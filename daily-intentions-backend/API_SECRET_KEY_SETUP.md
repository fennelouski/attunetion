# API access configuration

The current native app calls the existing Vercel AI routes without an API secret. Production has an `OPENAI_API_KEY` provider credential; it is server-side only and must never be copied into an app bundle, source, review notes or logs.

`API_SECRET_KEY` remains an optional server-side access check. When it is configured, callers must supply the matching `X-API-Key` or Bearer value; when it is absent, current Vercel access is anonymous. A shared secret embedded in a distributed native app is recoverable and is not user authentication. Do not invent a value or enable this option independently of a compatible, reviewed client access design.

The AWS parallel endpoint is protected separately with AWS IAM and requires SigV4-signed requests from authorized operator credentials. Native clients do not use it. Do not put AWS credentials into the mobile app or make the endpoint anonymous to bypass verification.

See DEPLOYMENT.md for actual request limits, known global quota limitations, deployment requirements and the public-cutover access-control work still outstanding. This guide intentionally contains no credential values.
