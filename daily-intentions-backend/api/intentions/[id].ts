import { validateApiKey, getUserId } from "../../lib/auth";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import {
  getIntentionById,
  updateIntention,
  deleteIntention,
  belongsToUser,
} from "../../lib/db";
import { UpdateIntentionRequest } from "../../types";

export default async function handler(
  request: Request,
  context?: { params?: { id?: string } }
): Promise<Response> {
  // Handle CORS preflight
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, PUT, DELETE, OPTIONS",
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

    // Extract ID from URL path or context params
    const url = new URL(request.url);
    const pathParts = url.pathname.split("/");
    const intentionId = context?.params?.id || pathParts[pathParts.length - 1];
    
    if (!intentionId) {
      return Response.json(
        createErrorResponse(ErrorCodes.BAD_REQUEST, "Intention ID is required", 400),
        { status: 400 }
      );
    }
    const userId = getUserId(request);

    // GET: Get a single intention
    if (request.method === "GET") {
      const intention = getIntentionById(intentionId);

      if (!intention) {
        return Response.json(
          createErrorResponse(ErrorCodes.NOT_FOUND, "Intention not found", 404),
          { status: 404 }
        );
      }

      // Check ownership if userId is provided
      if (userId && intention.userId !== userId) {
        return Response.json(
          createErrorResponse(ErrorCodes.UNAUTHORIZED, "Access denied", 403),
          { status: 403 }
        );
      }

      return Response.json({ intention });
    }

    // PUT: Update an intention
    if (request.method === "PUT") {
      if (!userId) {
        return Response.json(
          createErrorResponse(ErrorCodes.BAD_REQUEST, "userId is required", 400),
          { status: 400 }
        );
      }

      if (!belongsToUser(intentionId, userId)) {
        return Response.json(
          createErrorResponse(ErrorCodes.UNAUTHORIZED, "Access denied", 403),
          { status: 403 }
        );
      }

      const body = await request.json() as UpdateIntentionRequest;

      // Validate scope if provided
      if (body.scope && !["day", "week", "month"].includes(body.scope)) {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "scope must be 'day', 'week', or 'month'", 400),
          { status: 400 }
        );
      }

      // Validate text if provided
      if (body.text !== undefined && (typeof body.text !== "string" || body.text.trim().length === 0)) {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "text must be a non-empty string", 400),
          { status: 400 }
        );
      }

      const updated = updateIntention(intentionId, {
        ...body,
        text: body.text?.trim(),
      });

      if (!updated) {
        return Response.json(
          createErrorResponse(ErrorCodes.NOT_FOUND, "Intention not found", 404),
          { status: 404 }
        );
      }

      return Response.json({ intention: updated });
    }

    // DELETE: Delete an intention
    if (request.method === "DELETE") {
      if (!userId) {
        return Response.json(
          createErrorResponse(ErrorCodes.BAD_REQUEST, "userId is required", 400),
          { status: 400 }
        );
      }

      if (!belongsToUser(intentionId, userId)) {
        return Response.json(
          createErrorResponse(ErrorCodes.UNAUTHORIZED, "Access denied", 403),
          { status: 403 }
        );
      }

      const deleted = deleteIntention(intentionId);

      if (!deleted) {
        return Response.json(
          createErrorResponse(ErrorCodes.NOT_FOUND, "Intention not found", 404),
          { status: 404 }
        );
      }

      return Response.json({ success: true }, { status: 200 });
    }

    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405 }
    );
  } catch (error) {
    return handleError(error);
  }
}

