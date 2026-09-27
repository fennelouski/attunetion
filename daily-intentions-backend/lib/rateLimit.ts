/**
 * Simple in-memory rate limiting with sliding window
 * Each request expires after 2 hours
 * Best-effort instance limit: cold starts and multiple instances have separate stores.
 * This is not a durable per-account quota or a global provider spending cap.
 */

interface RateLimitEntry {
  requestTimestamps: number[]; // Array of request timestamps
}

const rateLimitStore = new Map<string, RateLimitEntry>();

const REQUEST_EXPIRY_MS = 2 * 60 * 60 * 1000; // 2 hours per request

// Tiered rate limits for cost control
const TIER_1_MAX_REQUESTS = 10; // First 10 requests: use gpt-5.4-mini
const TIER_2_MAX_REQUESTS = 20; // Next 10 requests: use gpt-5.4-nano for rephrasing
// TIER_3: After 20 requests, shuffle existing intentions
const RATE_LIMIT_MAX_REQUESTS = 50; // Per-instance limit

/**
 * Check if request should be rate limited
 * Uses sliding window: each request expires after 2 hours
 * Returns { allowed: boolean, remaining: number, resetAt: number, tier: number }
 */
export function checkRateLimit(identifier: string): {
  allowed: boolean;
  remaining: number;
  resetAt: number;
  tier: number; // 1 = mini, 2 = nano, 3 = shuffle
} {
  // Skip rate limiting if disabled
  if (process.env.RATE_LIMIT_ENABLED === "false") {
    return {
      allowed: true,
      remaining: RATE_LIMIT_MAX_REQUESTS,
      resetAt: Date.now() + REQUEST_EXPIRY_MS,
      tier: 1,
    };
  }

  const now = Date.now();
  let entry = rateLimitStore.get(identifier);

  // Initialize entry if it doesn't exist
  if (!entry) {
    entry = { requestTimestamps: [] };
    rateLimitStore.set(identifier, entry);
  }

  // Remove expired requests (older than 2 hours)
  entry.requestTimestamps = entry.requestTimestamps.filter(
    timestamp => now - timestamp < REQUEST_EXPIRY_MS
  );

  const activeRequestCount = entry.requestTimestamps.length;

  // Check if limit exceeded
  if (activeRequestCount >= RATE_LIMIT_MAX_REQUESTS) {
    // Calculate when the oldest request expires (when capacity will be available)
    const oldestRequest = Math.min(...entry.requestTimestamps);
    const resetAt = oldestRequest + REQUEST_EXPIRY_MS;
    
    return {
      allowed: false,
      remaining: 0,
      resetAt,
      tier: 3,
    };
  }

  // Determine tier based on active request count
  let tier = 1;
  if (activeRequestCount >= TIER_2_MAX_REQUESTS) {
    tier = 3; // Shuffle mode
  } else if (activeRequestCount >= TIER_1_MAX_REQUESTS) {
    tier = 2; // Nano mode
  }

  // Add current request timestamp
  entry.requestTimestamps.push(now);
  rateLimitStore.set(identifier, entry);

  // Calculate when the oldest request expires (for reset time)
  const oldestRequest = entry.requestTimestamps.length > 0 
    ? Math.min(...entry.requestTimestamps)
    : now;
  const resetAt = oldestRequest + REQUEST_EXPIRY_MS;

  // Clean up old entries periodically
  cleanupExpiredEntries();

  return {
    allowed: true,
    remaining: RATE_LIMIT_MAX_REQUESTS - activeRequestCount - 1,
    resetAt,
    tier,
  };
}

function cleanupExpiredEntries() {
  const now = Date.now();
  for (const [key, entry] of rateLimitStore.entries()) {
    // Remove expired requests
    entry.requestTimestamps = entry.requestTimestamps.filter(
      timestamp => now - timestamp < REQUEST_EXPIRY_MS
    );
    
    // Remove entry if no active requests
    if (entry.requestTimestamps.length === 0) {
      rateLimitStore.delete(key);
    }
  }
}

/**
 * Get rate limit identifier from request
 */
export function getRateLimitIdentifier(request: Request): string {
  // User-provided IDs are not authentication and must not reset a caller's quota.
  // Vercel supplies X-Forwarded-For; the AWS adapter overwrites it from sourceIp.
  const ip = request.headers.get("X-Forwarded-For")?.split(",")[0]?.trim() || "unknown";
  return `ip:${ip}`;
}
