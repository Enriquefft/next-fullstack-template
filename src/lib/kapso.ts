import "server-only";
import { WhatsAppClient } from "@kapso/whatsapp-cloud-api";
import { serverEnv } from "@/env/server.ts";

/**
 * Kapso WhatsApp Cloud API Client
 *
 * This client allows you to send and receive WhatsApp messages using the WhatsApp Cloud API
 * through Kapso's infrastructure.
 *
 * @see https://docs.kapso.ai for documentation
 */
export const kapsoClient = serverEnv.KAPSO_API_KEY
	? new WhatsAppClient({
			baseUrl: "https://api.kapso.ai/meta/whatsapp",
			kapsoApiKey: serverEnv.KAPSO_API_KEY,
		})
	: null;

/**
 * Kapso Platform API Base URL
 *
 * Use this for Platform API endpoints that enable multi-tenant WhatsApp integrations
 * where your customers connect their own WhatsApp Business accounts.
 */
export const KAPSO_PLATFORM_API_URL = "https://api.kapso.ai/platform/v1";

/**
 * Platform API helper to make authenticated requests to Kapso Platform API
 */
export const kapsoPlatformFetch = async (
	endpoint: string,
	options: RequestInit = {},
) => {
	if (!serverEnv.KAPSO_API_KEY) {
		throw new Error("KAPSO_API_KEY is not configured");
	}

	const url = `${KAPSO_PLATFORM_API_URL}${endpoint}`;

	const response = await fetch(url, {
		...options,
		headers: {
			"Content-Type": "application/json",
			"X-API-Key": serverEnv.KAPSO_API_KEY,
			...options.headers,
		},
	});

	if (!response.ok) {
		const error = await response.text();
		throw new Error(`Kapso Platform API error: ${response.status} - ${error}`);
	}

	return response.json();
};

/**
 * Platform API: Create a customer
 *
 * Creates a customer record for multi-tenant WhatsApp integration.
 * Returns a customer_id for future API calls.
 */
export const createKapsoCustomer = async (data: {
	name: string;
	email?: string;
	metadata?: Record<string, unknown>;
}) => {
	return kapsoPlatformFetch("/customers", {
		body: JSON.stringify(data),
		method: "POST",
	});
};

/**
 * Platform API: Generate setup link for customer
 *
 * Creates a hosted onboarding page where customers can connect their WhatsApp Business account.
 * The link guides users through Meta's embedded signup process.
 */
export const createSetupLink = async (customerId: string) => {
	return kapsoPlatformFetch(`/customers/${customerId}/setup_links`, {
		body: JSON.stringify({}),
		method: "POST",
	});
};

/**
 * Platform API: Get customer details
 */
export const getKapsoCustomer = async (customerId: string) => {
	return kapsoPlatformFetch(`/customers/${customerId}`, {
		method: "GET",
	});
};

/**
 * Platform API: List all customers
 */
export const listKapsoCustomers = async () => {
	return kapsoPlatformFetch("/customers", {
		method: "GET",
	});
};
