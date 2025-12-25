import "server-only";
import { WhatsAppClient } from "@kapso/whatsapp-cloud-api";
import { serverEnv } from "@/env/server.ts";

const isConfigured =
	!!serverEnv.KAPSO_API_KEY && !!serverEnv.KAPSO_PHONE_NUMBER_ID;

export const kapsoClient = isConfigured
	? new WhatsAppClient({
			baseUrl: "https://api.kapso.ai/meta/whatsapp",
			kapsoApiKey: serverEnv.KAPSO_API_KEY,
		})
	: null;

export const phoneNumberId = serverEnv.KAPSO_PHONE_NUMBER_ID;

export async function sendTextMessage(to: string, body: string) {
	if (!kapsoClient || !phoneNumberId) {
		throw new Error(
			"Kapso is not configured. Set KAPSO_API_KEY and KAPSO_PHONE_NUMBER_ID.",
		);
	}
	return kapsoClient.messages.sendText({
		body,
		phoneNumberId,
		to,
	});
}

export async function sendTemplateMessage(
	to: string,
	templateName: string,
	languageCode = "en",
) {
	if (!kapsoClient || !phoneNumberId) {
		throw new Error(
			"Kapso is not configured. Set KAPSO_API_KEY and KAPSO_PHONE_NUMBER_ID.",
		);
	}
	return kapsoClient.messages.sendTemplate({
		phoneNumberId,
		template: {
			language: { code: languageCode },
			name: templateName,
		},
		to,
	});
}

export async function sendImageMessage(
	to: string,
	imageUrl: string,
	caption?: string,
) {
	if (!kapsoClient || !phoneNumberId) {
		throw new Error(
			"Kapso is not configured. Set KAPSO_API_KEY and KAPSO_PHONE_NUMBER_ID.",
		);
	}
	return kapsoClient.messages.sendImage({
		image: { caption, link: imageUrl },
		phoneNumberId,
		to,
	});
}

export async function sendDocumentMessage(
	to: string,
	documentUrl: string,
	filename: string,
	caption?: string,
) {
	if (!kapsoClient || !phoneNumberId) {
		throw new Error(
			"Kapso is not configured. Set KAPSO_API_KEY and KAPSO_PHONE_NUMBER_ID.",
		);
	}
	return kapsoClient.messages.sendDocument({
		document: { caption, filename, link: documentUrl },
		phoneNumberId,
		to,
	});
}

export async function sendButtonMessage(
	to: string,
	bodyText: string,
	buttons: Array<{ id: string; title: string }>,
	headerText?: string,
	footerText?: string,
) {
	if (!kapsoClient || !phoneNumberId) {
		throw new Error(
			"Kapso is not configured. Set KAPSO_API_KEY and KAPSO_PHONE_NUMBER_ID.",
		);
	}
	return kapsoClient.messages.sendInteractiveButtons({
		bodyText,
		buttons,
		footerText,
		header: headerText ? { text: headerText, type: "text" } : undefined,
		phoneNumberId,
		to,
	});
}

export { isConfigured as isKapsoConfigured };
