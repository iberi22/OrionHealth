# OrionHealth Telegram Support Bot

This edge function powers the OrionHealth support system via Telegram, automatically creating GitHub issues for user feedback, bug reports, and feature requests.

## Architecture

```
User → Telegram Bot → Edge Function → GitHub Issues API
                           ↓
                    Classification Logic
                    (keywords-based)
```

## Setup Instructions

### 1. Create Telegram Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` and follow the instructions
3. Copy the bot token (looks like `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`)
4. Save it as `TELEGRAM_BOT_TOKEN` environment variable

### 2. Create GitHub Personal Access Token

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (for creating issues)
4. Copy the token and save it as `GITHUB_TOKEN` environment variable

### 3. Deploy Edge Function

#### Option A: Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd functions/telegram-bot
vercel
```

Set environment variables in Vercel Dashboard:
- `TELEGRAM_BOT_TOKEN`
- `GITHUB_TOKEN`

#### Option B: Supabase Edge Functions

```bash
# Link project
supabase link --project-ref your-project-ref

# Deploy function
supabase functions deploy telegram-bot
```

Set secrets:
```bash
supabase secrets set TELEGRAM_BOT_TOKEN=your_token
supabase secrets set GITHUB_TOKEN=your_token
```

#### Option C: Cloudflare Workers

```bash
# Create wrangler.toml
wrangler publish
```

### 4. Set Telegram Webhook

```bash
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://your-function-url.vercel.app/api/telegram-bot"}'
```

## Bot Commands

| Command | Description |
|---------|-------------|
| `/start` | Welcome message and instructions |
| `/bug <description>` | Report a bug |
| `/feature <description>` | Request a feature |
| `/feedback <description>` | Send general feedback |
| `/status` | Check bot status |

Users can also just send a message without commands - the bot will auto-classify it based on keywords.

## Classification Keywords

| Type | Keywords |
|------|----------|
| Bug | bug, error, crash, broken, not working, fail |
| Feature | feature, request, add, implement, suggestion |
| Question | how, what, why, when, can i, is it possible |
| Feedback | (default for unclassified messages) |

## GitHub Labels

Issues are automatically labeled with:
- `from-telegram` - Source indicator
- `triage` - Needs review
- Type-specific label (`bug`, `enhancement`, `feedback`, `question`)

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `TELEGRAM_BOT_TOKEN` | Bot token from @BotFather | Yes |
| `GITHUB_TOKEN` | GitHub PAT with `repo` scope | Yes |

## Security Considerations

1. **Token Security**: Never commit tokens to version control
2. **Rate Limiting**: Consider implementing rate limits to prevent spam
3. **Validation**: The bot validates webhook payloads from Telegram
4. **Privacy**: User Telegram IDs are not stored, only used for issue creation

## Testing Locally

```bash
# Install dependencies
npm install

# Run with environment variables
TELEGRAM_BOT_TOKEN=xxx GITHUB_TOKEN=xxx npx ts-node index.ts
```

Use [ngrok](https://ngrok.com/) to expose local server for webhook testing.

## Future Improvements

- [ ] Add spam detection
- [ ] Implement conversation threads for follow-ups
- [ ] Add screenshot/attachment support
- [ ] Multi-language classification
- [ ] Issue status notifications back to users
