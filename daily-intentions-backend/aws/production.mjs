import { handler as dispatch } from "./handler.ts";
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";
import { validateAIRequest } from "../lib/validation.ts";

const db = new DynamoDBClient({});
const actions = new Set(["generate-theme", "generate-weekly-intentions",
  "generate-monthly-intention", "rephrase-intention", "generate-quote"]);

function response(statusCode, message) {
  return { statusCode, headers: { "cache-control": "no-store", "content-type": "application/json" },
    body: JSON.stringify({ error: message }) };
}

export async function handler(event) {
  if (event.rawPath === "/api/health") return dispatch(event);
  const action = event.rawPath.slice("/api/ai/".length);
  if (!event.rawPath.startsWith("/api/ai/") || !actions.has(action)) return response(404, "Not found");
  if (event.requestContext.http.method !== "POST") return response(405, "Method not allowed");
  try {
    const body = Buffer.from(event.body ?? "", event.isBase64Encoded ? "base64" : "utf8");
    if (body.length > 65536) return response(413, "Request too large");
    validateAIRequest(action, JSON.parse(body.toString("utf8")));
  } catch {
    return response(400, "Invalid request");
  }
  const day = Math.floor(Date.now() / 86400000);
  try {
    await db.send(new UpdateItemCommand({
      TableName: process.env.QUOTA_TABLE,
      Key: { period: { S: String(day) } },
      UpdateExpression: "SET expiresAt = :expiry ADD requests :one",
      ConditionExpression: "attribute_not_exists(requests) OR requests < :limit",
      ExpressionAttributeValues: { ":one": { N: "1" }, ":limit": { N: process.env.DAILY_REQUEST_LIMIT },
        ":expiry": { N: String((day + 3) * 86400) } }
    }));
  } catch (error) {
    return error.name === "ConditionalCheckFailedException"
      ? response(429, "Daily suggestion limit reached")
      : response(503, "Suggestions temporarily unavailable");
  }
  return dispatch(event);
}
