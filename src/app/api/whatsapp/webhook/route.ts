import {
	normalizeWebhook,
	verifySignature,
} from "@kapso/whatsapp-cloud-api/server";
import { type NextRequest, NextResponse } from "next/server";
import { serverEnv } from "@/env/server.ts";

export const runtime = "nodejs";

// Webhook verification (GET) - Meta sends this to verify your endpoint
export async function GET(request: NextRequest) {
	const searchParams = request.nextUrl.searchParams;
	const mode = searchParams.get("hub.mode");
	const token = searchParams.get("hub.verify_token");
	const challenge = searchParams.get("hub.challenge");

	// Verify the webhook with the token you set in Meta Business Suite
	const verifyToken = serverEnv.META_APP_SECRET;

	if (mode === "subscribe" && token === verifyToken) {
		console.log("Webhook verified successfully");
		return new NextResponse(challenge, { status: 200 });
	}

	console.error("Webhook verification failed");
	return new NextResponse("Forbidden", { status: 403 });
}

// Webhook events (POST) - Meta sends events here
export async function POST(request: NextRequest) {
	const appSecret = serverEnv.META_APP_SECRET;

	if (!appSecret) {
		console.error("META_APP_SECRET not configured");
		return NextResponse.json({ error: "Not configured" }, { status: 500 });
	}

	// Get raw body for signature verification
	const rawBody = await request.text();
	const signatureHeader = request.headers.get("x-hub-signature-256");

	// Verify the webhook signature
	const isValid = verifySignature({
		appSecret,
		rawBody,
		signatureHeader: signatureHeader ?? undefined,
	});

	if (!isValid) {
		console.error("Invalid webhook signature");
		return NextResponse.json({ error: "Invalid signature" }, { status: 401 });
	}

	// Parse and normalize the webhook payload
	const payload = JSON.parse(rawBody);
	const events = normalizeWebhook(payload);

	// Handle incoming messages
	for (const message of events.messages) {
		console.log("Received message:", {
			from: message.from,
			// Text messages have a text.body property
			text: message.type === "text" ? message.text?.body : undefined,
			timestamp: message.timestamp,
			type: message.type,
		});

		// TODO: Add your message handling logic here
		// Examples:
		// - Store messages in database
		// - Trigger AI agent responses
		// - Forward to support system
	}

	// Handle message status updates (delivered, read, failed)
	for (const status of events.statuses) {
		console.log("Message status:", {
			id: status.id,
			recipientId: status.recipientId,
			status: status.status,
			timestamp: status.timestamp,
		});

		// TODO: Add your status handling logic here
		// Examples:
		// - Update message status in database
		// - Trigger analytics events
		// - Handle failed message retries
	}

	// Handle voice/video calls
	for (const call of events.calls) {
		console.log("Call event:", call);

		// TODO: Add your call handling logic here
	}

	// Access other webhook fields via events.raw
	// e.g., events.raw.accountAlerts, events.raw.templateCategoryUpdate

	return NextResponse.json({ success: true }, { status: 200 });
}
