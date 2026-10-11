import { validateApiKey, getUserId } from "../../lib/auth.js";
import { canSearchUnsplash, hasValidUnlockKey, searchPhotos } from "../../lib/unsplash.js";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit.js";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors.js";
import type { UnsplashSearchResponse } from "../../types/index.js";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
};

// Optional: cap search requests per privileged user per day (e.g. 20)
const UNSPLASH_SEARCH_MAX_PER_DAY = 20;
const DAY_MS = 24 * 60 * 60 * 1000;
const searchCountStore = new Map<string, number[]>();

function checkSearchRateLimit(userId: string): { allowed: boolean } {
  const now = Date.now();
  let timestamps = searchCountStore.get(userId) ?? [];
  timestamps = timestamps.filter((t) => now - t < DAY_MS);
  if (timestamps.length >= UNSPLASH_SEARCH_MAX_PER_DAY) {
    return { allowed: false };
  }
  timestamps.push(now);
  searchCountStore.set(userId, timestamps);
  return { allowed: true };
}

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

    if (!canSearchUnsplash(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.FORBIDDEN, "Unsplash search is not available for this account", 403),
        { status: 403, headers: CORS_HEADERS }
      );
    }

    // Users with valid unlock key skip daily search rate limit
    const searchLimit = hasValidUnlockKey(request) ? { allowed: true as const } : checkSearchRateLimit(userId);
    if (!searchLimit.allowed) {
      return Response.json(
        createErrorResponse(
          ErrorCodes.RATE_LIMIT_EXCEEDED,
          "Daily Unsplash search limit reached. Try again tomorrow.",
          429
        ),
        { status: 429, headers: CORS_HEADERS }
      );
    }

    const url = new URL(request.url);
    const q = url.searchParams.get("q")?.trim();
    const page = Math.max(1, parseInt(url.searchParams.get("page") ?? "1", 10) || 1);
    const per_page = Math.min(30, Math.max(1, parseInt(url.searchParams.get("per_page") ?? "10", 10) || 10));

    if (!q || q.length === 0) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Query parameter 'q' is required", 400),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    if (!process.env.UNSPLASH_ACCESS_KEY) {
      return Response.json(
        createErrorResponse(ErrorCodes.INTERNAL_ERROR, "Unsplash is not configured", 500),
        { status: 500, headers: CORS_HEADERS }
      );
    }

    const data = await searchPhotos({ query: q, page, per_page });

    const response: UnsplashSearchResponse = {
      total: data.total,
      total_pages: data.total_pages,
      results: data.results as UnsplashSearchResponse["results"],
    };

    return Response.json(response, { headers: CORS_HEADERS });
  } catch (error) {
    return handleError(error);
  }
}

export default { fetch: handler };
