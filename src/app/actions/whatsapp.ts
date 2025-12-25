"use server";

import { z } from "zod";
import { kapsoClient } from "@/lib/kapso.ts";

/**
 * Send a WhatsApp text message using Kapso
 *
 * @param phoneNumberId - The WhatsApp phone number ID (from your Kapso account)
 * @param to - The recipient's phone number (include country code, e.g., "1234567890")
 * @param message - The text message to send
 */
export async function sendWhatsAppMessage(
	phoneNumberId: string,
	to: string,
	message: string,
) {
	if (!kapsoClient) {
		throw new Error(
			"Kapso is not configured. Please set KAPSO_API_KEY in your environment variables.",
		);
	}

	const schema = z.object({
		message: z.string().min(1),
		phoneNumberId: z.string().min(1),
		to: z.string().min(1),
	});

	const validated = schema.parse({ message, phoneNumberId, to });

	try {
		const response = await kapsoClient.messages.sendText({
			body: validated.message,
			phoneNumberId: validated.phoneNumberId,
			to: validated.to,
		});

		return { data: response, success: true };
	} catch (error) {
		console.error("Failed to send WhatsApp message:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}

/**
 * Send a WhatsApp template message
 *
 * Template messages are pre-approved message templates that can be sent to users
 * who haven't messaged you in the last 24 hours.
 *
 * @param phoneNumberId - The WhatsApp phone number ID
 * @param to - The recipient's phone number
 * @param templateName - The name of the approved template
 * @param languageCode - The language code (e.g., "en_US")
 */
export async function sendWhatsAppTemplate(
	phoneNumberId: string,
	to: string,
	templateName: string,
	languageCode = "en_US",
) {
	if (!kapsoClient) {
		throw new Error(
			"Kapso is not configured. Please set KAPSO_API_KEY in your environment variables.",
		);
	}

	const schema = z.object({
		languageCode: z.string().min(1),
		phoneNumberId: z.string().min(1),
		templateName: z.string().min(1),
		to: z.string().min(1),
	});

	const validated = schema.parse({
		languageCode,
		phoneNumberId,
		templateName,
		to,
	});

	try {
		const response = await kapsoClient.messages.sendTemplate({
			phoneNumberId: validated.phoneNumberId,
			template: {
				language: {
					code: validated.languageCode,
				},
				name: validated.templateName,
			},
			to: validated.to,
		});

		return { data: response, success: true };
	} catch (error) {
		console.error("Failed to send WhatsApp template:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}

/**
 * Send a WhatsApp interactive button message
 *
 * @param phoneNumberId - The WhatsApp phone number ID
 * @param to - The recipient's phone number
 * @param bodyText - The main message text
 * @param buttons - Array of buttons (max 3)
 */
export async function sendWhatsAppButtons(
	phoneNumberId: string,
	to: string,
	bodyText: string,
	buttons: Array<{ id: string; title: string }>,
) {
	if (!kapsoClient) {
		throw new Error(
			"Kapso is not configured. Please set KAPSO_API_KEY in your environment variables.",
		);
	}

	const schema = z.object({
		bodyText: z.string().min(1),
		buttons: z
			.array(
				z.object({
					id: z.string(),
					title: z.string().max(20),
				}),
			)
			.max(3),
		phoneNumberId: z.string().min(1),
		to: z.string().min(1),
	});

	const validated = schema.parse({ bodyText, buttons, phoneNumberId, to });

	try {
		const response = await kapsoClient.messages.sendInteractiveButtons({
			bodyText: validated.bodyText,
			buttons: validated.buttons,
			phoneNumberId: validated.phoneNumberId,
			to: validated.to,
		});

		return { data: response, success: true };
	} catch (error) {
		console.error("Failed to send WhatsApp buttons:", error);
		return {
			error: error instanceof Error ? error.message : "Unknown error",
			success: false,
		};
	}
}
