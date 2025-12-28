import { expect, test, type APIRequestContext } from "@playwright/test";
import { createAndAuthenticateUser } from "../helpers/auth.ts";

/**
 * Configuration for the link crawler
 */
const CRAWLER_CONFIG = {
	/** Maximum depth to crawl from entry points */
	maxDepth: 5,

	/** Maximum number of pages to visit (prevents runaway crawls) */
	maxPages: 200,

	/** Timeout for each page load in milliseconds (needs to be high for cold compilation) */
	pageTimeout: 30000,

	/** Timeout for external link requests */
	externalLinkTimeout: 15000,

	/** URL patterns to exclude from crawling (regex patterns) */
	excludePatterns: [
		/^\/api\//, // API routes
		/^mailto:/, // Email links
		/^tel:/, // Phone links
		/^javascript:/, // JS links
		/^data:/, // Data URLs
		/^blob:/, // Blob URLs
		/^\s*$/, // Empty hrefs
	],

	/** Patterns for links to skip entirely (not broken, just not crawlable) */
	skipPatterns: [
		/^#/, // Anchor-only links
	],

	/** External domains to skip (known to block automated requests) */
	skipExternalDomains: [
		"linkedin.com",
		"www.linkedin.com",
		"x.com",
		"twitter.com",
	],
};

interface CrawlResult {
	url: string;
	status: number;
	depth: number;
	source: string;
}

interface BrokenLink {
	url: string;
	status: number;
	source: string;
	depth: number;
}

interface ExternalLinkResult {
	url: string;
	status: number;
	source: string;
	error?: string;
}

/**
 * Normalizes a URL path for deduplication
 */
function normalizeUrlForDedup(url: string): string {
	try {
		const parsed = new URL(url, "http://localhost");
		return parsed.pathname;
	} catch {
		const withoutQuery = url.split("?")[0] ?? url;
		return withoutQuery.split("#")[0] ?? withoutQuery;
	}
}

/**
 * Checks if a URL matches any of the exclude patterns
 */
function shouldExclude(url: string): boolean {
	return CRAWLER_CONFIG.excludePatterns.some((pattern) => pattern.test(url));
}

/**
 * Checks if a URL should be skipped (valid but not crawlable)
 */
function shouldSkip(url: string): boolean {
	return CRAWLER_CONFIG.skipPatterns.some((pattern) => pattern.test(url));
}

/**
 * Checks if a URL is external
 */
function isExternalUrl(url: string, baseUrl: string): boolean {
	if (url.startsWith("http://") || url.startsWith("https://")) {
		try {
			const parsed = new URL(url);
			const base = new URL(baseUrl);
			return parsed.host !== base.host;
		} catch {
			return false;
		}
	}
	return false;
}

/**
 * Checks if an external URL should be skipped (known bot-blocking domains)
 */
function shouldSkipExternalDomain(url: string): boolean {
	try {
		const parsed = new URL(url);
		return CRAWLER_CONFIG.skipExternalDomains.some(
			(domain) =>
				parsed.host === domain || parsed.host.endsWith(`.${domain}`),
		);
	} catch {
		return false;
	}
}

/**
 * Resolves a potentially relative URL against a base URL
 */
function resolveUrl(
	href: string,
	currentUrl: string,
	baseUrl: string,
): string | null {
	if (shouldSkip(href) || shouldExclude(href)) {
		return null;
	}

	// Handle absolute external URLs
	if (href.startsWith("http://") || href.startsWith("https://")) {
		return href;
	}

	// Handle absolute internal paths
	if (href.startsWith("/")) {
		return href;
	}

	// Handle relative paths
	try {
		const base = new URL(currentUrl, baseUrl);
		const resolved = new URL(href, base);
		// Only return if it's on the same host
		if (resolved.host === new URL(baseUrl).host) {
			return resolved.pathname + resolved.search;
		}
		return resolved.href;
	} catch {
		return null;
	}
}

/**
 * Fetches and parses the sitemap to get all URLs
 */
