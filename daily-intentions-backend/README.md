# Daily Intentions Backend API

Vercel serverless backend API for the Daily Intentions iOS/macOS app, providing AI-powered features including theme generation, quote finding, intention rephrasing, and monthly intention generation.

## 🚀 Quick Start

### Prerequisites

- Node.js 20.x or later
- Vercel CLI (`npm i -g vercel`)
- OpenAI API key

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

### Local Development

```bash
# Run locally with Vercel CLI
npm run dev
```

The API will be available at `http://localhost:3000`

### Deployment

```bash
# Deploy to Vercel
vercel

# Set environment variables in Vercel dashboard
# - OPENAI_API_KEY
# - API_SECRET_KEY (optional)
# - RATE_LIMIT_ENABLED=true
```

## 📚 API Documentation

### Base URL

- **Production**: `https://your-project.vercel.app`
- **Development**: `http://localhost:3000`

### Authentication

For MVP, authentication is optional. If `API_SECRET_KEY` is set in environment variables, include it in requests:

**Option 1: Header**
```
X-API-Key: your-api-secret-key
```

**Option 2: Authorization Header**
```
Authorization: Bearer your-api-secret-key
```

**User Identification** (optional):
```
X-User-Id: user-uuid-here
```

### Rate Limiting

AI endpoints are rate-limited to **50 requests per hour per user/IP**.

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Maximum requests allowed (50)
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Unix timestamp when limit resets

### Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "statusCode": 400
  }
}
```

**Error Codes:**
- `RATE_LIMIT_EXCEEDED` (429): Too many requests
- `UNAUTHORIZED` (401): Invalid or missing API key
- `BAD_REQUEST` (400): Invalid request format
- `NOT_FOUND` (404): Resource not found
- `VALIDATION_ERROR` (400): Request validation failed
- `OPENAI_ERROR` (500): OpenAI API error
- `INTERNAL_ERROR` (500): Server error

---

## 🤖 AI Endpoints

### POST /api/ai/generate-theme

Generate a color theme for an intention based on its content.

**Request:**
```json
{
  "intentionText": "Be more present with my family"
}
```

**Response:**
```json
{
  "theme": {
    "backgroundColor": "#F0E6D2",
    "textColor": "#2C1810",
    "accentColor": "#8B4513",
    "name": "Warm Family",
    "reasoning": "Warm, earthy tones that evoke comfort and togetherness"
  }
}
```

**cURL Example:**
```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-theme \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -H "X-User-Id: user-123" \
  -d '{"intentionText": "Focus on health and exercise"}'
```

---

### POST /api/ai/generate-quote

Find or generate a relevant inspirational quote for an intention.

**Request:**
```json
{
  "intentionText": "Focus on health and exercise"
}
```

**Response:**
```json
{
  "quote": "The greatest wealth is health.",
  "author": "Virgil",
  "relevance": "Emphasizes the value of health as true wealth"
}
```

**cURL Example:**
```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-quote \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{"intentionText": "Focus on health and exercise"}'
```

---

### POST /api/ai/rephrase-intention

Rephrase an intention while preserving its core meaning.

**Request:**
```json
{
  "intentionText": "Exercise more",
  "previousPhrases": ["Get fit", "Work out daily"]
}
```

**Response:**
```json
{
  "rephrasedText": "Prioritize movement and physical vitality",
  "preservedMeaning": true
}
```

**cURL Example:**
```bash
curl -X POST https://your-project.vercel.app/api/ai/rephrase-intention \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "intentionText": "Exercise more",
    "previousPhrases": ["Get fit", "Work out daily"]
  }'
```

**Note:** `previousPhrases` is optional and helps avoid repetition.

---

### POST /api/ai/generate-monthly-intention

Generate a new monthly intention based on previous monthly intentions.

**Request:**
```json
{
  "previousIntentions": [
    { "text": "Focus on family", "month": "January" },
    { "text": "Build healthy habits", "month": "February" },
    { "text": "Practice gratitude", "month": "March" }
  ]
}
```

**Response:**
```json
{
  "intention": "Cultivate deeper connections and mindful living",
  "reasoning": "Builds on themes of family, health, and gratitude"
}
```

**cURL Example:**
```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-monthly-intention \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "previousIntentions": [
      {"text": "Focus on family", "month": "January"},
      {"text": "Build healthy habits", "month": "February"}
    ]
  }'
