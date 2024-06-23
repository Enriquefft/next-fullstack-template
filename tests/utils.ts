import {expect} from "bun:test"

/**
 * Asserts that a value is not nul:.
 * @param value - Any value.
 */
export function assertNotNull<T>(value: T): asserts value is NonNullable<T> {
  expect(value).not.toBeNull();
}
