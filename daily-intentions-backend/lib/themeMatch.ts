/**
 * Map a hex color (e.g. from Unsplash photo) to the nearest preset theme name.
 * Used so curated photos can be suggested when users pick a specific theme.
 */

// Subset of preset themes (name, backgroundColor hex) - must match app PresetThemes
const PRESET_THEMES: { name: string; hex: string }[] = [
  { name: "Serene", hex: "#F5F7FA" },
  { name: "Vibrant", hex: "#7C3AED" },
  { name: "Minimal", hex: "#FFFFFF" },
  { name: "Sunset", hex: "#C2410C" },
  { name: "Ocean", hex: "#4A90E2" },
  { name: "Forest", hex: "#047857" },
  { name: "Slate", hex: "#374151" },
  { name: "Rose", hex: "#BE185D" },
  { name: "Amber", hex: "#D97706" },
  { name: "Lavender", hex: "#A78BFA" },
  { name: "Teal", hex: "#0D9488" },
  { name: "Navy", hex: "#1E40AF" },
  { name: "Cream", hex: "#FEF3C7" },
  { name: "Indigo", hex: "#4F46E5" },
  { name: "Coral", hex: "#FB7185" },
  { name: "Moss", hex: "#65A30D" },
  { name: "Midnight", hex: "#111827" },
  { name: "Sky", hex: "#0EA5E9" },
  { name: "Plum", hex: "#6B21A8" },
  { name: "Stone", hex: "#57534E" },
  { name: "Sage", hex: "#4A7C59" },
];

function hexToRgb(hex: string): [number, number, number] {
  const h = hex.replace(/^#/, "");
  if (h.length === 6) {
    const r = parseInt(h.slice(0, 2), 16);
    const g = parseInt(h.slice(2, 4), 16);
    const b = parseInt(h.slice(4, 6), 16);
    return [r, g, b];
  }
  if (h.length === 3) {
    const r = parseInt(h[0] + h[0], 16);
    const g = parseInt(h[1] + h[1], 16);
    const b = parseInt(h[2] + h[2], 16);
    return [r, g, b];
  }
  return [128, 128, 128];
}

function colorDistance(hexA: string, hexB: string): number {
  const [r1, g1, b1] = hexToRgb(hexA);
  const [r2, g2, b2] = hexToRgb(hexB);
  return Math.sqrt((r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2);
}

/**
 * Return the preset theme name whose background color is closest to the given hex.
 */
export function nearestPresetThemeName(hexColor: string | undefined | null): string | null {
  if (!hexColor || typeof hexColor !== "string") return null;
  const normalized = hexColor.trim().startsWith("#") ? hexColor.trim() : `#${hexColor.trim()}`;
  if (normalized.length < 3) return null;

  let best: { name: string; dist: number } | null = null;
  for (const theme of PRESET_THEMES) {
    const dist = colorDistance(normalized, theme.hex);
    if (best === null || dist < best.dist) {
      best = { name: theme.name, dist };
    }
  }
  return best?.name ?? null;
}
