/**
 * Color Conversion Utility: Hex ↔ OKLCH
 *
 * Implements pure mathematical conversions for OKLCH color space.
 * No external dependencies - follows CSS Color Module Level 4 specification.
 *
 * OKLCH is a perceptually uniform color space based on OKLab.
 * Format: oklch(L C H) where:
 * - L (Lightness): 0-1 (0 = black, 1 = white)
 * - C (Chroma): 0-0.4+ (saturation, unbounded but typically 0-0.4)
 * - H (Hue): 0-360 degrees
 */

/**
 * Convert hex color to OKLCH
 * @param hex - Hex color string (e.g., "#2563EB" or "2563EB")
 * @returns OKLCH values as {l, c, h} or null if invalid
 */
export function hexToOklch(
    hex: string,
): { l: number; c: number; h: number } | null {
    // Remove # if present
    const cleanHex = hex.replace(/^#/, "");

    // Validate hex format
    if (!/^[0-9A-Fa-f]{6}$/.test(cleanHex)) {
        return null;
    }

    // Parse RGB values (0-255)
    const r = Number.parseInt(cleanHex.slice(0, 2), 16) / 255;
    const g = Number.parseInt(cleanHex.slice(2, 4), 16) / 255;
    const b = Number.parseInt(cleanHex.slice(4, 6), 16) / 255;

    // Convert to linear RGB (gamma correction)
    const lr = srgbToLinear(r);
    const lg = srgbToLinear(g);
    const lb = srgbToLinear(b);

    // Convert linear RGB to OKLab
    const l_ = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb;
    const m_ = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb;
    const s_ = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb;

    const l = Math.cbrt(l_);
    const m = Math.cbrt(m_);
    const s = Math.cbrt(s_);

    const L = 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s;
    const a = 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s;
    const b_ = 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s;

    // Convert OKLab to OKLCH (cartesian to polar)
    const C = Math.sqrt(a * a + b_ * b_);
    let H = (Math.atan2(b_, a) * 180) / Math.PI;

    // Normalize hue to 0-360
    if (H < 0) H += 360;

    return {
        c: Number(C.toFixed(3)),
        h: Number(H.toFixed(1)),
        l: Number(L.toFixed(3)),
    };
}

/**
 * Convert OKLCH to hex color
 * @param l - Lightness (0-1)
 * @param c - Chroma (0-0.4+)
 * @param h - Hue (0-360 degrees)
 * @returns Hex color string (e.g., "#2563EB") or null if out of sRGB gamut
 */
export function oklchToHex(l: number, c: number, h: number): string | null {
    // Convert OKLCH to OKLab (polar to cartesian)
    const a = c * Math.cos((h * Math.PI) / 180);
    const b = c * Math.sin((h * Math.PI) / 180);

    // Convert OKLab to linear RGB
    const l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    const m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    const s_ = l - 0.0894841775 * a - 1.291485548 * b;

    const l_cubed = l_ * l_ * l_;
    const m_cubed = m_ * m_ * m_;
    const s_cubed = s_ * s_ * s_;

    const lr =
        +4.0767416621 * l_cubed - 3.3077115913 * m_cubed + 0.2309699292 * s_cubed;
    const lg =
        -1.2684380046 * l_cubed + 2.6097574011 * m_cubed - 0.3413193965 * s_cubed;
    const lb =
        -0.0041960863 * l_cubed - 0.7034186147 * m_cubed + 1.707614701 * s_cubed;

    // Convert linear RGB to sRGB
    const r = linearToSrgb(lr);
    const g = linearToSrgb(lg);
    const b_ = linearToSrgb(lb);

    // Check if color is in sRGB gamut
    if (r < 0 || r > 1 || g < 0 || g > 1 || b_ < 0 || b_ > 1) {
        return null; // Out of gamut
    }

    // Convert to 8-bit RGB and format as hex
    const rHex = Math.round(r * 255)
        .toString(16)
        .padStart(2, "0");
    const gHex = Math.round(g * 255)
        .toString(16)
        .padStart(2, "0");
    const bHex = Math.round(b_ * 255)
        .toString(16)
        .padStart(2, "0");

    return `#${rHex}${gHex}${bHex}`.toUpperCase();
}

/**
 * Format OKLCH values for CSS
 * @param l - Lightness (0-1)
 * @param c - Chroma (0-0.4+)
 * @param h - Hue (0-360 degrees)
 * @returns CSS variable format (e.g., "0.55 0.24 264")
 */
export function formatOklchForCss(l: number, c: number, h: number): string {
    return `${l.toFixed(3)} ${c.toFixed(3)} ${h.toFixed(1)}`;
}

/**
 * Parse OKLCH string from CSS
 * @param oklchString - OKLCH string (e.g., "0.55 0.24 264" or "oklch(0.55 0.24 264)")
 * @returns OKLCH values as {l, c, h} or null if invalid
 */
export function parseOklchFromCss(
    oklchString: string,
): { l: number; c: number; h: number } | null {
    // Remove "oklch(" wrapper if present
    const cleaned = oklchString
        .replace(/^oklch\(/, "")
        .replace(/\)$/, "")
        .trim();

    // Split by whitespace
    const parts = cleaned.split(/\s+/);

    if (parts.length !== 3) {
        return null;
    }

    const l = Number.parseFloat(parts[0]);
    const c = Number.parseFloat(parts[1]);
    const h = Number.parseFloat(parts[2]);

    if (Number.isNaN(l) || Number.isNaN(c) || Number.isNaN(h)) {
        return null;
    }

    return { l, c, h };
}

/**
 * Calculate WCAG 2.1 contrast ratio between two colors
 * @param hex1 - First hex color
 * @param hex2 - Second hex color
 * @returns Contrast ratio (1-21) or null if invalid colors
 */
export function getContrastRatio(hex1: string, hex2: string): number | null {
    const lum1 = getRelativeLuminance(hex1);
    const lum2 = getRelativeLuminance(hex2);

    if (lum1 === null || lum2 === null) {
        return null;
    }

    const lighter = Math.max(lum1, lum2);
    const darker = Math.min(lum1, lum2);

    return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Check if contrast ratio meets WCAG AA standard
 * @param hex1 - Foreground color
 * @param hex2 - Background color
 * @param level - 'AA' or 'AAA'
 * @param fontSize - Font size in pixels (affects requirements)
 * @returns true if contrast is sufficient
 */
export function meetsWcagContrast(
    hex1: string,
    hex2: string,
    level: "AA" | "AAA" = "AA",
    fontSize = 16,
): boolean {
    const ratio = getContrastRatio(hex1, hex2);

    if (ratio === null) {
        return false;
    }

    // Large text (18pt+ or 14pt+ bold) has lower requirements
    const isLargeText = fontSize >= 24 || fontSize >= 19; // 18pt ≈ 24px, 14pt ≈ 19px

    if (level === "AAA") {
        return isLargeText ? ratio >= 4.5 : ratio >= 7;
    }

    // AA level
    return isLargeText ? ratio >= 3 : ratio >= 4.5;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Convert sRGB component to linear RGB (gamma correction)
 */
function srgbToLinear(c: number): number {
    return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

/**
 * Convert linear RGB to sRGB (inverse gamma correction)
 */
function linearToSrgb(c: number): number {
    return c <= 0.0031308 ? c * 12.92 : 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
}

/**
 * Calculate relative luminance for WCAG contrast
 */
function getRelativeLuminance(hex: string): number | null {
    const cleanHex = hex.replace(/^#/, "");

    if (!/^[0-9A-Fa-f]{6}$/.test(cleanHex)) {
        return null;
    }

    const r = Number.parseInt(cleanHex.slice(0, 2), 16) / 255;
    const g = Number.parseInt(cleanHex.slice(2, 4), 16) / 255;
    const b = Number.parseInt(cleanHex.slice(4, 6), 16) / 255;

    const lr = srgbToLinear(r);
    const lg = srgbToLinear(g);
    const lb = srgbToLinear(b);

    return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
}

// ============================================================================
// CLI Support (when run directly via bun/node)
// ============================================================================

if (import.meta.main) {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        console.error("Usage: bun run color-conversion.ts <hex>");
        console.error("Example: bun run color-conversion.ts #2563EB");
        process.exit(1);
    }

    const hex = args[0];
    const oklch = hexToOklch(hex);

    if (!oklch) {
        console.error(`Invalid hex color: ${hex}`);
        process.exit(1);
    }

    // Output for bash consumption
    console.log(formatOklchForCss(oklch.l, oklch.c, oklch.h));
}
