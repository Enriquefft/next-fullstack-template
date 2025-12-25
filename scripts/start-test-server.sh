#!/bin/bash
#
# Start Next.js dev server for E2E tests with proper environment variables
#

set -e  # Exit on error

# On NixOS, add library paths for Next.js native modules
if [ -d "/nix/store" ]; then
  LIB_PATHS=$(ls -d /nix/store/*-gcc-*-lib/lib 2>/dev/null | tr "\n" ":" | sed 's/:$//')
  if [ -n "$LIB_PATHS" ]; then
    export LD_LIBRARY_PATH="${LIB_PATHS}:${LD_LIBRARY_PATH}"
  fi
fi

# Export all test environment variables
export NODE_ENV=test
export PORT="${PORT:-3000}"

# Required for E2E tests - validate and export
export DATABASE_URL_TEST="${DATABASE_URL_TEST:?DATABASE_URL_TEST is required}"
export GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:?GOOGLE_CLIENT_ID is required}"
export GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:?GOOGLE_CLIENT_SECRET is required}"
export BETTER_AUTH_SECRET="${BETTER_AUTH_SECRET:?BETTER_AUTH_SECRET is required}"
export NEXT_PUBLIC_PROJECT_NAME="${NEXT_PUBLIC_PROJECT_NAME:?NEXT_PUBLIC_PROJECT_NAME is required}"
export POLAR_ACCESS_TOKEN="${POLAR_ACCESS_TOKEN:?POLAR_ACCESS_TOKEN is required}"
export UPLOADTHING_TOKEN="${UPLOADTHING_TOKEN:?UPLOADTHING_TOKEN is required}"

# Optional with defaults
export POLAR_MODE="${POLAR_MODE:-sandbox}"
export NEXT_PUBLIC_POSTHOG_KEY="${NEXT_PUBLIC_POSTHOG_KEY:-}"

# Start Next.js dev server (use bunx to run locally installed next)
exec bunx --bun next dev --turbopack
