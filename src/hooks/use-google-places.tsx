import { useJsApiLoader } from "@react-google-maps/api";
import { useCallback, useState } from "react";

type PlacePrediction = {
	description: string;
	place_id: string;
};

type UseGooglePlacesReturn = {
	placePredictions: PlacePrediction[];
	isLoading: boolean;
	searchPlaces: (query: string) => Promise<void>;
};

export const useGooglePlaces = (apiKey: string): UseGooglePlacesReturn => {
	const { isLoaded, loadError } = useJsApiLoader({
		googleMapsApiKey: apiKey,
		libraries: ["places"],
		region: "PE",
	});

	const [placePredictions, setPlacePredictions] = useState<PlacePrediction[]>(
		[],
	);
	const [isLoading, setIsLoading] = useState(false);

	const searchPlaces = useCallback(
		async (query: string) => {
			if (!isLoaded || loadError) {
				setPlacePredictions([]);
				return;
			}

			if (!query) {
				setPlacePredictions([]);
				return;
			}

			setIsLoading(true);

			const service = new window.google.maps.places.AutocompleteService();
			const sessionToken =
				new window.google.maps.places.AutocompleteSessionToken();

			const request: google.maps.places.AutocompletionRequest = {
				componentRestrictions: { country: "PE" },
				input: query,
				sessionToken,
			};

			const predictions: PlacePrediction[] = await new Promise((res) =>
				service.getPlacePredictions(request, (results, status) => {
					if (
						status === window.google.maps.places.PlacesServiceStatus.OK &&
						results
					) {
						res(
							results.map((p) => ({
								description: p.description,
								place_id: p.place_id,
							})),
						);
					} else {
						res([]);
					}
				}),
			);

			setPlacePredictions(predictions);
			setIsLoading(false);
		},
		[isLoaded, loadError],
	);

	return {
		isLoading,
		placePredictions,
		searchPlaces,
	};
};
