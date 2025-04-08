import { isRedirectError } from "next/dist/client/components/redirect-error";
import { toast } from "sonner";
import { z } from "zod";

export function getErrorMessage(err: unknown) {
	const unknownErrorMessage = "Something went wrong, please try again later.";

	if (err instanceof z.ZodError) {
		const errors = err.issues.map((issue) => {
			return issue.message;
		});
		return errors.join("\n");
	}
	if (err instanceof Error) {
		return err.message;
	}
	if (isRedirectError(err)) {
		throw err;
	}
	return unknownErrorMessage;
}

export function showErrorToast(err: unknown) {
	const errorMessage = getErrorMessage(err);
	return toast.error(errorMessage);
}
