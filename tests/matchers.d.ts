import { TestingLibraryMatchers } from "@testing-library/jest-dom/matchers";
import type { Matchers, AsymmetricMatchers } from "bun:test";

declare module "bun:test" {
    interface Matchers<T>
        extends TestingLibraryMatchers<typeof expect.stringContaining, T> { }
    interface AsymmetricMatchers extends TestingLibraryMatchers { }
}
