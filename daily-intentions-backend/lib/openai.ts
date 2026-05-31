import OpenAI from "openai";

/** GPT-5.4 models for Chat Completions (see https://developers.openai.com/api/docs/models/) */
export const GPT54_NANO = "gpt-5.4-nano";
export const GPT54_MINI = "gpt-5.4-mini";

export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Chat Completions for GPT-5.4 reasoning models.
 * Uses max_completion_tokens (not max_tokens) and omits temperature (unsupported).
 */
export function createGpt54JsonCompletion(options: {
  model: string;
  messages: OpenAI.Chat.ChatCompletionMessageParam[];
  maxCompletionTokens: number;
  reasoningEffort?: OpenAI.ReasoningEffort | null;
}) {
  return openai.chat.completions.create({
    model: options.model,
    messages: options.messages,
    max_completion_tokens: options.maxCompletionTokens,
    reasoning_effort: options.reasoningEffort ?? "none",
    response_format: { type: "json_object" },
  });
}

/**
 * Generate a color theme for an intention using AI
 */
export async function generateTheme(intentionText: string): Promise<{
  backgroundColor: string;
  textColor: string;
  accentColor: string;
  name: string;
  reasoning: string;
}> {
  const systemPrompt = `You are a color theory expert. Given a text intention, generate a harmonious color palette that reflects the mood and theme. Return ONLY a valid JSON object with these exact keys: backgroundColor, textColor, accentColor (all hex codes like #FFFFFF), name (2-3 words), and reasoning (one sentence). Do not include any markdown formatting or code blocks.`;

  const userPrompt = `Generate a color theme for this intention: "${intentionText}"`;

  const response = await createGpt54JsonCompletion({
    model: GPT54_NANO,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    maxCompletionTokens: 512,
    reasoningEffort: "none",
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Failed to generate theme");
  }

  try {
    const theme = JSON.parse(content);

    if (!theme.backgroundColor || !theme.textColor || !theme.accentColor || !theme.name || !theme.reasoning) {
      throw new Error("Invalid theme response structure");
    }

    return theme;
  } catch (error) {
    throw new Error(`Failed to parse theme response: ${error}`);
  }
}

/**
 * Generate a relevant quote for an intention
 */
export async function generateQuote(intentionText: string): Promise<{
  quote: string;
  author: string;
  relevance: string;
}> {
  const systemPrompt = `You are a quote expert. Given a text intention, find or generate a relevant inspirational quote. Return ONLY a valid JSON object with these exact keys: quote (the quote text), author (the author name or "Unknown" if generated), and relevance (one sentence explaining why it's relevant). Do not include any markdown formatting or code blocks.`;

  const userPrompt = `Find or generate a relevant quote for this intention: "${intentionText}"`;

  const response = await createGpt54JsonCompletion({
    model: GPT54_NANO,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    maxCompletionTokens: 512,
    reasoningEffort: "none",
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Failed to generate quote");
  }

  try {
    const quote = JSON.parse(content);

    if (!quote.quote || !quote.author || !quote.relevance) {
      throw new Error("Invalid quote response structure");
    }

    return quote;
  } catch (error) {
    throw new Error(`Failed to parse quote response: ${error}`);
  }
}

/**
 * Rephrase an intention while preserving its core meaning
 */
export async function rephraseIntention(
  intentionText: string,
  previousPhrases: string[] = []
): Promise<{
  rephrasedText: string;
  preservedMeaning: boolean;
}> {
  const systemPrompt = `You are a writing assistant. Rephrase the given intention text to make it fresh and inspiring while preserving the core meaning. Remember: intentions are about HOW you want to be or show up, not specific measurable goals. Focus on being/doing rather than achieving/completing. Return ONLY a valid JSON object with these exact keys: rephrasedText (the new phrasing, 5-15 words), and preservedMeaning (boolean). Do not include any markdown formatting or code blocks.`;

  let userPrompt = `Rephrase this intention: "${intentionText}"`;

  if (previousPhrases.length > 0) {
    userPrompt += `\n\nAvoid repeating these previous phrasings: ${previousPhrases.join(", ")}`;
  }

  const response = await createGpt54JsonCompletion({
    model: GPT54_NANO,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    maxCompletionTokens: 512,
    reasoningEffort: "none",
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Failed to rephrase intention");
  }

  try {
    const result = JSON.parse(content);

    if (!result.rephrasedText || typeof result.preservedMeaning !== "boolean") {
      throw new Error("Invalid rephrase response structure");
    }

    return result;
  } catch (error) {
    throw new Error(`Failed to parse rephrase response: ${error}`);
  }
}

/**
 * Generate a monthly intention based on previous intentions
 */
export async function generateMonthlyIntention(
  previousIntentions: Array<{ text: string; month: string }>
): Promise<{
  intention: string;
  reasoning: string;
}> {
  const systemPrompt = `You are a personal growth advisor. Analyze patterns in previous monthly intentions and generate a new intention that builds on those themes. Remember: intentions are about HOW you want to be or show up, not specific measurable goals. Focus on being/doing rather than achieving/completing. Return ONLY a valid JSON object with these exact keys: intention (5-15 words), and reasoning (one sentence explaining how it builds on previous themes). Do not include any markdown formatting or code blocks.`;

  const intentionsList = previousIntentions
    .map((int) => `${int.month}: ${int.text}`)
    .join("\n");

  const userPrompt = `Based on these previous monthly intentions:\n${intentionsList}\n\nGenerate a new monthly intention that builds on these themes.`;

  const response = await createGpt54JsonCompletion({
    model: GPT54_NANO,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    maxCompletionTokens: 512,
    reasoningEffort: "none",
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Failed to generate monthly intention");
  }

  try {
    const result = JSON.parse(content);

    if (!result.intention || !result.reasoning) {
      throw new Error("Invalid monthly intention response structure");
    }

    return result;
  } catch (error) {
    throw new Error(`Failed to parse monthly intention response: ${error}`);
  }
}
