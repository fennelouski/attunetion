# API_SECRET_KEY Setup Guide

## Current Status

✅ **OPENAI_API_KEY**: Already configured  
❓ **API_SECRET_KEY**: Not set (optional)

## Understanding API_SECRET_KEY

The `API_SECRET_KEY` is **completely optional**. It provides basic API protection:

- **If NOT set**: All requests are allowed (no authentication required)
- **If SET**: Requests must include the key in `X-API-Key` header

## Option 1: Leave Unset (Recommended for MVP/Testing)

**Pros:**
- ✅ No configuration needed
- ✅ Works immediately
- ✅ Good for MVP/testing phase
- ✅ iOS app already handles this case

**Cons:**
- ⚠️ No API protection (anyone can call your endpoints)
- ⚠️ Rate limiting still applies per IP/user

**Action Required:** None! Your backend will work as-is.

---

## Option 2: Set API_SECRET_KEY (Recommended for Production)

**Pros:**
- ✅ Basic API protection
- ✅ Prevents unauthorized access
- ✅ Better for production apps

**Cons:**
- ⚠️ Requires updating iOS app configuration
- ⚠️ Need to manage the secret key

### Generated Secure Key

```
bc67339cdabb7358191785dab821136615ad7cce6fccbb3bed6d818f016dcaa6
```

### Step 1: Set in Vercel Dashboard

1. Go to https://vercel.com/dashboard
2. Select your **attunetion** project
3. Navigate to **Settings** → **Environment Variables**
4. Click **Add New**
5. Enter:
   - **Key**: `API_SECRET_KEY`
   - **Value**: `bc67339cdabb7358191785dab821136615ad7cce6fccbb3bed6d818f016dcaa6`
   - **Environments**: Select **Production** (and **Preview** if desired)
6. Click **Save**
7. **Redeploy** your project (or wait for next deployment)

### Step 2: Update iOS App

The iOS app has been updated to check `Info.plist` first, then `UserDefaults`.

**Add to Info.plist:**

1. Open `Attunetion/Info.plist` in Xcode
2. Add this entry:
   ```xml
   <key>APISecretKey</key>
   <string>bc67339cdabb7358191785dab821136615ad7cce6fccbb3bed6d818f016dcaa6</string>
   ```

**Or set via UserDefaults (for testing):**

```swift
UserDefaults.standard.set("bc67339cdabb7358191785dab821136615ad7cce6fccbb3bed6d818f016dcaa6", forKey: "APISecretKey")
```

### Step 3: Test

After setting the key in Vercel and iOS app:

1. **Test without key** (should fail with 401):
   ```bash
   curl -X POST https://attunetion.vercel.app/api/ai/generate-theme \
     -H "Content-Type: application/json" \
     -d '{"intentionText": "test"}'
   ```

2. **Test with key** (should succeed):
   ```bash
   curl -X POST https://attunetion.vercel.app/api/ai/generate-theme \
     -H "Content-Type: application/json" \
     -H "X-API-Key: bc67339cdabb7358191785dab821136615ad7cce6fccbb3bed6d818f016dcaa6" \
     -d '{"intentionText": "test"}'
   ```

---

## Security Notes

⚠️ **Important**: The API key in `Info.plist` is visible in the app bundle. For production apps with sensitive data, consider:

1. **Server-side validation** (already implemented)
2. **Rate limiting** (already implemented - 50 requests/hour)
3. **User authentication** (future enhancement)
4. **Obfuscation** (advanced - not needed for MVP)

For MVP, this level of protection is sufficient.

---

## Current iOS App Behavior

The iOS app (`APIClient.swift`) checks for API key in this order:

1. ✅ `Info.plist` → `APISecretKey` key
2. ✅ `UserDefaults` → `APISecretKey` key  
3. ✅ Returns `nil` if not found (requests work without key)

If you set `API_SECRET_KEY` in Vercel, make sure to add it to `Info.plist` or the requests will fail with 401 Unauthorized.

---

## Recommendation

**For MVP/Testing**: Leave `API_SECRET_KEY` unset  
**For Production**: Set `API_SECRET_KEY` and add to `Info.plist`

Your backend is already configured to handle both cases! 🎉



