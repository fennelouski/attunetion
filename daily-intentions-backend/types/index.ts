// API Request/Response Types

export interface GenerateThemeRequest {
  intentionText: string;
}

export interface ThemeResponse {
  theme: {
    backgroundColor: string;
    textColor: string;
    accentColor: string;
    name: string;
    reasoning: string;
  };
}

export interface GenerateQuoteRequest {
  intentionText: string;
}

export interface QuoteResponse {
  quote: string;
  author: string;
  relevance: string;
}

export interface RephraseIntentionRequest {
  intentionText: string;
  previousPhrases?: string[];
}

export interface RephraseIntentionResponse {
  rephrasedText: string;
  preservedMeaning: boolean;
}

export interface PreviousIntention {
  text: string;
  month: string;
}

export interface GenerateMonthlyIntentionRequest {
  previousIntentions: PreviousIntention[];
}

export interface GenerateMonthlyIntentionResponse {
  intention: string;
  reasoning: string;
}

export interface Intention {
  id: string;
  userId: string;
  text: string;
  scope: "day" | "week" | "month";
  date: string;
  createdAt: string;
  updatedAt: string;
  themeId?: string;
  customFont?: string;
  aiGenerated: boolean;
  aiRephrased: boolean;
  quote?: string;
}

export interface CreateIntentionRequest {
  userId: string;
  text: string;
  scope: "day" | "week" | "month";
  date: string;
  themeId?: string;
  customFont?: string;
  aiGenerated?: boolean;
  quote?: string;
}

export interface UpdateIntentionRequest {
  text?: string;
  scope?: "day" | "week" | "month";
  date?: string;
  themeId?: string;
  customFont?: string;
  aiRephrased?: boolean;
  quote?: string;
}

export interface ApiError {
  error: {
    code: string;
    message: string;
    statusCode: number;
  };
}

export interface HealthResponse {
  status: "ok";
  timestamp: string;
  version: string;
}

