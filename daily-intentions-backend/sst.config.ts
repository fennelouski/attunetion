/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    if (input.stage !== "parallel") throw new Error("Only the protected parallel stage is enabled.");
    return {
      name: "attunetion-backend", home: "aws", removal: "retain", protect: true,
      providers: { aws: { region: "us-west-2", allowedAccountIds: ["074861507225"] } },
    };
  },
  async run() {
    if (!/^[a-f0-9]{40}$/.test(process.env.SOURCE_COMMIT || "")) throw new Error("SOURCE_COMMIT must identify the committed release.");
    const key = new sst.Secret("OpenAIAPIKey");
    const api = new sst.aws.Function("Api", {
      handler: "aws/handler.handler",
      runtime: "nodejs24.x",
      url: { authorization: "iam", cors: false },
      timeout: "60 seconds", memory: "256 MB",
      // Account limit10 cannot reserve2 while preserving AWS minimum10 unreserved.
      // IAM-only operator parity uses the existing shared account cap; no public access.
      logging: { retention: "1 week" },
      environment: {
        OPENAI_API_KEY: key.value,
        RATE_LIMIT_ENABLED: "true",
        SOURCE_COMMIT: process.env.SOURCE_COMMIT!,
      },
      copyFiles: [{ from: "public", to: "public" }],
    });
    return { url: api.url, functionName: api.name, revision: process.env.SOURCE_COMMIT };
  },
});
