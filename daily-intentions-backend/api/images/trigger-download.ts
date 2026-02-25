/**
 * Trigger Unsplash download event when user "uses" a photo (e.g. selects as theme).
 * POST body: { unsplashPhotoId, download_location }
 * Rate-limit: one trigger per photo per user per day.
 */

import { validateApiKey, getUserId } from "../../lib/auth";
import { triggerDownload } from "../../lib/unsplash";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import type { TriggerDownloadRequest } from "../../types";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
};

const DAY_MS = 24 * 60 * 60 * 1000;
// One trigger per (userId, photoId) per day
const triggerStore = new Map<string, number[]>();

function wasTriggeredRecently(userId: string, photoId: string): boolean {
  const key = `${userId}:${photoId}`;
  const now = Date.now();
  let timestamps = triggerStore.get(key) ?? [];
  timestamps = timestamps.filter((t) => now - t < DAY_MS);
  const triggered = timestamps.length > 0;
  if (!triggered) {
    timestamps.push(now);
    triggerStore.set(key, timestamps);
  }
  return triggered;
}

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

    const userId = getUserId(request);
    if (!userId) {
      return Response.json(
        createErrorResponse(ErrorCodes.UNAUTHORIZED, "X-User-Id is required", 401),
        { status: 401, headers: CORS_HEADERS }
      );
    }

    let body: TriggerDownloadRequest;
    try {
      body = (await request.json()) as TriggerDownloadRequest;
    } catch {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Invalid JSON body", 400),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const { unsplashPhotoId, download_location } = body;
    if (!unsplashPhotoId || !download_location) {
      return Response.json(
        createErrorResponse(
          ErrorCodes.VALIDATION_ERROR,
          "unsplashPhotoId and download_location are required",
          400
        ),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    if (wasTriggeredRecently(userId, unsplashPhotoId)) {
      return Response.json({ ok: true, triggered: false }, { headers: CORS_HEADERS });
    }

    await triggerDownload(download_location);

    return Response.json({ ok: true, triggered: true }, { headers: CORS_HEADERS });
  } catch (error) {
    return handleError(error);
  }
}
