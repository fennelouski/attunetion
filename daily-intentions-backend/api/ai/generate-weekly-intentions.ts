import OpenAI from "openai";
import { validateApiKey, getUserId } from "../../lib/auth";
import { checkRateLimit, getRateLimitIdentifier } from "../../lib/rateLimit";
import { handleError, ErrorCodes, createErrorResponse } from "../../lib/errors";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

interface GenerateWeeklyIntentionsRequest {
  userInfo: string;
  weekStartDate: string; // ISO date string
  previousIntentions?: Array<{
    text: string;
    scope: "day" | "week" | "month";
    date: string;
  }>;
}

interface WeeklyIntention {
  date: string; // ISO date string
  text: string;
  scope: "day" | "week" | "month";
}

interface GenerateWeeklyIntentionsResponse {
  intentions: WeeklyIntention[];
  weekStartDate: string;
  weekEndDate: string;
}

export default async function handler(request: Request): Promise<Response> {
  // Handle CORS preflight
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key, X-User-Id",
      },
    });
  }

  if (request.method !== "POST") {
    return Response.json(
      createErrorResponse(ErrorCodes.BAD_REQUEST, "Method not allowed", 405),
      { status: 405 }
    );
  }

  try {
    // Authentication
    if (!validateApiKey(request)) {
      return Response.json(
        createErrorResponse(ErrorCodes.UNAUTHORIZED, "Invalid API key", 401),
        { status: 401 }
      );
    }

    // Rate limiting
    const identifier = getRateLimitIdentifier(request);
    const rateLimit = checkRateLimit(identifier);
    
    if (!rateLimit.allowed) {
      const waitMinutes = Math.ceil((rateLimit.resetAt - Date.now()) / 60000);
      const waitHours = Math.floor(waitMinutes / 60);
      const waitMinutesRemainder = waitMinutes % 60;
      
      let waitMessage = "";
      if (waitHours > 0) {
        waitMessage = `Too many requests. Try again in ${waitHours} hour${waitHours > 1 ? 's' : ''}${waitMinutesRemainder > 0 ? ` and ${waitMinutesRemainder} minute${waitMinutesRemainder > 1 ? 's' : ''}` : ''}.`;
      } else {
        waitMessage = `Too many requests. Try again in ${waitMinutes} minute${waitMinutes > 1 ? 's' : ''}.`;
      }
      
      return Response.json(
        createErrorResponse(
          ErrorCodes.RATE_LIMIT_EXCEEDED,
          waitMessage,
          429
        ),
        {
          status: 429,
          headers: {
            "X-RateLimit-Limit": "50",
            "X-RateLimit-Remaining": "0",
            "X-RateLimit-Reset": rateLimit.resetAt.toString(),
          },
        }
      );
    }

    // Parse request body
    const body: GenerateWeeklyIntentionsRequest = await request.json();
    
    if (!body.userInfo || typeof body.userInfo !== "string") {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "userInfo is required", 400),
        { status: 400 }
      );
    }

    if (!body.weekStartDate || typeof body.weekStartDate !== "string") {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "weekStartDate is required (ISO string)", 400),
        { status: 400 }
      );
    }

    const weekStart = new Date(body.weekStartDate);
    if (isNaN(weekStart.getTime())) {
      return Response.json(
        createErrorResponse(ErrorCodes.VALIDATION_ERROR, "Invalid weekStartDate format", 400),
        { status: 400 }
      );
    }

    // Calculate week end date (7 days from start)
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);

    // Determine which strategy to use based on rate limit tier
    const tier = rateLimit.tier;
    
    // Tier 3: Shuffle existing intentions (no API call)
    if (tier === 3) {
      return handleShuffleMode(body, weekStart, weekEnd, rateLimit);
    }
    
    // Tier 2: Use nano model for rephrasing
    if (tier === 2) {
      return handleNanoMode(body, weekStart, weekEnd, rateLimit);
    }
    
    // Tier 1: Use mini model (default)
    return handleMiniMode(body, weekStart, weekEnd, rateLimit);
  } catch (error) {
    return handleError(error);
  }
}