```

---

## 📝 Data Sync Endpoints (Optional)

These endpoints provide server-side backup/sync. Since the iOS app uses CloudKit for sync, these are optional.

### GET /api/intentions?userId=xxx

Get all intentions for a user.

**Response:**
```json
{
  "intentions": [
    {
      "id": "uuid",
      "userId": "user-123",
      "text": "Be more present",
      "scope": "day",
      "date": "2024-01-15T00:00:00Z",
      "createdAt": "2024-01-15T10:00:00Z",
      "updatedAt": "2024-01-15T10:00:00Z",
      "themeId": "theme-uuid",
      "aiGenerated": false,
      "aiRephrased": false
    }
  ]
}
```

---

### POST /api/intentions

Create a new intention.

**Request:**
```json
{
  "userId": "user-123",
  "text": "Be more present with family",
  "scope": "day",
  "date": "2024-01-15T00:00:00Z",
  "themeId": "theme-uuid",
  "customFont": "Arial",
  "aiGenerated": false,
  "quote": "Family is everything"
}
```

**Response:**
```json
{
  "intention": {
    "id": "generated-uuid",
    "userId": "user-123",
    "text": "Be more present with family",
    "scope": "day",
    "date": "2024-01-15T00:00:00Z",
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T10:00:00Z",
    "aiGenerated": false,
    "aiRephrased": false
  }
}
```

---

### GET /api/intentions/:id

Get a single intention by ID.

**Response:**
```json
{
  "intention": {
    "id": "uuid",
    "userId": "user-123",
    "text": "Be more present",
    "scope": "day",
    "date": "2024-01-15T00:00:00Z",
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

### PUT /api/intentions/:id

Update an intention.

**Request:**
```json
{
  "text": "Updated intention text",
  "scope": "week",
  "aiRephrased": true
}
```

**Response:**
```json
{
  "intention": {
    "id": "uuid",
    "text": "Updated intention text",
    "scope": "week",
    "aiRephrased": true,
    "updatedAt": "2024-01-15T11:00:00Z"
  }
}
```

---

### DELETE /api/intentions/:id

Delete an intention.

**Response:**
```json
{
  "success": true
}
```

---

## 🏥 Health Check

### GET /api/health

Check API health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:00:00.000Z",
  "version": "1.0.0"
}
```

---

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | Your OpenAI API key |
| `API_SECRET_KEY` | No | API key for authentication (skip for dev) |
| `RATE_LIMIT_ENABLED` | No | Enable rate limiting (default: true) |
| `DATABASE_URL` | No | Database URL (if using persistent storage) |

### CORS

CORS is enabled for all origins by default. In production, you may want to restrict this to your iOS app's domain.

---

## 💰 Cost Considerations

OpenAI API costs (approximate):
- Theme generation: ~$0.002 per request (GPT-3.5-turbo)
- Quote generation: ~$0.002 per request
- Rephrase: ~$0.001 per request
- Monthly intention: ~$0.002 per request

**Recommendations:**
- Cache theme responses for same intention text (24 hours)
- Cache quotes (they don't change)
- Implement client-side caching to reduce API calls

---

## 🧪 Testing

### Test Health Endpoint

```bash
curl https://your-project.vercel.app/api/health
```

### Test Theme Generation

```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-theme \
  -H "Content-Type: application/json" \
  -d '{"intentionText": "Be kind to others"}'
```

### Test Quote Generation

```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-quote \
  -H "Content-Type: application/json" \
  -d '{"intentionText": "Practice gratitude"}'
```

---

## 📦 Project Structure

```
daily-intentions-backend/
├── api/
│   ├── ai/
│   │   ├── generate-theme.ts
│   │   ├── generate-quote.ts
│   │   ├── rephrase-intention.ts
│   │   └── generate-monthly-intention.ts
│   ├── intentions/
│   │   ├── index.ts
│   │   └── [id].ts
│   └── health.ts
├── lib/
│   ├── openai.ts
│   ├── auth.ts
│   ├── rateLimit.ts
│   ├── errors.ts
│   └── db.ts
├── types/
│   └── index.ts
├── package.json
├── tsconfig.json
├── vercel.json
└── README.md
```

---

## 🔄 Integration with iOS App

### Example Swift Code

```swift
struct AIService {
    let baseURL = "https://your-project.vercel.app"
    let apiKey = "your-api-key"
    
    func generateTheme(for intentionText: String) async throws -> Theme {
        var request = URLRequest(url: URL(string: "\(baseURL)/api/ai/generate-theme")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpBody = try JSONEncoder().encode(["intentionText": intentionText])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ThemeResponse.self, from: data)
        return response.theme
    }
}
```

---

## 🐛 Troubleshooting

### OpenAI API Errors

If you see `OPENAI_ERROR`, check:
1. Your `OPENAI_API_KEY` is valid
2. You have sufficient OpenAI credits
3. The request format is correct

### Rate Limit Errors

If you hit rate limits:
1. Check `X-RateLimit-Reset` header for reset time
2. Implement client-side caching
3. Consider upgrading rate limits for production

### CORS Errors

If you see CORS errors:
1. Check `vercel.json` headers configuration
2. Ensure `Access-Control-Allow-Origin` header is present
3. Verify request includes proper headers

---

## 📝 Notes

- **In-Memory Storage**: The current implementation uses in-memory storage for intentions. Data will reset on serverless function restart. For production, use Vercel Postgres or similar.
- **Authentication**: MVP uses simple API key auth. For production, consider JWT tokens or OAuth.
- **Rate Limiting**: Uses in-memory rate limiting. For production, use Vercel Edge Config or Upstash Redis.

---

## 📄 License

MIT

---

## 🤝 Support

For issues or questions, contact the backend team or refer to the main project documentation.

