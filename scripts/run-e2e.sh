#!/usr/bin/env bash
# Playwright E2E test runner - adds NixOS library paths if needed

# On NixOS, add library paths for Chromium. On other systems, this is a no-op.
if [ -d "/nix/store" ]; then
  LIB_PATHS=$(ls -d /nix/store/*-{mesa-libgbm,nss,nspr,atk,at-spi2-atk,cups,dbus,libxkbcommon,libGL,alsa-lib,expat,libX11,libXcomposite,libXdamage,libXext,libXfixes,libXrandr,libxcb,libxshmfence,pango,cairo,glib,gdk-pixbuf,libdrm}-[0-9]* 2>/dev/null | grep -v "\.drv$" | xargs -I{} echo {}/lib | tr "\n" ":" | sed 's/:$//')
  export LD_LIBRARY_PATH="${LIB_PATHS}:${LD_LIBRARY_PATH}"
  unset PLAYWRIGHT_BROWSERS_PATH
fi

bunx playwright test --config=e2e/playwright.config.ts "$@"