async function handleMiniMode(
  body: GenerateWeeklyIntentionsRequest,
  weekStart: Date,
  weekEnd: Date,
  rateLimit: { remaining: number; resetAt: number; tier: number }
): Promise<Response> {
  const model = "gpt-5.1-mini";

    // Build system prompt
    const systemPrompt = `You are a personal growth and mindfulness advisor. Based on information about a user, generate personalized daily, weekly, and monthly intentions for a specific week. 

Return ONLY a valid JSON object with this exact structure:
{
  "intentions": [
    {
      "date": "YYYY-MM-DD",
      "text": "intention text (5-15 words)",
      "scope": "day"
    },
    {
      "date": "YYYY-MM-DD",
      "text": "intention text (5-15 words)",
      "scope": "week"
    },
    {
      "date": "YYYY-MM-DD",
      "text": "intention text (5-15 words)",
      "scope": "month"
    }
  ]
}

Rules:
- Generate exactly ONE daily intention for each day of the week (7 days)
- Generate exactly ONE weekly intention for the week
- Generate exactly ONE monthly intention for the month (if the week spans a month boundary, use the month that contains most days)
- Daily intentions should be specific and actionable for that day
- Weekly intention should be broader and guide the whole week
- Monthly intention should be the most general and guide the whole month
- Make intentions personal, relevant, and inspiring based on the user's information
- Use dates in YYYY-MM-DD format
- Do not include any markdown formatting or code blocks`;

    // Build user prompt
    let userPrompt = `Generate intentions for the week starting ${body.weekStartDate}.\n\n`;
    userPrompt += `User information:\n${body.userInfo}\n\n`;
    
    if (body.previousIntentions && body.previousIntentions.length > 0) {
      userPrompt += `Previous intentions (for context):\n`;
      body.previousIntentions.forEach(int => {
        userPrompt += `- ${int.scope} (${int.date}): ${int.text}\n`;
      });
      userPrompt += `\n`;
    }
    
    userPrompt += `Generate 7 daily intentions (one for each day), 1 weekly intention, and 1 monthly intention.`;

    // Call OpenAI API
    const response = await openai.chat.completions.create({
      model: model,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      max_tokens: 2000,
      temperature: 0.8,
      response_format: { type: "json_object" },
    });

    return processAIResponse(response, body.weekStartDate, weekEnd, rateLimit);
}

async function handleNanoMode(
  body: GenerateWeeklyIntentionsRequest,
  weekStart: Date,
  weekEnd: Date,
  rateLimit: { remaining: number; resetAt: number; tier: number }
): Promise<Response> {
  // Use nano model to rephrase existing intentions
  const model = "gpt-5.1-nano";
  
  if (!body.previousIntentions || body.previousIntentions.length === 0) {
    // Fallback to shuffle if no previous intentions
    return handleShuffleMode(body, weekStart, weekEnd, rateLimit);
  }
  
  const systemPrompt = `You are a personal growth advisor. Rephrase the given intentions to make them fresh and relevant for a new week. Return ONLY a valid JSON object with this structure:
{
  "intentions": [
    {"date": "YYYY-MM-DD", "text": "rephrased text (5-15 words)", "scope": "day"},
    ...
  ]
}`;

  // Select a few previous intentions to rephrase
  const selectedIntentions = body.previousIntentions.slice(0, 9); // Mix of daily/weekly/monthly
  const userPrompt = `Rephrase these intentions for the week starting ${body.weekStartDate}:\n${selectedIntentions.map(i => `- ${i.scope}: ${i.text}`).join('\n')}\n\nGenerate 7 daily intentions, 1 weekly, and 1 monthly.`;

  const response = await openai.chat.completions.create({
    model: model,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    max_tokens: 1000,
    temperature: 0.7,
    response_format: { type: "json_object" },
  });

  return processAIResponse(response, body.weekStartDate, weekEnd, rateLimit);
}

