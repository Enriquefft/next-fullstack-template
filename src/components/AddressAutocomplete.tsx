import type { DeepKeys } from "@tanstack/react-form";
import { MapPin } from "lucide-react";
import { useState } from "react";
import {
	Command,
	CommandEmpty,
	CommandGroup,
	CommandInput,
	CommandItem,
	CommandList,
} from "@/components/ui/command";
import {
	Field,
	FieldControl,
	FieldError,
	FieldLabel,
} from "@/components/ui/field";
import { useGooglePlaces } from "@/hooks/use-google-places";
import { debounce } from "@/lib/utils.ts";

type TanStackFieldApi<TValue> = {
	state: {
		value: TValue;
		meta: {
			errors: string[];
		};
	};
	handleChange: (value: TValue) => void;
	handleBlur: () => void;
};

type TanStackForm<TFormData> = {
	Field: <TName extends DeepKeys<TFormData>>(props: {
		name: TName;
		children: (field: TanStackFieldApi<unknown>) => React.ReactNode;
	}) => React.ReactElement;
};

type AddressAutocompleteProps<TFormData> = {
	form: TanStackForm<TFormData>;
	name: DeepKeys<TFormData>;
	label?: string;
	placeholder?: string;
	apiKey: string;
};

export function AddressAutocomplete<TFormData extends Record<string, unknown>>({
	form,
	name,
	label = "Address",
	placeholder = "Enter an address",
	apiKey,
}: AddressAutocompleteProps<TFormData>) {
	const { placePredictions, isLoading, searchPlaces } = useGooglePlaces(apiKey);
	const [open, setOpen] = useState(false);

	// Create a debounced search function
	const debouncedSearch = debounce((value: string) => {
		searchPlaces(value);
	}, 300);

	return (
		<form.Field name={name}>
			{(field) => {
				const fieldValue = String(field.state.value ?? "");
				const hasErrors = field.state.meta.errors.length > 0;

				return (
					<Field data-invalid={hasErrors}>
						<FieldLabel data-error={hasErrors}>{label}</FieldLabel>
						<FieldControl>
							<Command className="overflow-visible bg-transparent w-full">
								<CommandInput
									placeholder={placeholder}
									value={fieldValue}
									onValueChange={(value) => {
										field.handleChange(value);
										if (value.trim().length > 0) {
											debouncedSearch(value);
											setOpen(true);
										} else {
											setOpen(false);
										}
									}}
									onFocus={() => fieldValue.trim().length > 0 && setOpen(true)}
									onBlur={() => {
										field.handleBlur();
										setTimeout(() => setOpen(false), 200);
									}}
									className="border rounded-md px-3 py-2 w-full"
									aria-invalid={hasErrors}
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
														field.handleChange(value);
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
						</FieldControl>
						{hasErrors ? (
							<FieldError>{field.state.meta.errors.join(", ")}</FieldError>
						) : null}
					</Field>
				);
			}}
		</form.Field>
	);
}
