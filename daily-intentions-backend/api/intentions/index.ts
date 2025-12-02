import { validateApiKey, getUserId } from "../../lib/auth";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import { getIntentionsByUserId, createIntention } from "../../lib/db";
import { CreateIntentionRequest, Intention } from "../../types";

export default async function handler(request: Request): Promise<Response> {
  // Handle CORS preflight
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
      },
    });
  }

  try {
    // Authentication
    if (!validateApiKey(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.UNAUTHORIZED, "Invalid API key", 401),
        { status: 401 }
      );
    }

    // GET: List all intentions for a user
    if (request.method === "GET") {
      const url = new URL(request.url);
      const userId = url.searchParams.get("userId") || getUserId(request);

      if (!userId) {
        return Response.json(
          createErrorResponse(ErrorCodes.BAD_REQUEST, "userId is required", 400),
          { status: 400 }
        );
      }

      const intentions = getIntentionsByUserId(userId);
      return Response.json({ intentions });
    }

    // POST: Create a new intention
    if (request.method === "POST") {
      const body: CreateIntentionRequest = await request.json();

      // Validation
      if (!body.userId || typeof body.userId !== "string") {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "userId is required", 400),
          { status: 400 }
        );
      }

      if (!body.text || typeof body.text !== "string" || body.text.trim().length === 0) {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "text is required", 400),
          { status: 400 }
        );
      }

      if (!body.scope || !["day", "week", "month"].includes(body.scope)) {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "scope must be 'day', 'week', or 'month'", 400),
          { status: 400 }
        );
      }

      if (!body.date || typeof body.date !== "string") {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "date is required (ISO string)", 400),
          { status: 400 }
        );
      }

      const intention = createIntention({
        userId: body.userId,
        text: body.text.trim(),
        scope: body.scope,
        date: body.date,
        themeId: body.themeId,
        customFont: body.customFont,
        aiGenerated: body.aiGenerated,
        quote: body.quote,
      });

      return Response.json({ intention }, { status: 201 });
    }

    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405 }
    );
  } catch (error) {
    return handleError(error);
  }
}

