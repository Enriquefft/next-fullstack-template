#!/bin/bash
#
# Start Next.js dev server for E2E tests with proper environment variables
#

# Export all test environment variables
export NODE_ENV=test
export PORT="${PORT:-3000}"

# Required for E2E tests - these should be set by CI or local .env
: "${DATABASE_URL_TEST:?DATABASE_URL_TEST is required}"
: "${GOOGLE_CLIENT_ID:?GOOGLE_CLIENT_ID is required}"
: "${GOOGLE_CLIENT_SECRET:?GOOGLE_CLIENT_SECRET is required}"
: "${BETTER_AUTH_SECRET:?BETTER_AUTH_SECRET is required}"
: "${NEXT_PUBLIC_PROJECT_NAME:?NEXT_PUBLIC_PROJECT_NAME is required}"
: "${POLAR_ACCESS_TOKEN:?POLAR_ACCESS_TOKEN is required}"
: "${UPLOADTHING_TOKEN:?UPLOADTHING_TOKEN is required}"

# Optional with defaults
export POLAR_MODE="${POLAR_MODE:-sandbox}"
export NEXT_PUBLIC_POSTHOG_KEY="${NEXT_PUBLIC_POSTHOG_KEY:-}"

# Start Next.js dev server
exec next dev --turbopack
