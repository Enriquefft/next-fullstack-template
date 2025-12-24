import type { Thing, WithContext } from "@/lib/seo/schema";

/**
 * SchemaScript Component
 *
 * Renders JSON-LD structured data in a script tag
 * Use this component to add schemas to any page
 *
 * @example Single schema
 * ```tsx
 * <SchemaScript schema={organizationSchema} />
 * ```
 *
 * @example Multiple schemas
 * ```tsx
 * <SchemaScript schema={[organizationSchema, websiteSchema]} />
 * ```
 */
export function SchemaScript({
	schema,
}: {
	schema: WithContext<Thing> | WithContext<Thing>[];
}) {
	const schemaArray = Array.isArray(schema) ? schema : [schema];

	return (
		<>
			{schemaArray.map((s, index) => (
				<script
					key={`${s["@type"]}-${index}`}
					type="application/ld+json"
					// biome-ignore lint/security/noDangerouslySetInnerHtml: Required for JSON-LD structured data
					dangerouslySetInnerHTML={{
						__html: JSON.stringify(s, null, 0),
					}}
				/>
			))}
		</>
	);
}
