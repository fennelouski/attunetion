import { rephraseIntention } from "../../lib/openai";
import { validateApiKey } from "../../lib/auth";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import { RephraseIntentionRequest, RephraseIntentionResponse } from "../../types";

export default async function handler(request: Request): Promise<Response> {
  // Handle CORS preflight
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
      },
    });
  }

  if (request.method !== "POST") {
    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405 }
    );
  }

  try {
    // Authentication
    if (!validateApiKey(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.UNAUTHORIZED, "Invalid API key", 401),
        { status: 401 }
      );
    }

    // Rate limiting
    const identifier = getRateLimitIdentifier(request);
    const rateLimit = checkRateLimit(identifier);
    
    if (!rateLimit.allowed) {
      return Response.json(
        createErrorResponse(
          ErrorCodes.RATE_LIMIT_EXCEEDED,
          `Too many requests. Try again in ${Math.ceil((rateLimit.resetAt - Date.now()) / 60000)} minutes.`,
          429
        ),
        {
          status: 429,
          headers: {
            "X-RateLimit-Limit": "50",
            "X-RateLimit-Remaining": "0",
            "X-RateLimit-Reset": rateLimit.resetAt.toString(),
          },
        }
      );
    }

    // Parse request body
    const body: RephraseIntentionRequest = await request.json();
    
    if (!body.intentionText || typeof body.intentionText !== "string" || body.intentionText.trim().length === 0) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "intentionText is required", 400),
        { status: 400 }
      );
    }

    // Validate previousPhrases if provided
    if (body.previousPhrases && !Array.isArray(body.previousPhrases)) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "previousPhrases must be an array", 400),
        { status: 400 }
      );
    }

    // Rephrase intention
    const result = await rephraseIntention(
      body.intentionText.trim(),
      body.previousPhrases || []
    );

    const response: RephraseIntentionResponse = {
      rephrasedText: result.rephrasedText,
      preservedMeaning: result.preservedMeaning,
    };

    return Response.json(response, {
      headers: {
        "X-RateLimit-Limit": "50",
        "X-RateLimit-Remaining": rateLimit.remaining.toString(),
        "X-RateLimit-Reset": rateLimit.resetAt.toString(),
      },
    });
  } catch (error) {
    return handleError(error);
  }
}



