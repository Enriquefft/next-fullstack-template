import { clientEnv } from "./client.ts";
import { dbEnv } from "./db.ts";
import { serverEnv } from "./server.ts";

export { clientEnv } from "./client.ts";
export { dbEnv } from "./db.ts";
export { serverEnv } from "./server.ts";

export const env = {
	...clientEnv,
	...dbEnv,
	...serverEnv,
};
