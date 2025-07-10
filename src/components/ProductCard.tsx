"use client";
import type { Product } from "@polar-sh/sdk/models/components/product.js";
import { useMemo } from "react";
import { checkout } from "@/lib/auth-client";
import { Button } from "./ui/button";

interface ProductCardProps {
	product: Product;
}

export const ProductCard = ({ product }: ProductCardProps) => {
	// Handling just a single price for now
	// Remember to handle multiple prices for products if you support monthly & yearly pricing plans
	const firstPrice = product.prices[0];

	const price = useMemo(() => {
		switch (firstPrice?.amountType) {
			case "fixed":
				// The Polar API returns prices in cents - Convert to dollars for display
				return `$${firstPrice.priceAmount / 100}`;
			case "free":
				return "Free";
			default:
				return "Pay what you want";
		}
	}, [firstPrice]);

	return (
		<div className="flex flex-col gap-y-24 justify-between p-12 rounded-3xl bg-neutral-950 h-full border border-neutral-900">
			<div className="flex flex-col gap-y-8">
				<h1 className="text-3xl">{product.name}</h1>
				<p className="text-neutral-400">{product.description}</p>
				<ul>
					{product.benefits.map((benefit) => (
						<li key={benefit.id} className="flex flex-row gap-x-2 items-center">
							{benefit.description}
						</li>
					))}
				</ul>
			</div>
			<div className="flex flex-row gap-x-4 justify-between items-center">
				<Button
					className="h-8 flex flex-row items-center justify-center rounded-full bg-white text-black font-medium px-4"
					onClick={() => checkout({ products: [product.id] })}
				>
					Buy
				</Button>
				<span className="text-neutral-500">{price}</span>
			</div>
		</div>
	);
};
