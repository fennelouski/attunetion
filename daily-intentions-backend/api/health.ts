import { HealthResponse } from "../types";

export default async function handler(): Promise<Response> {
  const response: HealthResponse = {
    status: "ok",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  };

  return Response.json(response);
}



