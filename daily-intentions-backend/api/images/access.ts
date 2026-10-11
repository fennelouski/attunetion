/**
 * GET /api/images/access
 * Returns whether the current request has Unsplash search access and/or unlimited themes.
 * Client sends X-API-Key, X-User-Id, and optionally X-Unsplash-Unlock-Key.
 */

import { validateApiKey, getUserId } from "../../lib/auth.js";
import { canSearchUnsplash, hasUnlimitedUnsplashThemes } from "../../lib/unsplash.js";
import { createErrorResponse, ErrorCodes } from "../../lib/errors.js";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id, X-Unsplash-Unlock-Key",
};

async function handler(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (request.method !== "GET") {
    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405, headers: CORS_HEADERS }
    );
  }

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

  const canSearch = canSearchUnsplash(request);
  const unlimitedThemes = hasUnlimitedUnsplashThemes(request);

  return Response.json(
    { canSearch, unlimitedThemes },
    { headers: CORS_HEADERS }
  );
}

export default { fetch: handler };
