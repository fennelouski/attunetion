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

// Unsplash API types (normalized for our app)
export interface UnsplashPhotoSummary {
  id: string;
  urls: { raw?: string; full?: string; regular: string; small: string; thumb: string };
  links: { download_location: string; html: string };
  user: { name: string; username: string; links?: { html: string } };
  attributionText?: string;
  attributionUrl?: string;
}

export interface UnsplashSearchResponse {
  total: number;
  total_pages: number;
  results: UnsplashPhotoSummary[];
}

export interface TriggerDownloadRequest {
  unsplashPhotoId: string;
  download_location: string;
}

export interface CuratedPhotoRecord {
  id: string;
  unsplash_photo_id: string;
  image_url: string;
  attribution_text: string;
  attribution_url: string;
  download_location: string;
  approved_at: string;
  created_at: string;
  suggested_theme_name?: string | null;
}

export interface AddCuratedPhotoRequest {
  unsplash_photo_id: string;
  image_url: string;
  attribution_text: string;
  attribution_url: string;
  download_location: string;
  color?: string; // Unsplash photo color hex, used to suggest preset theme
}

export interface FromStablePhotoItem {
  unsplash_photo_id: string;
  image_url: string;
  attribution_text: string;
  attribution_url: string;
  download_location: string;
  color?: string;
}

export interface FromStableRequest {
  photos: FromStablePhotoItem[];
}



