/**
 * In-memory store for curated Unsplash photos (approved for all users).
 * In production, replace with Vercel Postgres or similar.
 */

import type { CuratedPhotoRecord, AddCuratedPhotoRequest } from "../types/index.js";
import { nearestPresetThemeName } from "./themeMatch.js";
import { getPhotoById } from "./unsplash.js";

const curatedStore = new Map<string, CuratedPhotoRecord>();

export function getCuratedPhotos(page = 1, perPage = 20, themeName?: string | null): CuratedPhotoRecord[] {
  let all = Array.from(curatedStore.values()).sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  );
  if (themeName != null && themeName !== "") {
    all = all.filter((p) => (p.suggested_theme_name ?? "").toLowerCase() === themeName.toLowerCase());
  }
  const start = (page - 1) * perPage;
  return all.slice(start, start + perPage);
}

export function getCuratedPhotoByUnsplashId(unsplashPhotoId: string): CuratedPhotoRecord | undefined {
  return Array.from(curatedStore.values()).find((p) => p.unsplash_photo_id === unsplashPhotoId);
}

export function addCuratedPhoto(data: AddCuratedPhotoRequest): CuratedPhotoRecord {
  const now = new Date().toISOString();
  const suggested_theme_name = data.color ? nearestPresetThemeName(data.color) : null;
  const record: CuratedPhotoRecord = {
    id: crypto.randomUUID(),
    unsplash_photo_id: data.unsplash_photo_id,
    image_url: data.image_url,
    attribution_text: data.attribution_text,
    attribution_url: data.attribution_url,
    download_location: data.download_location,
    approved_at: now,
    created_at: now,
    suggested_theme_name: suggested_theme_name ?? undefined,
  };
  curatedStore.set(record.id, record);
  return record;
}

/**
 * Add to curated; if color is missing, fetch from Unsplash API to derive suggested_theme_name.
 */
export async function addCuratedPhotoWithOptionalColorFetch(
  data: AddCuratedPhotoRequest
): Promise<CuratedPhotoRecord> {
  let color = data.color;
  if (!color && data.unsplash_photo_id) {
    const photo = await getPhotoById(data.unsplash_photo_id);
    color = photo?.color;
  }
  return addCuratedPhoto({ ...data, color });
}

export function getCuratedTotal(themeName?: string | null): number {
  if (themeName == null || themeName === "") return curatedStore.size;
  return Array.from(curatedStore.values()).filter(
    (p) => (p.suggested_theme_name ?? "").toLowerCase() === themeName.toLowerCase()
  ).length;
}
