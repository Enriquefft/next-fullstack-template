import { expect, test } from "@jest/globals";
import { Button } from "@/components/button";

import { render, screen } from "@testing-library/react";

test("uses jest-dom", () => {
  render(<Button>Visible Example</Button>);

  expect(screen.getByText("Visible Example")).toBeInTheDocument();

  expect(screen.getByRole("button")).toHaveTextContent("Visible Example");
});
