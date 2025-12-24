import type { WithContext } from "./base";
import { withContext } from "./base";

/**
 * FAQPage Schema
 * CRITICAL for GEO - ChatGPT and AI search engines love FAQs
 * Increases visibility in AI-generated answers
 */
export type FAQPage = {
	"@type": "FAQPage";
	mainEntity: Question[];
};

export type Question = {
	"@type": "Question";
	name: string;
	acceptedAnswer: Answer;
};

export type Answer = {
	"@type": "Answer";
	text: string;
};

/**
 * Generate FAQPage schema
 *
 * @example
 * ```tsx
 * const faqSchema = generateFAQSchema([
 *   {
 *     question: "What is your return policy?",
 *     answer: "You can return items within 30 days of purchase for a full refund.",
 *   },
 *   {
 *     question: "Do you ship internationally?",
 *     answer: "Yes, we ship to over 100 countries worldwide.",
 *   },
 * ]);
 * ```
 */
export function generateFAQSchema(
	items: Array<{ question: string; answer: string }>,
): WithContext<FAQPage> {
	const mainEntity: Question[] = items.map((item) => ({
		"@type": "Question",
		acceptedAnswer: {
			"@type": "Answer",
			text: item.answer,
		},
		name: item.question,
	}));

	return withContext({
		"@type": "FAQPage",
		mainEntity,
	});
}
