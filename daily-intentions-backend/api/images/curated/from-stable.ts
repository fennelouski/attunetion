/**
 * POST /api/images/curated/from-stable
 * Submit photos that have been used as intention background for 7+ days without change.
 * Requires valid UNSPLASH_UNLOCK_KEY (X-Unsplash-Unlock-Key header).
 * Each photo is added to the curated list for all users; suggested_theme_name is derived from color.
 */

import { validateApiKey } from "../../../lib/auth";
import { hasValidUnlockKey } from "../../../lib/unsplash";
import {
  addCuratedPhotoWithOptionalColorFetch,
  getCuratedPhotoByUnsplashId,
} from "../../../lib/curatedPhotos";
import { handleError, ErrorCodes, createErrorResponse } from "../../../lib/errors";
import type { FromStableRequest, FromStablePhotoItem } from "../../../types";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id, X-Unsplash-Unlock-Key",
};

export default async function handler(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (request.method !== "POST") {
    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405, headers: CORS_HEADERS }
    );
  }

  try {
    if (!validateApiKey(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.UNAUTHORIZED, "Invalid API key", 401),
        { status: 401, headers: CORS_HEADERS }
      );
    }

    if (!hasValidUnlockKey(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.FORBIDDEN, "Valid Unsplash unlock key required", 403),
        { status: 403, headers: CORS_HEADERS }
      );
    }

    let body: FromStableRequest;
    try {
      body = (await request.json()) as FromStableRequest;
    } catch {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Invalid JSON body", 400),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const photos = body.photos;
    if (!Array.isArray(photos) || photos.length === 0) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "photos array is required and must not be empty", 400),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const added: FromStablePhotoItem[] = [];
    const skipped: string[] = [];

    for (const p of photos as FromStablePhotoItem[]) {
      if (
        !p.unsplash_photo_id ||
        !p.image_url ||
        !p.attribution_text ||
        !p.attribution_url ||
        !p.download_location
      ) {
        continue;
      }
      if (getCuratedPhotoByUnsplashId(p.unsplash_photo_id)) {
        skipped.push(p.unsplash_photo_id);
        continue;
      }
      await addCuratedPhotoWithOptionalColorFetch({
        unsplash_photo_id: p.unsplash_photo_id,
        image_url: p.image_url,
        attribution_text: p.attribution_text,
        attribution_url: p.attribution_url,
        download_location: p.download_location,
        color: p.color,
      });
      added.push(p);
    }

    return Response.json(
      { added: added.length, skipped: skipped.length, added_ids: added.map((x) => x.unsplash_photo_id) },
      { headers: CORS_HEADERS }
    );
  } catch (error) {
    return handleError(error);
  }
}