async function fetchSitemapUrls(baseUrl: string): Promise<string[]> {
	try {
		const response = await fetch(`${baseUrl}/sitemap.xml`);
		if (!response.ok) {
			console.log(`⚠️ Could not fetch sitemap: ${response.status}`);
			return [];
		}

		const xml = await response.text();

		// Simple XML parsing for <loc> elements
		const urlMatches = xml.matchAll(/<loc>([^<]+)<\/loc>/g);
		const urls: string[] = [];

		for (const match of urlMatches) {
			const url = match[1];
			if (url) {
				// Convert absolute URLs to relative paths
				try {
					const parsed = new URL(url);
					urls.push(parsed.pathname);
				} catch {
					urls.push(url);
				}
			}
		}

		return [...new Set(urls)]; // Deduplicate
	} catch (error) {
		console.log(`⚠️ Error fetching sitemap: ${error}`);
		return [];
	}
}

/**
 * Checks an external link with HEAD request, falling back to GET if HEAD fails with 405
 */
async function checkExternalLink(
	request: APIRequestContext,
	url: string,
	source: string,
): Promise<ExternalLinkResult | null> {
	// Skip known bot-blocking domains
	if (shouldSkipExternalDomain(url)) {
		return null;
	}

	const maxRetries = 2;

	for (let attempt = 0; attempt < maxRetries; attempt++) {
		try {
			// Try HEAD request first (more efficient)
			const response = await request.head(url, {
				timeout: CRAWLER_CONFIG.externalLinkTimeout,
			});
			const status = response.status();

			// If HEAD returns 405 (Method Not Allowed), try GET instead
			if (status === 405) {
				const getResponse = await request.get(url, {
					timeout: CRAWLER_CONFIG.externalLinkTimeout,
				});
				return { url, status: getResponse.status(), source };
			}

			return { url, status, source };
		} catch (error) {
			if (attempt === maxRetries - 1) {
				return {
					url,
					status: 0,
					source,
					error: error instanceof Error ? error.message : "Unknown error",
				};
			}
			// Wait before retry
			await new Promise((r) => setTimeout(r, 1000));
		}
	}

	return { url, status: 0, source, error: "Max retries exceeded" };
}

