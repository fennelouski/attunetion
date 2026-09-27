import { RequestValidationError } from "./validation.js";
import { ApiError } from "../types/index.js";

/**
 * Create a standardized API error response
 */
export function createErrorResponse(
  code: string,
  message: string,
  statusCode: number
): ApiError {
  return {
    error: {
      code,
      message,
      statusCode,
    },
  };
}

/**
 * Common error codes
 */
export const ErrorCodes = {
  RATE_LIMIT_EXCEEDED: "RATE_LIMIT_EXCEEDED",
  UNAUTHORIZED: "UNAUTHORIZED",
  BAD_REQUEST: "BAD_REQUEST",
  NOT_FOUND: "NOT_FOUND",
  INTERNAL_ERROR: "INTERNAL_ERROR",
  OPENAI_ERROR: "OPENAI_ERROR",
  VALIDATION_ERROR: "VALIDATION_ERROR",
} as const;

/**
 * Handle errors and return appropriate response
 */
export function handleError(error: unknown): Response {
  if (error instanceof RequestValidationError) {
    return Response.json(createErrorResponse(ErrorCodes.VALIDATION_ERROR, error.message, error.status), { status: error.status });
  }
  // Do not log personal intention/profile text or provider request bodies.
  console.error("API request failed", { kind: error instanceof Error ? error.name : "Unknown" });

  if (error instanceof Error) {
    // OpenAI API errors
    if (error.message.includes("OpenAI") || error.message.includes("API")) {
      return Response.json(
        createErrorResponse(
          ErrorCodes.OPENAI_ERROR,
          "Failed to process AI request. Please try again.",
          500
        ),
        { status: 500 }
      );
    }


  }

  // Default internal error
  return Response.json(
    createErrorResponse(
      ErrorCodes.INTERNAL_ERROR,
      "An unexpected error occurred",
      500
    ),
    { status: 500 }
  );
}



