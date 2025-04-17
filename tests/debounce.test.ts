// biome-ignore-all lint/suspicious/noExplicitAny: reason
import { expect, test } from "bun:test";
import { debounce } from "@/lib/utils.ts";

// In these tests, we use a small wait time (50ms) for faster test execution.
const WAIT_TIME = 50;

test("calls the function after the specified wait time", async () => {
	let callCount = 0;
	let lastArgs: any[] = [];
	function mockFn(...args: any[]) {
		callCount++;
		lastArgs = args;
	}

	const debouncedFn = debounce(mockFn, WAIT_TIME);
	debouncedFn("test");

	// Immediately after calling, the function should not be invoked.
	expect(callCount).toBe(0);

	// Wait a little longer than the debounce interval.
	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));

	expect(callCount).toBe(1);
	expect(lastArgs).toEqual(["test"]);
});

test("delays function execution if called again within wait time", async () => {
	let callCount = 0;
	let lastArgs: any[] = [];
	function mockFn(...args: any[]) {
		callCount++;
		lastArgs = args;
	}

	const debouncedFn = debounce(mockFn, WAIT_TIME);
	debouncedFn("first");

	// Wait half of the debounce time.
	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME / 2));

	// Call again before the wait period has expired.
	debouncedFn("second");

	// Wait enough time after the second call.
	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));

	// Only one call should be made with the last value.
	expect(callCount).toBe(1);
	expect(lastArgs).toEqual(["second"]);
});

test("executes only once when called multiple times rapidly", async () => {
	let callCount = 0;
	let lastArgs: any[] = [];
	function mockFn(...args: any[]) {
		callCount++;
		lastArgs = args;
	}

	const debouncedFn = debounce(mockFn, WAIT_TIME);

	// Rapidly call the debounced function several times.
	debouncedFn(1);
	debouncedFn(2);
	debouncedFn(3);

	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));

	expect(callCount).toBe(1);
	expect(lastArgs).toEqual([3]);
});

test("passes multiple arguments correctly after debouncing", async () => {
	let callCount = 0;
	let lastArgs: any[] = [];
	function mockFn(...args: any[]) {
		callCount++;
		lastArgs = args;
	}

	const debouncedFn = debounce(mockFn, WAIT_TIME);
	debouncedFn("a", "b");

	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));

	expect(callCount).toBe(1);
	expect(lastArgs).toEqual(["a", "b"]);
});

test("allows successive debounced calls after previous execution", async () => {
	let callCount = 0;
	let lastArgs: any[] = [];
	function mockFn(...args: any[]) {
		callCount++;
		lastArgs = args;
	}

	const debouncedFn = debounce(mockFn, WAIT_TIME);

	// First call.
	debouncedFn("first");
	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));
	expect(callCount).toBe(1);
	expect(lastArgs).toEqual(["first"]);

	// Second call.
	debouncedFn("second");
	await new Promise((resolve) => setTimeout(resolve, WAIT_TIME + 10));
	expect(callCount).toBe(2);
	expect(lastArgs).toEqual(["second"]);
});
