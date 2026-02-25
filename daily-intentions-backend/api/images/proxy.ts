/**
 * Image proxy: serve Unsplash photo by id, with optional Vercel Blob cache.
 * GET /api/images/proxy?id=PHOTO_ID
 * If blob cache exists, redirect to blob URL. Else fetch from Unsplash, store in blob, redirect.
 * If Vercel Blob is not configured, redirect to Unsplash image URL directly.
 */

import { put, list } from "@vercel/blob";
import { getPhotoById } from "../../lib/unsplash";
import { createErrorResponse, ErrorCodes } from "../../lib/errors";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
};

export default async function handler(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (request.method !== "GET") {
    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405, headers: CORS_HEADERS }
    );
  }

  const url = new URL(request.url);
  const id = url.searchParams.get("id")?.trim();

  if (!id) {
    return Response.json(
      createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Query parameter 'id' is required", 400),
      { status: 400, headers: CORS_HEADERS }
    );
  }

  const blobPath = `unsplash/${id}.jpg`;

  try {
    // If Vercel Blob is configured, check cache first
    if (process.env.BLOB_READ_WRITE_TOKEN) {
      try {
        const { blobs } = await list({ prefix: blobPath, limit: 1 });
        if (blobs.length > 0 && blobs[0].url) {
          return Response.redirect(blobs[0].url, 302);
        }
      } catch {
        // list may throw; continue to fetch from Unsplash
      }

      const photo = await getPhotoById(id);
      if (!photo) {
        return Response.json(
          createErrorResponse(ErrorCodes.NOT_FOUND, "Photo not found", 404),
          { status: 404, headers: CORS_HEADERS }
        );
      }

      const imageRes = await fetch(photo.imageUrl);
      if (!imageRes.ok) {
        return Response.json(
          createErrorResponse(ErrorCodes.INTERNAL_ERROR, "Failed to fetch image", 502),
          { status: 502, headers: CORS_HEADERS }
        );
      }

      const body = await imageRes.arrayBuffer();
      const blob = await put(blobPath, body, {
        access: "public",
        contentType: imageRes.headers.get("content-type") || "image/jpeg",
      });

      return Response.redirect(blob.url, 302);
    }

    // No blob: redirect directly to Unsplash (no server-side cache)
    const photo = await getPhotoById(id);
    if (!photo) {
      return Response.json(
        createErrorResponse(ErrorCodes.NOT_FOUND, "Photo not found", 404),
        { status: 404, headers: CORS_HEADERS }
      );
    }

    return Response.redirect(photo.imageUrl, 302);
  } catch (error) {
    console.error("Image proxy error:", error);
    return Response.json(
      createErrorResponse(ErrorCodes.INTERNAL_ERROR, "Failed to serve image", 500),
      { status: 500, headers: CORS_HEADERS }
    );
  }
}
