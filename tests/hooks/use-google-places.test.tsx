import { beforeEach, expect, test } from "@jest/globals";
import { render, waitFor } from "@testing-library/react";
import { useGooglePlaces } from "@/hooks/use-google-places";

function TestComponent({ apiKey }: { apiKey: string }) {
	useGooglePlaces(apiKey);
	return null;
}

beforeEach(() => {
	document.head.innerHTML = "";

	// @ts-ignore
	delete window.google;
});

test("injects Google Places script once after effect runs", async () => {
	const apiKey = "FAKE_KEY";
	render(<TestComponent apiKey={apiKey} />);

	await waitFor(() => {
		const scripts = document.querySelectorAll(
			"script[src*='maps.googleapis.com/maps/api/js']",
		);
		expect(scripts).toHaveLength(1);

		if (scripts[0]) {
			expect(scripts[0].getAttribute("src")).toContain(`key=${apiKey}`);
		}
	});
});
