import { expect, test } from "bun:test";
import { render, screen } from "@testing-library/react";
import { Button } from "@/components/ui/button";

test("uses jest-dom", () => {
	render(<Button>Visible Example</Button>);

	expect(screen.getByText("Visible Example")).toBeInTheDocument();

	expect(screen.getByRole("button")).toHaveTextContent("Visible Example");
});
