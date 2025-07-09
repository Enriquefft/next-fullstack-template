import { beforeEach, expect, test } from "@jest/globals";
import { render, waitFor } from "@testing-library/react";
import {
	resetGooglePlacesLoading,
	useGooglePlaces,
} from "@/hooks/use-google-places";

function TestComponent({ apiKey }: { apiKey: string }) {
	useGooglePlaces(apiKey);
	return null;
}

beforeEach(() => {
	// reset DOM and globals
	resetGooglePlacesLoading();
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

test("does not append duplicate script on multiple mounts", async () => {
	const apiKey = "FAKE_KEY";
	render(<TestComponent apiKey={apiKey} />);
	render(<TestComponent apiKey={apiKey} />);

	await waitFor(() => {
		const scripts = document.querySelectorAll(
			"script[src*='maps.googleapis.com/maps/api/js']",
		);
		expect(scripts).toHaveLength(1);
	});
});

test("skips injection if window.google.maps.places already exists", async () => {
	window.google = {
		maps: {
			// @ts-ignore
			places: {},
		},
	};
	render(<TestComponent apiKey="FAKE_KEY" />);

	await waitFor(() => {
		const scripts = document.querySelectorAll(
			"script[src*='maps.googleapis.com/maps/api/js']",
		);
		expect(scripts).toHaveLength(0);
	});
});
