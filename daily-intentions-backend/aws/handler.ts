import { readFile } from "node:fs/promises";
import { resolve, extname } from "node:path";
import theme from "../api/ai/generate-theme.js";
import quote from "../api/ai/generate-quote.js";
import rephrase from "../api/ai/rephrase-intention.js";
import monthly from "../api/ai/generate-monthly-intention.js";
import weekly from "../api/ai/generate-weekly-intentions.js";
import health from "../api/health.js";
import legal from "../api/legal/[document].js";

// Lambda URL authorization is AWS_IAM. No anonymous endpoint is provisioned.
interface FunctionUrlEvent {
  rawPath: string;
  rawQueryString?: string;
  headers: Record<string, string | undefined>;
  requestContext: { domainName: string; http: { method: string; sourceIp: string } };
  body?: string;
  isBase64Encoded?: boolean;
}
const routes: Record<string, { fetch(request: Request): Promise<Response> }> = {
  "/api/ai/generate-theme": theme,
  "/api/ai/generate-quote": quote,
  "/api/ai/rephrase-intention": rephrase,
  "/api/ai/generate-monthly-intention": monthly,
  "/api/ai/generate-weekly-intentions": weekly,
  "/api/health": health,
};
const mime: Record<string, string> = {
  ".html": "text/html; charset=utf-8", ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8", ".json": "application/json",
  ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon",
};

async function route(request: Request): Promise<Response> {
  const path = new URL(request.url).pathname.replace(/\/$/, "") || "/";
  if (routes[path]) return routes[path].fetch(request);
  if (path.startsWith("/api/legal/")) return legal.fetch(request);
  if (path.startsWith("/api/")) return new Response("Not found", { status: 404 });
  if (!["GET", "HEAD"].includes(request.method)) return new Response("Method not allowed", { status: 405 });
  const root = resolve(process.cwd(), "public");
  let pathname: string;
  try { pathname = decodeURIComponent(path); } catch { return new Response("Invalid path", { status: 400 }); }
  const file = resolve(root, `.${pathname === "/" ? "/index.html" : pathname}`);
  if (!file.startsWith(`${root}/`)) return new Response("Not found", { status: 404 });
  try {
    const data = await readFile(file);
    return new Response(request.method === "HEAD" ? null : new Uint8Array(data), {
      headers: { "Content-Type": mime[extname(file)] || "application/octet-stream" },
    });
  } catch { return new Response("Not found", { status: 404 }); }
}

export async function handler(event: FunctionUrlEvent) {
  const headers = new Headers();
  for (const [key, value] of Object.entries(event.headers || {})) {
    if (value !== undefined) headers.set(key, value);
  }
  // Client headers must not select another caller's limiter identity.
  headers.set("X-Forwarded-For", event.requestContext.http.sourceIp);
  const method = event.requestContext.http.method;
  const url = `https://${event.requestContext.domainName}${event.rawPath}${event.rawQueryString ? `?${event.rawQueryString}` : ""}`;
  const body = event.body === undefined ? undefined : Buffer.from(event.body, event.isBase64Encoded ? "base64" : "utf8");
  const request = new Request(url, { method, headers, ...(!["GET", "HEAD"].includes(method) && body !== undefined ? { body } : {}) });
  const response = await route(request);
  const responseHeaders = Object.fromEntries(response.headers.entries());
  responseHeaders["x-source-commit"] = process.env.SOURCE_COMMIT || "unknown";
  responseHeaders["cache-control"] = "no-store";
  return {
    statusCode: response.status,
    headers: responseHeaders,
    body: Buffer.from(await response.arrayBuffer()).toString("base64"),
    isBase64Encoded: true,
  };
}
