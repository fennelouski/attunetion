import { readJsonObject, validateAIRequest } from "../../lib/validation.js";
import { generateTheme } from "../../lib/openai.js";
import { validateApiKey } from "../../lib/auth.js";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit.js";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors.js";
import { GenerateThemeRequest, ThemeResponse } from "../../types/index.js";

export default {
  async fetch(request: Request): Promise<Response> {
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

    // Parse request body
    const rawBody = await readJsonObject(request);
    validateAIRequest("generate-theme", rawBody);
    const body = rawBody as unknown as GenerateThemeRequest;

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


    
    if (!body.intentionText || typeof body.intentionText !== "string" || body.intentionText.trim().length === 0) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "intentionText is required", 400),
        { status: 400 }
      );
    }

    // Generate theme
    const theme = await generateTheme(body.intentionText.trim());

    const response: ThemeResponse = {
      theme,
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
  },
};

