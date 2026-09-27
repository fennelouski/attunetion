import { readJsonObject, validateAIRequest } from "../../lib/validation.js";
import { generateQuote } from "../../lib/openai.js";
import { validateApiKey } from "../../lib/auth.js";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit.js";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors.js";
import { GenerateQuoteRequest, QuoteResponse } from "../../types/index.js";

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
    validateAIRequest("generate-quote", rawBody);
    const body = rawBody as unknown as GenerateQuoteRequest;

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

    // Generate quote
    const quote = await generateQuote(body.intentionText.trim());

    const response: QuoteResponse = {
      quote: quote.quote,
      author: quote.author,
      relevance: quote.relevance,
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

