# Gemini Cloud API Setup

Follow these steps to enable Gemini Cloud API as the fallback for the RAG pipeline.

1. Open [Google AI Studio API keys](https://aistudio.google.com/apikey).
2. Sign in with your Google account.
3. Create a new API key.
4. Copy the key into the project root `.env` file:

```env
GEMINI_API_KEY=your-gemini-api-key-here
```

5. Save the file and restart the app so the environment variable is loaded.

## Free Tier Limits

For `Gemini 2.0 Flash`, the current free tier limits are:

* 15 requests per minute (RPM)
* 200 requests per day (RPD)

These limits come from the official Gemini API rate limits page:
https://ai.google.dev/gemini-api/docs/rate-limits

## Notes

* Keep `.env` out of version control.
* The app will use local Gemma first when available, then fall back to Gemini Cloud API.
* If the key is missing, cloud fallback remains disabled.
