import { readFile } from 'fs/promises';
import { join } from 'path';

const LEGAL_DOCUMENTS: Record<string, string> = {
  'privacy-policy': 'privacy-policy.html',
  'eula': 'eula.html',
  'terms-of-service': 'terms-of-service.html',
};

export default async function handler(request: Request): Promise<Response> {
  if (request.method !== "GET") {
    return new Response("Method not allowed", { status: 405 });
  }

  const url = new URL(request.url);
  const document = url.pathname.split('/').pop() || '';

  const fileName = LEGAL_DOCUMENTS[document];
  if (!fileName) {
    return new Response("Document not found", { status: 404 });
  }

  try {
    // In Vercel, public files are served automatically, but we can also serve them via API
    // For now, redirect to the public file
    const baseUrl = process.env.VERCEL_URL 
      ? `https://${process.env.VERCEL_URL}` 
      : 'http://localhost:3000';
    
    return Response.redirect(`${baseUrl}/legal/${fileName}`, 302);
  } catch (error) {
    return new Response("Error serving document", { status: 500 });
  }
}


