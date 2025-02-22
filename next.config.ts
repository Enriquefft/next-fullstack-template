import type { NextConfig } from "next";

import "./src/env.ts";
const nextConfig: NextConfig = {
	experimental: {
		typedRoutes: true,
	},
	transpilePackages: ["@t3-oss/env-nextjs", "@t3-oss/env-core"],
	eslint: {
		// Warning: This allows production builds to successfully complete even if
		// your project has ESLint errors.
		ignoreDuringBuilds: true,
	},
};

export default nextConfig;
