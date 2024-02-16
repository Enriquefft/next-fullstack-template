/* eslint-disable jsdoc/check-tag-names */

import "./src/env.mjs";

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    typedRoutes: true,
  },
};

export default nextConfig;
