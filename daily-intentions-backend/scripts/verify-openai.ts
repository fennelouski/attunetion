/**
 * Smoke-test the configured Chat Completions models (requires OPENAI_API_KEY).
 * Run: npm run verify-openai
 */
async function main() {
  if (!process.env.OPENAI_API_KEY) {
    console.log("OPENAI_API_KEY is not set");
    process.exit(1);
  }

  const { createJsonCompletion, generateQuote, FOCUSED_MODEL } = await import(
    "../lib/openai"
  );

  console.log("1. createJsonCompletion (focused model, json_object)...");
  const ping = await createJsonCompletion({
    model: FOCUSED_MODEL,
    messages: [
      {
        role: "system",
        content: 'Return ONLY JSON: {"ok":true}. No markdown.',
      },
      { role: "user", content: "ping" },
    ],
    maxCompletionTokens: 256,
    reasoningEffort: "none",
  });
  const pingContent = ping.choices[0]?.message?.content;
  if (!pingContent) {
    throw new Error("Empty completion content");
  }
  const parsed = JSON.parse(pingContent) as { ok?: boolean };
  if (parsed.ok !== true) {
    throw new Error(`Unexpected JSON: ${pingContent}`);
  }
  console.log("   OK");

  console.log("2. generateQuote()...");
  const quote = await generateQuote("Show up with patience");
  if (!quote.quote || !quote.author) {
    throw new Error("generateQuote returned invalid shape");
  }
  console.log(`   OK — "${quote.quote.slice(0, 40)}..."`);

  console.log("\nAll OpenAI smoke tests passed.");
}

main().catch((err) => {
  console.error("\nOpenAI verification failed:", err);
  process.exit(1);
});