test.describe("Broken Link Checker", () => {
	// Use longer timeout for crawling
	test.setTimeout(300000); // 5 minutes

	test("All internal links resolve correctly (unauthenticated)", async ({
		page,
		baseURL,
	}) => {
		const visited = new Map<string, CrawlResult>();
		const broken: BrokenLink[] = [];
		const externalLinks = new Map<string, string>(); // url -> source
		const toVisit: { url: string; depth: number; source: string }[] = [];

		// Get entry points from sitemap + root
		const sitemapUrls = await fetchSitemapUrls(baseURL!);
		console.log(`📍 Found ${sitemapUrls.length} URLs in sitemap`);

		// Add root as entry point
		toVisit.push({ url: "/", depth: 0, source: "entry-point" });

		// Add sitemap URLs as entry points
		for (const url of sitemapUrls) {
			toVisit.push({ url, depth: 0, source: "sitemap" });
		}

		let pagesVisited = 0;

		while (toVisit.length > 0 && pagesVisited < CRAWLER_CONFIG.maxPages) {
			const current = toVisit.shift();
			if (!current) break;

			const normalizedUrl = normalizeUrlForDedup(current.url);

			// Skip if already visited
			if (visited.has(normalizedUrl)) {
				continue;
			}

			// Skip if exceeds max depth
			if (current.depth > CRAWLER_CONFIG.maxDepth) {
				continue;
			}

			// Skip excluded patterns
			if (shouldExclude(current.url)) {
				continue;
			}

			pagesVisited++;

			// Visit the page
			let status: number;
			try {
				const response = await page.goto(current.url, {
					timeout: CRAWLER_CONFIG.pageTimeout,
					waitUntil: "domcontentloaded",
				});
				status = response?.status() ?? 0;
			} catch {
				status = 0;
			}

			const result: CrawlResult = {
				url: current.url,
				status,
				depth: current.depth,
				source: current.source,
			};

			visited.set(normalizedUrl, result);

			// Track broken links (4xx and 5xx status codes, or connection failures)
			if (status >= 400 || status === 0) {
				broken.push({
					url: current.url,
					status,
					source: current.source,
					depth: current.depth,
				});
				// Don't crawl links from broken pages
				continue;
			}

			// Extract links from this page
			const links = await page
				.locator("a[href]")
				.evaluateAll((anchors) =>
					anchors
						.map((a) => a.getAttribute("href"))
						.filter((href): href is string => !!href),
				);

			// Process links
			for (const href of links) {
				const resolvedUrl = resolveUrl(href, current.url, baseURL!);
				if (!resolvedUrl) {
					continue;
				}

				// Check if external
				if (isExternalUrl(resolvedUrl, baseURL!)) {
					if (!externalLinks.has(resolvedUrl)) {
						externalLinks.set(resolvedUrl, current.url);
					}
					continue;
				}

				// Queue internal links
				const normalizedResolvedUrl = normalizeUrlForDedup(resolvedUrl);
				if (
					!visited.has(normalizedResolvedUrl) &&
					!shouldExclude(resolvedUrl)
				) {
					toVisit.push({
						url: resolvedUrl,
						depth: current.depth + 1,
						source: current.url,
					});
				}
			}
		}

		// Check external links
		const externalBroken: ExternalLinkResult[] = [];
		console.log(`🔗 Checking ${externalLinks.size} external links...`);

		for (const [url, source] of externalLinks) {
			const result = await checkExternalLink(page.request, url, source);
			if (result && (result.status >= 400 || result.status === 0)) {
				externalBroken.push(result);
			}
		}

		// Report results
		console.log(`\n📊 Link Crawler Results:`);
		console.log(`   Sitemap URLs: ${sitemapUrls.length}`);
		console.log(`   Pages visited: ${pagesVisited}`);
		console.log(`   External links checked: ${externalLinks.size}`);
		console.log(`   Broken internal links: ${broken.length}`);
		console.log(`   Broken external links: ${externalBroken.length}`);

		if (broken.length > 0) {
			console.log(`\n❌ Broken Internal Links:`);
			for (const link of broken) {
				console.log(`   ${link.status}: ${link.url}`);
				console.log(`      Found on: ${link.source} (depth: ${link.depth})`);
			}
		}

		if (externalBroken.length > 0) {
			console.log(`\n❌ Broken External Links:`);
			for (const link of externalBroken) {
				console.log(`   ${link.status}: ${link.url}`);
				console.log(`      Found on: ${link.source}`);
				if (link.error) {
					console.log(`      Error: ${link.error}`);
				}
			}
		}

		expect(
			broken,
			`Found ${broken.length} broken internal links:\n${broken.map((b) => `  ${b.status}: ${b.url} (from ${b.source})`).join("\n")}`,
		).toEqual([]);

		expect(
			externalBroken,
			`Found ${externalBroken.length} broken external links:\n${externalBroken.map((b) => `  ${b.status}: ${b.url} (from ${b.source})`).join("\n")}`,
		).toEqual([]);
	});

	test("All internal links resolve correctly (authenticated)", async ({
		page,
		baseURL,
	}) => {
		// Create and authenticate a user
		await createAndAuthenticateUser(page);

		const visited = new Map<string, CrawlResult>();
		const broken: BrokenLink[] = [];
		const externalLinks = new Map<string, string>();
		const toVisit: { url: string; depth: number; source: string }[] = [];

		// Get entry points from sitemap + root
		const sitemapUrls = await fetchSitemapUrls(baseURL!);
		console.log(`📍 Found ${sitemapUrls.length} URLs in sitemap (authenticated)`);

		toVisit.push({ url: "/", depth: 0, source: "entry-point" });

		for (const url of sitemapUrls) {
			toVisit.push({ url, depth: 0, source: "sitemap" });
		}

		let pagesVisited = 0;

		while (toVisit.length > 0 && pagesVisited < CRAWLER_CONFIG.maxPages) {
			const current = toVisit.shift();
			if (!current) break;

			const normalizedUrl = normalizeUrlForDedup(current.url);

			if (visited.has(normalizedUrl)) {
				continue;
			}

			if (current.depth > CRAWLER_CONFIG.maxDepth) {
				continue;
			}

			if (shouldExclude(current.url)) {
				continue;
			}

			pagesVisited++;

			let status: number;
			try {
				const response = await page.goto(current.url, {
					timeout: CRAWLER_CONFIG.pageTimeout,
					waitUntil: "domcontentloaded",
				});
				status = response?.status() ?? 0;
			} catch {
				status = 0;
			}

			const result: CrawlResult = {
				url: current.url,
				status,
				depth: current.depth,
				source: current.source,
			};

			visited.set(normalizedUrl, result);

			if (status >= 400 || status === 0) {
				broken.push({
					url: current.url,
					status,
					source: current.source,
					depth: current.depth,
				});
				continue;
			}

			const links = await page
				.locator("a[href]")
				.evaluateAll((anchors) =>
					anchors
						.map((a) => a.getAttribute("href"))
						.filter((href): href is string => !!href),
				);

			for (const href of links) {
				const resolvedUrl = resolveUrl(href, current.url, baseURL!);
				if (!resolvedUrl) {
					continue;
				}

				if (isExternalUrl(resolvedUrl, baseURL!)) {
					if (!externalLinks.has(resolvedUrl)) {
						externalLinks.set(resolvedUrl, current.url);
					}
					continue;
				}

				const normalizedResolvedUrl = normalizeUrlForDedup(resolvedUrl);
				if (
					!visited.has(normalizedResolvedUrl) &&
					!shouldExclude(resolvedUrl)
				) {
					toVisit.push({
						url: resolvedUrl,
						depth: current.depth + 1,
						source: current.url,
					});
				}
			}
		}

		// Check external links
		const externalBroken: ExternalLinkResult[] = [];
		console.log(`🔗 Checking ${externalLinks.size} external links (authenticated)...`);

		for (const [url, source] of externalLinks) {
			const result = await checkExternalLink(page.request, url, source);
			if (result && (result.status >= 400 || result.status === 0)) {
				externalBroken.push(result);
			}
		}

		// Report results
		console.log(`\n📊 Link Crawler Results (Authenticated):`);
		console.log(`   Sitemap URLs: ${sitemapUrls.length}`);
		console.log(`   Pages visited: ${pagesVisited}`);
		console.log(`   External links checked: ${externalLinks.size}`);
		console.log(`   Broken internal links: ${broken.length}`);
		console.log(`   Broken external links: ${externalBroken.length}`);

		if (broken.length > 0) {
			console.log(`\n❌ Broken Internal Links (Authenticated):`);
			for (const link of broken) {
				console.log(`   ${link.status}: ${link.url}`);
				console.log(`      Found on: ${link.source} (depth: ${link.depth})`);
			}
		}

		if (externalBroken.length > 0) {
			console.log(`\n❌ Broken External Links (Authenticated):`);
			for (const link of externalBroken) {
				console.log(`   ${link.status}: ${link.url}`);
				console.log(`      Found on: ${link.source}`);
				if (link.error) {
					console.log(`      Error: ${link.error}`);
				}
			}
		}

		expect(
			broken,
			`Found ${broken.length} broken internal links:\n${broken.map((b) => `  ${b.status}: ${b.url} (from ${b.source})`).join("\n")}`,
		).toEqual([]);

		expect(
			externalBroken,
			`Found ${externalBroken.length} broken external links:\n${externalBroken.map((b) => `  ${b.status}: ${b.url} (from ${b.source})`).join("\n")}`,
		).toEqual([]);
	});
});
