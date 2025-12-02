/**
 * Simple API key authentication middleware
 * For MVP, we use API key from request header
 */

export function validateApiKey(request: Request): boolean {
  // For MVP, we can either:
  // 1. Skip auth (return true)
  // 2. Check API key from header
  // 3. Check API key from environment variable
  
  const apiKey = request.headers.get("X-API-Key") || request.headers.get("Authorization")?.replace("Bearer ", "");
  const expectedKey = process.env.API_SECRET_KEY;

  // If no API_SECRET_KEY is set, skip auth for development
  if (!expectedKey) {
    return true;
  }

  return apiKey === expectedKey;
}

export function getUserId(request: Request): string | null {
  // For MVP, extract userId from header or request body
  // In production, this would come from JWT token or session
  return request.headers.get("X-User-Id") || null;
}

