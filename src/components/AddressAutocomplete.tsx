import { MapPin } from "lucide-react";
import { useState } from "react";
import type { Control, FieldValues, Path } from "react-hook-form";
import {
	Command,
	CommandEmpty,
	CommandGroup,
	CommandInput,
	CommandItem,
	CommandList,
} from "@/components/ui/command";
import {
	FormControl,
	FormField,
	FormItem,
	FormLabel,
	FormMessage,
} from "@/components/ui/form";
import { useGooglePlaces } from "@/hooks/use-google-places";
import { debounce } from "@/lib/utils.ts";

type AddressAutocompleteProps<T extends FieldValues> = {
	control: Control<T>;
	name: Path<T>;
	label?: string;
	placeholder?: string;
	apiKey: string;
};

export function AddressAutocomplete<T extends FieldValues>({
	control,
	name,
	label = "Address",
	placeholder = "Enter an address",
	apiKey,
}: AddressAutocompleteProps<T>) {
	const { placePredictions, isLoading, searchPlaces } = useGooglePlaces(apiKey);
	const [open, setOpen] = useState(false);

	// Create a debounced search function
	const debouncedSearch = debounce((value: string) => {
		searchPlaces(value);
	}, 300);

	return (
		<FormField
			control={control}
			name={name}
			render={({ field }) => (
				<FormItem className="flex flex-col">
					<FormLabel>{label}</FormLabel>
					<FormControl>
						<Command className="overflow-visible bg-transparent w-full">
							<CommandInput
								placeholder={placeholder}
								value={field.value}
								onValueChange={(value) => {
									field.onChange(value);
									if (value.trim().length > 0) {
										debouncedSearch(value);
										setOpen(true);
									} else {
										setOpen(false);
									}
								}}
								onFocus={() => field.value.trim().length > 0 && setOpen(true)}
								onBlur={() => setTimeout(() => setOpen(false), 200)}
								className="border rounded-md px-3 py-2 w-full"
							/>
							{open && (
								<CommandList className="bg-white border rounded-md shadow-md max-h-60 overflow-auto">
									{isLoading ? (
										<p className="p-2">Loading addresses...</p>
									) : null}
									<CommandEmpty>No addresses found</CommandEmpty>
									<CommandGroup>
										{placePredictions.map((place) => (
											<CommandItem
												key={place.place_id}
												value={place.description}
												onSelect={(value) => {
													field.onChange(value);
													setOpen(false);
												}}
												className="flex items-start gap-2 py-2"
											>
												<MapPin className="h-4 w-4 text-muted-foreground flex-shrink-0 mt-0.5" />
												<span>{place.description}</span>
											</CommandItem>
										))}
									</CommandGroup>
								</CommandList>
							)}
						</Command>
					</FormControl>
					<FormMessage />
				</FormItem>
			)}
		/>
	);
}
