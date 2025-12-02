# Chat 2: Vercel Backend API

## Your Mission
Build the Vercel backend API that handles AI features (theme generation, quote finding, intention rephrasing) and provides REST endpoints for data sync.

## Context
You're building the backend for a Daily Intentions app. The iOS app uses SwiftData for local storage, but needs AI features powered by OpenAI. The backend will run on Vercel with serverless functions.

## Your Scope - FILES YOU OWN
Create a new Vercel project in a separate directory (NOT in the Xcode project):
```
daily-intentions-backend/
├── api/
│   ├── intentions/
│   │   ├── index.ts (GET all, POST create)
│   │   └── [id].ts (GET one, PUT update, DELETE)
│   ├── ai/
│   │   ├── generate-theme.ts
│   │   ├── generate-quote.ts
│   │   ├── rephrase-intention.ts
│   │   └── generate-monthly-intention.ts
│   └── health.ts
├── lib/
│   ├── openai.ts
│   ├── db.ts (optional - for backup/sync)
│   └── auth.ts
├── types/
│   └── index.ts
├── vercel.json
├── package.json
└── README.md
```

## What You Need to Build

### 1. AI Endpoints

#### POST /api/ai/generate-theme
```typescript
// Input:
{
  "intentionText": "Be more present with my family"
}

// Output:
{
  "theme": {
    "backgroundColor": "#F0E6D2",
    "textColor": "#2C1810",
    "accentColor": "#8B4513",
    "name": "Warm Family",
    "reasoning": "Warm, earthy tones that evoke comfort and togetherness"
  }
}

// Implementation:
- Use GPT-4 or GPT-3.5-turbo
- Analyze the intention's mood/theme
- Generate harmonious color palette
- Return hex colors and a generated name
```

#### POST /api/ai/generate-quote
```typescript
// Input:
{
  "intentionText": "Focus on health and exercise"
}

// Output:
{
  "quote": "The greatest wealth is health.",
  "author": "Virgil",
  "relevance": "Emphasizes the value of health as true wealth"
}

// Implementation:
- Use GPT-4 to find or generate relevant quote
- Can use real quotes or inspirational generated ones
- Include attribution if real quote
```

#### POST /api/ai/rephrase-intention
```typescript
// Input:
{
  "intentionText": "Exercise more",
  "previousPhrases": ["Get fit", "Work out daily"] // optional, to avoid repeats
}

// Output:
{
  "rephrasedText": "Prioritize movement and physical vitality",
  "preservedMeaning": true
}

// Implementation:
- Rephrase while keeping core meaning
- Make it fresh/inspiring
- Avoid repetition of previous phrases
```

#### POST /api/ai/generate-monthly-intention
```typescript
// Input:
{
  "previousIntentions": [
    { "text": "Focus on family", "month": "January" },
    { "text": "Build healthy habits", "month": "February" },
    { "text": "Practice gratitude", "month": "March" }
  ]
}

// Output:
{
  "intention": "Cultivate deeper connections and mindful living",
  "reasoning": "Builds on themes of family, health, and gratitude"
}

// Implementation:
- Analyze patterns in previous intentions
- Generate new intention that builds on themes
- Keep it concise (5-15 words)
```

### 2. Data Sync Endpoints (Optional for MVP)

#### GET /api/intentions?userId=xxx
Return all intentions for a user (if you want server-side backup)

#### POST /api/intentions
Create new intention

#### PUT /api/intentions/:id
Update intention

#### DELETE /api/intentions/:id
Delete intention

**Note**: These are optional since CloudKit handles sync. Implement only if you want server-side backup or analytics.

### 3. Authentication
Simple approach for MVP:
- Use API key authentication (from iOS app)
- Or use Clerk/Auth0 for user management
- Or skip auth for now (use userId in request body)

### 4. Rate Limiting
Implement rate limiting on AI endpoints:
- 50 requests per hour per user for AI endpoints
- Use Vercel's Edge Config or Upstash Redis

### 5. Error Handling
Consistent error responses:
```typescript
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Try again in 5 minutes.",
    "statusCode": 429
  }
}
```

## Environment Variables Needed
```
OPENAI_API_KEY=sk-...
DATABASE_URL=... (if using DB)
API_SECRET_KEY=... (for auth)
RATE_LIMIT_ENABLED=true
```

## OpenAI Best Practices
- Use GPT-3.5-turbo for cost efficiency (or GPT-4 for better quality)
- Set reasonable token limits (max_tokens: 150 for themes, 100 for quotes)
- Include system prompts that enforce constraints
- Cache responses when appropriate (same intention text = same theme)
- Handle OpenAI API errors gracefully

Example system prompt for theme generation:
```
You are a color theory expert. Given a text intention, generate a harmonious color palette that reflects the mood and theme. Return ONLY a JSON object with backgroundColor, textColor, accentColor (all hex codes), name (2-3 words), and reasoning (one sentence).
```

## Testing
- Create a `/api/health` endpoint that returns { status: "ok" }
- Test all AI endpoints with curl/Postman
- Document example requests/responses
- Test OpenAI error scenarios (rate limits, network errors)

## Integration Points

### What Others Need From You
- **iOS Team** needs:
  - API base URL (will be Vercel production URL)
  - Endpoint documentation
  - Error codes documentation
  - Example requests/responses

### What You Need From Others
- **Data Team** will provide model structure (but you don't need it to start)
- Can define your own API contract and document it

## Deployment
1. Deploy to Vercel
2. Set environment variables in Vercel dashboard
3. Enable CORS for iOS app (allow all origins for development)
4. Share production URL with iOS team

## Cost Considerations
OpenAI API costs:
- Theme generation: ~$0.002 per request (GPT-3.5)
- Quote generation: ~$0.002 per request
- Rephrase: ~$0.001 per request

Implement caching to reduce costs:
- Cache theme for same intention text (24 hours)
- Cache quotes (they don't change)

## Deliverables
1. Working Vercel backend with all AI endpoints
2. API documentation (README.md with examples)
3. Error handling and rate limiting
4. Health check endpoint
5. Environment variable template (.env.example)
6. Deployed to Vercel with production URL

## Tech Stack
- TypeScript
- Vercel Serverless Functions
- OpenAI API (GPT-3.5-turbo or GPT-4)
- Optional: Vercel Postgres or Upstash Redis for caching

**Start by initializing a Vercel project, setting up OpenAI client, and building the theme generation endpoint first as proof of concept.**
