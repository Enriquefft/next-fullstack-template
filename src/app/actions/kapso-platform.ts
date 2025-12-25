"use server";

import { z } from "zod";
import {
	createKapsoCustomer as createCustomer,
	getKapsoCustomer as fetchCustomer,
	listKapsoCustomers as fetchCustomers,
	createSetupLink as generateSetupLink,
} from "@/lib/kapso.ts";

/**
 * Create a Kapso customer (Platform API)
 *
 * Creates a customer record for multi-tenant WhatsApp integration.
 * This allows your customers to connect their own WhatsApp Business accounts.
 */
export async function createKapsoCustomer(data: {
	name: string;
	email?: string;
	metadata?: Record<string, unknown>;
}) {
	const schema = z.object({
		email: z.string().email().optional(),
		metadata: z.record(z.string(), z.unknown()).optional(),
		name: z.string().min(1),
	});

	const validated = schema.parse(data);

	try {
		const customer = await createCustomer(validated);
		return { data: customer, success: true };
	} catch (error) {
		console.error("Failed to create Kapso customer:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}

/**
 * Generate a setup link for a customer (Platform API)
 *
 * Creates a hosted onboarding page where customers can connect their
 * WhatsApp Business account through Meta's embedded signup process.
 */
export async function createSetupLink(customerId: string) {
	const schema = z.string().min(1);
	const validated = schema.parse(customerId);

	try {
		const setupLink = await generateSetupLink(validated);
		return { data: setupLink, success: true };
	} catch (error) {
		console.error("Failed to create setup link:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}

/**
 * Get customer details (Platform API)
 */
export async function getKapsoCustomer(customerId: string) {
	const schema = z.string().min(1);
	const validated = schema.parse(customerId);

	try {
		const customer = await fetchCustomer(validated);
		return { data: customer, success: true };
	} catch (error) {
		console.error("Failed to get Kapso customer:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}

/**
 * List all customers (Platform API)
 */
export async function listKapsoCustomers() {
	try {
		const customers = await fetchCustomers();
		return { data: customers, success: true };
	} catch (error) {
		console.error("Failed to list Kapso customers:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}
