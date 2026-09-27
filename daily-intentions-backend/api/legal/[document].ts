const LEGAL_DOCUMENTS: Record<string, string> = {
  'privacy-policy': 'privacy-policy.html',
  'eula': 'eula.html',
  'terms-of-service': 'terms-of-service.html',
};

export default {
  async fetch(request: Request): Promise<Response> {
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
    if (document === 'privacy-policy') {
      return Response.redirect('https://nathanfennel.com/attunetion/privacy.html', 302);
    }
    const baseUrl = url.origin;

    return Response.redirect(`${baseUrl}/legal/${fileName}`, 302);
  } catch (error) {
    return new Response("Error serving document", { status: 500 });
  }
  },
};

