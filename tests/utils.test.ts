import { expect } from "@jest/globals";

/**
 * Asserts that a value is not null.
 * @param value - Any value.
 */
export function assertNotNull<T>(value: T): asserts value is NonNullable<T> {
	expect(value).not.toBeNull();
}
