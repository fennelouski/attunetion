import { generateMonthlyIntention } from "../../lib/openai";
import { validateApiKey } from "../../lib/auth";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";
import { GenerateMonthlyIntentionRequest, GenerateMonthlyIntentionResponse } from "../../types";

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
    const body: GenerateMonthlyIntentionRequest = await request.json();
    
    if (!body.previousIntentions || !Array.isArray(body.previousIntentions) || body.previousIntentions.length === 0) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "previousIntentions array is required and must not be empty", 400),
        { status: 400 }
      );
    }

    // Validate each intention in the array
    for (const intention of body.previousIntentions) {
      if (!intention.text || typeof intention.text !== "string" || !intention.month || typeof intention.month !== "string") {
        return Response.json(
          createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Each previousIntention must have text and month fields", 400),
          { status: 400 }
        );
      }
    }

    // Generate monthly intention
    const result = await generateMonthlyIntention(body.previousIntentions);

    const response: GenerateMonthlyIntentionResponse = {
      intention: result.intention,
      reasoning: result.reasoning,
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



