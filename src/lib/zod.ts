import { z } from "zod";

export const removeNullable = <Schema extends z.AnyZodObject>(
	schema: Schema,
) => {
	const entries = Object.entries(schema.shape) as [
		keyof Schema["shape"],
		z.ZodTypeAny,
	][];
	const newProps = entries.reduce(
		(acc, [key, value]) => {
			acc[key] = value instanceof z.ZodNullable ? value.unwrap() : value;
			return acc;
		},
		{} as {
			[key in keyof Schema["shape"]]: Schema["shape"][key] extends z.ZodNullable<
				infer T
			>
				? z.ZodDefault<T>
				: Schema["shape"][key];
		},
	);
	return z.object(newProps);
};
