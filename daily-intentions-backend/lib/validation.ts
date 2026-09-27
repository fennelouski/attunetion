export class RequestValidationError extends Error {
  constructor(message: string, public readonly status = 400) { super(message); }
}

export async function readJsonObject(request: Request): Promise<Record<string, unknown>> {
  const limit = 64 * 1024;
  if (Number(request.headers.get('content-length')) > limit) {
    throw new RequestValidationError('Request body is too large', 413);
  }
  const text = await request.text();
  if (new TextEncoder().encode(text).length > limit) {
    throw new RequestValidationError('Request body is too large', 413);
  }
  let body: unknown;
  try { body = JSON.parse(text); } catch { throw new RequestValidationError('Request body must be valid JSON'); }
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    throw new RequestValidationError('Request body must be a JSON object');
  }
  return body as Record<string, unknown>;
}

function string(value: unknown, name: string, max: number): asserts value is string {
  if (typeof value !== 'string' || !value.trim() || value.length > max) {
    throw new RequestValidationError(`${name} must contain 1–${max} characters`);
  }
}
function date(value: unknown, name: string): void {
  string(value, name, 40);
  if (!/^\d{4}-\d{2}-\d{2}(?:T.*)?$/.test(value) || Number.isNaN(Date.parse(value))) {
    throw new RequestValidationError(`${name} must be an ISO date`);
  }
}
function array(value: unknown, name: string, max: number): asserts value is unknown[] {
  if (!Array.isArray(value) || value.length > max) throw new RequestValidationError(`${name} must be an array of at most ${max} entries`);
}
function object(value: unknown): asserts value is Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new RequestValidationError('Each intention must be an object');
}

export function validateAIRequest(kind: string, body: Record<string, unknown>): void {
  if (kind === 'generate-weekly-intentions') {
    string(body.userInfo, 'userInfo', 8000);
    date(body.weekStartDate, 'weekStartDate');
    if (body.previousIntentions !== undefined) {
      array(body.previousIntentions, 'previousIntentions', 90);
      for (const item of body.previousIntentions) {
        object(item);string(item.text, 'text', 2000);date(item.date, 'date');
        if (!['day','week','month'].includes(String(item.scope))) throw new RequestValidationError('Invalid intention scope');
      }
    }
  } else if (kind === 'generate-monthly-intention') {
    array(body.previousIntentions, 'previousIntentions', 36);
    if (!body.previousIntentions.length) throw new RequestValidationError('previousIntentions must not be empty');
    for (const item of body.previousIntentions) { object(item);string(item.text, 'text', 2000);string(item.month, 'month', 40); }
  } else {
    string(body.intentionText, 'intentionText', 2000);
    if (kind === 'rephrase-intention' && body.previousPhrases !== undefined) {
      array(body.previousPhrases, 'previousPhrases', 50);
      for (const phrase of body.previousPhrases) string(phrase, 'previous phrase', 2000);
    }
  }
}
