import { pgTableCreator } from "drizzle-orm/pg-core";
import { env } from "@/env.mjs";

export const createTable = pgTableCreator(
  (name) => `${env.NEXT_PUBLIC_PROJECT_NAME}_${name}`,
);
