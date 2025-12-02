/**
 * Simple in-memory database for MVP
 * In production, replace with Vercel Postgres or similar
 */

import { Intention, CreateIntentionRequest, UpdateIntentionRequest } from "../types";

// In-memory store (will reset on serverless function restart)
const intentionsStore = new Map<string, Intention>();

/**
 * Get all intentions for a user
 */
export function getIntentionsByUserId(userId: string): Intention[] {
  return Array.from(intentionsStore.values()).filter(
    (intention) => intention.userId === userId
  );
}

/**
 * Get a single intention by ID
 */
export function getIntentionById(id: string): Intention | undefined {
  return intentionsStore.get(id);
}

/**
 * Create a new intention
 */
export function createIntention(data: CreateIntentionRequest): Intention {
  const intention: Intention = {
    id: crypto.randomUUID(),
    userId: data.userId,
    text: data.text,
    scope: data.scope,
    date: data.date,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    themeId: data.themeId,
    customFont: data.customFont,
    aiGenerated: data.aiGenerated || false,
    aiRephrased: false,
    quote: data.quote,
  };

  intentionsStore.set(intention.id, intention);
  return intention;
}

/**
 * Update an existing intention
 */
export function updateIntention(
  id: string,
  data: UpdateIntentionRequest
): Intention | null {
  const existing = intentionsStore.get(id);
  if (!existing) {
    return null;
  }

  const updated: Intention = {
    ...existing,
    ...data,
    updatedAt: new Date().toISOString(),
  };

  intentionsStore.set(id, updated);
  return updated;
}

/**
 * Delete an intention
 */
export function deleteIntention(id: string): boolean {
  return intentionsStore.delete(id);
}

/**
 * Check if intention belongs to user
 */
export function belongsToUser(intentionId: string, userId: string): boolean {
  const intention = intentionsStore.get(intentionId);
  return intention?.userId === userId;
}

