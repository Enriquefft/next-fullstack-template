import { useEffect, useRef, useState } from "react";

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

export const useGooglePlaces = (apiKey: string): UseGooglePlacesReturn => {
	// Store the full suggestions for later details retrieval.
	const [suggestions, setSuggestions] = useState<CompleteSuggestion[]>([]);
	const [isLoading, setIsLoading] = useState<boolean>(false);
	const scriptLoaded = useRef<boolean>(false);

	useEffect(() => {
		// Check if the script is already loaded.
		if (window.google?.maps?.places || scriptLoaded.current) {
			return;
		}
		scriptLoaded.current = true;
		const script = document.createElement("script");
		script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`;
		script.async = true;
		script.defer = true;
		document.head.appendChild(script);
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