async function handleShuffleMode(
  body: GenerateWeeklyIntentionsRequest,
  weekStart: Date,
  weekEnd: Date,
  rateLimit: { remaining: number; resetAt: number; tier: number }
): Promise<Response> {
  // Shuffle existing intentions to create illusion of new content
  if (!body.previousIntentions || body.previousIntentions.length < 9) {
    // Not enough intentions to shuffle, return error
    return Response.json(
      createErrorResponse(
        ErrorCodes.BAD_REQUEST,
        "Not enough previous intentions available. Please create some intentions first.",
        400
      ),
      { status: 400 }
    );
  }

  // Shuffle and select intentions
  const shuffled = [...body.previousIntentions].sort(() => Math.random() - 0.5);
  const dailyIntentions = shuffled.filter(i => i.scope === "day").slice(0, 7);
  const weeklyIntention = shuffled.find(i => i.scope === "week") || shuffled[0];
  const monthlyIntention = shuffled.find(i => i.scope === "month") || shuffled[1];

  // Generate dates for the week
  const intentions: WeeklyIntention[] = [];
  for (let i = 0; i < 7; i++) {
    const date = new Date(weekStart);
    date.setDate(date.getDate() + i);
    intentions.push({
      date: date.toISOString().split('T')[0],
      text: dailyIntentions[i]?.text || shuffled[i % shuffled.length].text,
      scope: "day",
    });
  }

  intentions.push({
    date: weekStart.toISOString().split('T')[0],
    text: weeklyIntention.text,
    scope: "week",
  });

  intentions.push({
    date: weekStart.toISOString().split('T')[0],
    text: monthlyIntention.text,
    scope: "month",
  });

  const apiResponse: GenerateWeeklyIntentionsResponse = {
    intentions,
    weekStartDate: body.weekStartDate,
    weekEndDate: weekEnd.toISOString().split('T')[0],
  };

  return Response.json(apiResponse, {
    headers: {
      "X-RateLimit-Limit": "50",
      "X-RateLimit-Remaining": rateLimit.remaining.toString(),
      "X-RateLimit-Reset": rateLimit.resetAt.toString(),
      "X-Response-Mode": "shuffle",
    },
  });
}

function processAIResponse(
  response: any,
  weekStartDate: string,
  weekEnd: Date,
  rateLimit: { remaining: number; resetAt: number; tier: number }
): Response {
  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Failed to generate intentions");
  }

  try {
    const result = JSON.parse(content);
    
    // Validate response structure
    if (!result.intentions || !Array.isArray(result.intentions)) {
      throw new Error("Invalid response structure: intentions array missing");
    }

    // Validate each intention
    for (const intention of result.intentions) {
      if (!intention.date || !intention.text || !intention.scope) {
        throw new Error("Invalid intention structure: missing required fields");
      }
      if (!["day", "week", "month"].includes(intention.scope)) {
        throw new Error("Invalid scope: must be 'day', 'week', or 'month'");
      }
    }

    // Ensure we have the right number of intentions
    const dailyCount = result.intentions.filter((i: WeeklyIntention) => i.scope === "day").length;
    const weeklyCount = result.intentions.filter((i: WeeklyIntention) => i.scope === "week").length;
    const monthlyCount = result.intentions.filter((i: WeeklyIntention) => i.scope === "month").length;

    if (dailyCount !== 7) {
      throw new Error(`Expected 7 daily intentions, got ${dailyCount}`);
    }
    if (weeklyCount !== 1) {
      throw new Error(`Expected 1 weekly intention, got ${weeklyCount}`);
    }
    if (monthlyCount !== 1) {
      throw new Error(`Expected 1 monthly intention, got ${monthlyCount}`);
    }

    const apiResponse: GenerateWeeklyIntentionsResponse = {
      intentions: result.intentions,
      weekStartDate: weekStartDate,
      weekEndDate: weekEnd.toISOString().split('T')[0],
    };

    return Response.json(apiResponse, {
      headers: {
        "X-RateLimit-Limit": "50",
        "X-RateLimit-Remaining": rateLimit.remaining.toString(),
        "X-RateLimit-Reset": rateLimit.resetAt.toString(),
      },
    });
  } catch (error) {
    throw new Error(`Failed to parse intentions response: ${error}`);
  }
}

