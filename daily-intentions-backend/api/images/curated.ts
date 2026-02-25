/**
 * GET /api/images/curated - list approved photos (paginated) for all authenticated users.
 * POST /api/images/curated - add a photo to curated list (admin; same API key).
 */

import { validateApiKey, getUserId } from "../../lib/auth";
import {
  getCuratedPhotos,
  addCuratedPhoto,
  getCuratedTotal,
  getCuratedPhotoByUnsplashId,
} from "../../lib/curatedPhotos";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import type { AddCuratedPhotoRequest } from "../../types";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id, X-Unsplash-Unlock-Key",
};

export default async function handler(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (request.method !== "GET" && request.method !== "POST") {
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

    if (request.method === "GET") {
      const userId = getUserId(request);
      if (!userId) {
        return Response.json(
          createErrorResponse(ErrorCodes.UNAUTHORIZED, "X-User-Id is required", 401),
          { status: 401, headers: CORS_HEADERS }
        );
      }

      const url = new URL(request.url);
      const page = Math.max(1, parseInt(url.searchParams.get("page") ?? "1", 10) || 1);
      const per_page = Math.min(50, Math.max(1, parseInt(url.searchParams.get("per_page") ?? "20", 10) || 20));
      const theme = url.searchParams.get("theme")?.trim() || undefined;

      const photos = getCuratedPhotos(page, per_page, theme ?? null);
      const total = getCuratedTotal(theme ?? null);

      return Response.json(
        {
          photos,
          total,
          page,
          per_page,
          total_pages: Math.ceil(total / per_page) || 1,
        },
        { headers: CORS_HEADERS }
      );
    }

    // POST - add curated photo (admin)
    let body: AddCuratedPhotoRequest;
    try {
      body = (await request.json()) as AddCuratedPhotoRequest;
    } catch {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Invalid JSON body", 400),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const {
      unsplash_photo_id,
      image_url,
      attribution_text,
      attribution_url,
      download_location,
    } = body;

    if (
      !unsplash_photo_id ||
      !image_url ||
      !attribution_text ||
      !attribution_url ||
      !download_location
    ) {
      return Response.json(
        createErrorResponse(
          ErrorCodes.VALIDATION_ERROR,
          "unsplash_photo_id, image_url, attribution_text, attribution_url, download_location are required",
          400
        ),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const existing = getCuratedPhotoByUnsplashId(unsplash_photo_id);
    if (existing) {
      return Response.json(
        { photo: existing, created: false },
        { status: 200, headers: CORS_HEADERS }
      );
    }

    const record = addCuratedPhoto(body);
    return Response.json(
      { photo: record, created: true },
      { status: 201, headers: CORS_HEADERS }
    );
  } catch (error) {
    return handleError(error);
  }
}
