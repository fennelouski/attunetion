# Deployment Guide

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Vercel CLI**: Install globally with `npm i -g vercel`
3. **OpenAI API Key**: Get from [platform.openai.com](https://platform.openai.com)

## Step 1: Install Dependencies

```bash
cd attunetion-backend
npm install
```

## Step 2: Set Up Environment Variables

Create a `.env` file in the project root (or set in Vercel dashboard):

```bash
OPENAI_API_KEY=sk-your-key-here
API_SECRET_KEY=your-secret-key-here  # Optional for MVP
RATE_LIMIT_ENABLED=true
```

## Step 3: Test Locally

```bash
npm run dev
```

Test the health endpoint:
```bash
curl http://localhost:3000/api/health
```

## Step 4: Deploy to Vercel

### Option A: Using Vercel CLI

```bash
# Login to Vercel
vercel login

# Deploy (follow prompts)
vercel

# For production deployment
vercel --prod
```

### Option B: Using Vercel Dashboard

1. Push your code to GitHub/GitLab/Bitbucket
2. Go to [vercel.com/new](https://vercel.com/new)
3. Import your repository
4. Vercel will auto-detect the project settings
5. Add environment variables in the dashboard

## Step 5: Configure Environment Variables in Vercel

1. Go to your project dashboard on Vercel
2. Navigate to **Settings** → **Environment Variables**
3. Add the following:
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `API_SECRET_KEY`: (Optional) Your API secret key
   - `RATE_LIMIT_ENABLED`: `true`

## Step 6: Verify Deployment

After deployment, you'll get a URL like: `https://your-project.vercel.app`

Test the health endpoint:
```bash
curl https://your-project.vercel.app/api/health
```

Test an AI endpoint:
```bash
curl -X POST https://your-project.vercel.app/api/ai/generate-theme \
  -H "Content-Type: application/json" \
  -d '{"intentionText": "Be kind to others"}'
```

## Step 7: Share with iOS Team

Provide the iOS team with:
1. **Production URL**: `https://your-project.vercel.app`
2. **API Documentation**: See `README.md`
3. **API Key** (if using authentication): The `API_SECRET_KEY` value

## Troubleshooting

### Function Timeout Errors

If you see timeout errors, check:
- OpenAI API response times
- Increase function timeout in `vercel.json` if needed

### CORS Errors

CORS is configured in `vercel.json`. If you see CORS errors:
1. Check that headers are properly set
2. Verify the request includes proper headers
3. Check browser console for specific CORS error

### Environment Variables Not Working

1. Ensure variables are set in Vercel dashboard (not just `.env` file)
2. Redeploy after adding new environment variables
3. Check variable names match exactly (case-sensitive)

### OpenAI API Errors

1. Verify `OPENAI_API_KEY` is correct
2. Check OpenAI account has sufficient credits
3. Check OpenAI API status page

## Production Checklist

- [ ] Environment variables configured in Vercel
- [ ] Health endpoint responding
- [ ] All AI endpoints tested
- [ ] Rate limiting working
- [ ] CORS configured correctly
- [ ] Error handling tested
- [ ] Production URL shared with iOS team
- [ ] API documentation updated with production URL



