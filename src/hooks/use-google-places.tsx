import { useEffect, useState } from "react";

type PlacePrediction = {
	description: string;
	place_id: string;
};

type CompleteSuggestion = PlacePrediction & {
	fullSuggestion: google.maps.places.PlacePrediction;
};

type UseGooglePlacesReturn = {
	placePredictions: PlacePrediction[];
	isLoading: boolean;
	searchPlaces: (query: string) => Promise<void>;
};

let googlePlacesLoading: Promise<void> | null = null;
export const useGooglePlaces = (apiKey: string): UseGooglePlacesReturn => {
	// Store the full suggestions for later details retrieval.
	const [suggestions, setSuggestions] = useState<CompleteSuggestion[]>([]);
	const [isLoading, setIsLoading] = useState<boolean>(false);

	useEffect(() => {
		if (!googlePlacesLoading) {
			googlePlacesLoading = new Promise((resolve, reject) => {
				if (window.google?.maps?.places) return resolve();
				const s = document.createElement("script");
				s.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`;
				s.onload = () => resolve();
				s.onerror = reject;
				document.head.appendChild(s);
			});
		}
	}, [apiKey]);

	const searchPlaces = async (query: string): Promise<void> => {
		if (!query) {
			setSuggestions([]);
			return;
		}
		setIsLoading(true);
		try {
			const sessionToken = new google.maps.places.AutocompleteSessionToken();
			const request = {
				includedRegionCodes: ["PE"],
				input: query,
				sessionToken,
			};
			const { suggestions: fetchedSuggestions } =
				await google.maps.places.AutocompleteSuggestion.fetchAutocompleteSuggestions(
					request,
				);

			if (!fetchedSuggestions) {
				setSuggestions([]);
			} else {
				setSuggestions(
					fetchedSuggestions
						.map((s) => {
							if (!s.placePrediction) {
								return null;
							}
							if (!s) {
								return null;
							}

							return {
								description: s.placePrediction.text.text,
								fullSuggestion: s.placePrediction,
								place_id: s.placePrediction.placeId,
							};
						})
						.filter(Boolean) as CompleteSuggestion[],
				);
			}
		} catch (error) {
			console.error("Error fetching autocomplete suggestions:", error);
			setSuggestions([]);
		} finally {
			setIsLoading(false);
		}
	};

	// Expose only minimal prediction data.
	const placePredictions: PlacePrediction[] = suggestions.map(
		({ description, place_id }) => ({ description, place_id }),
	);

	return {
		isLoading,
		placePredictions,
		searchPlaces,
	};
};
