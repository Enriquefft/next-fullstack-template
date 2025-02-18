import { Button } from "@/components/ui/button";
import { expect, test } from "@jest/globals";

import { render, screen } from "@testing-library/react";

test("uses jest-dom", () => {
	render(<Button>Visible Example</Button>);

	expect(screen.getByText("Visible Example")).toBeInTheDocument();

	expect(screen.getByRole("button")).toHaveTextContent("Visible Example");
});
