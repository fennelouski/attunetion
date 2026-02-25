/**
 * Unsplash API helpers and privileged-user check
 */

import { getUserId } from "./auth";

const UNSPLASH_API_BASE = "https://api.unsplash.com";

const UNSPLASH_UNLOCK_KEY_HEADER = "X-Unsplash-Unlock-Key";

/**
 * Parse UNSPLASH_PRIVILEGED_USER_IDS env (comma-separated list).
 * If not set, no users have unfettered search access.
 */
export function getPrivilegedUserIds(): Set<string> {
  const raw = process.env.UNSPLASH_PRIVILEGED_USER_IDS;
  if (!raw || typeof raw !== "string") return new Set();
  return new Set(
    raw
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean)
  );
}

/**
 * Check if request has a valid Unsplash unlock key (entered in app).
 * When valid, user gets unlimited Unsplash access and can submit stable photos to curated.
 */
export function hasValidUnlockKey(request: Request): boolean {
  const key = request.headers.get(UNSPLASH_UNLOCK_KEY_HEADER)?.trim();
  const expected = process.env.UNSPLASH_UNLOCK_KEY?.trim();
  if (!expected || !key) return false;
  return key === expected;
}

/**
 * User can search Unsplash if they are in privileged list OR have valid unlock key.
 */
export function canSearchUnsplash(request: Request): boolean {
  if (hasValidUnlockKey(request)) return true;
  return isPrivilegedUser(request);
}

/**
 * User has unlimited Unsplash themes (no 5-theme limit) when they have valid unlock key.
 */
export function hasUnlimitedUnsplashThemes(request: Request): boolean {
  return hasValidUnlockKey(request);
}

export function isPrivilegedUser(request: Request): boolean {
  const userId = getUserId(request);
  if (!userId) return false;
  return getPrivilegedUserIds().has(userId);
}

/**
 * Call Unsplash search/photos. Requires UNSPLASH_ACCESS_KEY.
 */
export async function searchPhotos(params: {
  query: string;
  page?: number;
  per_page?: number;
}): Promise<{ total: number; total_pages: number; results: unknown[] }> {
  const key = process.env.UNSPLASH_ACCESS_KEY;
  if (!key) {
    throw new Error("UNSPLASH_ACCESS_KEY is not set");
  }

  const url = new URL(`${UNSPLASH_API_BASE}/search/photos`);
  url.searchParams.set("query", params.query);
  url.searchParams.set("page", String(params.page ?? 1));
  url.searchParams.set("per_page", String(params.per_page ?? 10));

  const res = await fetch(url.toString(), {
    headers: {
      Authorization: `Client-ID ${key}`,
      "Accept-Version": "v1",
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Unsplash API error: ${res.status} ${text}`);
  }

  const data = (await res.json()) as {
    total: number;
    total_pages: number;
    results: Array<{
      id: string;
      urls: { raw?: string; full?: string; regular: string; small: string; thumb: string };
      links: { download_location?: string; download?: string; html: string };
      user: { name: string; username: string; links?: { html: string } };
    }>;
  };

  const results = (data.results ?? []).map((p) => ({
    id: p.id,
    urls: p.urls,
    links: {
      download_location: p.links?.download_location ?? p.links?.download ?? "",
      html: p.links?.html ?? `https://unsplash.com/photos/${p.id}`,
    },
    user: p.user,
    attributionText: `Photo by ${p.user?.name ?? "Unknown"} on Unsplash`,
    attributionUrl: p.links?.html ?? `https://unsplash.com/photos/${p.id}`,
  }));

  return {
    total: data.total ?? 0,
    total_pages: data.total_pages ?? 0,
    results,
  };
}

/**
 * Trigger Unsplash download event (required by API guidelines when user "uses" a photo).
 * Call the download_location URL with client_id.
 */
export async function triggerDownload(downloadLocationUrl: string): Promise<void> {
  const key = process.env.UNSPLASH_ACCESS_KEY;
  if (!key) return;

  const url = new URL(downloadLocationUrl);
  url.searchParams.set("client_id", key);

  await fetch(url.toString(), { method: "GET" });
}

/**
 * Fetch a single photo by id from Unsplash (for proxy cache miss).
 * Returns urls.regular for image bytes, links.download_location, and color hex.
 */
export async function getPhotoById(id: string): Promise<{
  imageUrl: string;
  download_location: string;
  color?: string;
} | null> {
  const key = process.env.UNSPLASH_ACCESS_KEY;
  if (!key) return null;

  const res = await fetch(`${UNSPLASH_API_BASE}/photos/${id}`, {
    headers: {
      Authorization: `Client-ID ${key}`,
      "Accept-Version": "v1",
    },
  });

  if (!res.ok) return null;

  const data = (await res.json()) as {
    urls?: { regular?: string };
    links?: { download_location?: string; download?: string };
    color?: string;
  };

  const imageUrl = data.urls?.regular ?? "";
  const download_location =
    data.links?.download_location ?? data.links?.download ?? "";

  if (!imageUrl) return null;

  return {
    imageUrl,
    download_location,
    color: data.color ?? undefined,
  };
}
