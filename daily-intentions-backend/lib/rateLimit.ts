/**
 * Simple in-memory rate limiting
 * For production, use Vercel Edge Config or Upstash Redis
 */

interface RateLimitEntry {
  count: number;
  resetTime: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();

const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour
const RATE_LIMIT_MAX_REQUESTS = 50; // 50 requests per hour

/**
 * Check if request should be rate limited
 * Returns { allowed: boolean, remaining: number, resetAt: number }
 */
export function checkRateLimit(identifier: string): {
  allowed: boolean;
  remaining: number;
  resetAt: number;
} {
  // Skip rate limiting if disabled
  if (process.env.RATE_LIMIT_ENABLED !== "true") {
    return {
      allowed: true,
      remaining: RATE_LIMIT_MAX_REQUESTS,
      resetAt: Date.now() + RATE_LIMIT_WINDOW_MS,
    };
  }

  const now = Date.now();
  const entry = rateLimitStore.get(identifier);

  // No entry or expired, create new entry
  if (!entry || now > entry.resetTime) {
    const resetTime = now + RATE_LIMIT_WINDOW_MS;
    rateLimitStore.set(identifier, {
      count: 1,
      resetTime,
    });

    // Clean up old entries periodically
    cleanupExpiredEntries();

    return {
      allowed: true,
      remaining: RATE_LIMIT_MAX_REQUESTS - 1,
      resetAt: resetTime,
    };
  }

  // Check if limit exceeded
  if (entry.count >= RATE_LIMIT_MAX_REQUESTS) {
    return {
      allowed: false,
      remaining: 0,
      resetAt: entry.resetTime,
    };
  }

  // Increment count
  entry.count++;
  rateLimitStore.set(identifier, entry);

  return {
    allowed: true,
    remaining: RATE_LIMIT_MAX_REQUESTS - entry.count,
    resetAt: entry.resetTime,
  };
}

function cleanupExpiredEntries() {
  const now = Date.now();
  for (const [key, entry] of rateLimitStore.entries()) {
    if (now > entry.resetTime) {
      rateLimitStore.delete(key);
    }
  }
}

/**
 * Get rate limit identifier from request
 */
export function getRateLimitIdentifier(request: Request): string {
  // Use user ID if available, otherwise use IP address
  const userId = request.headers.get("X-User-Id");
  if (userId) {
    return `user:${userId}`;
  }

  // Fallback to IP address (for Vercel, use CF-Connecting-IP header)
  const ip = request.headers.get("CF-Connecting-IP") || 
             request.headers.get("X-Forwarded-For")?.split(",")[0] || 
             "unknown";
  return `ip:${ip}`;
}

