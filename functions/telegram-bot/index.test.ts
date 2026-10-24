import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import handler from './index';

describe('Telegram Bot Webhook Handler', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    vi.resetModules();
    process.env = {
      ...originalEnv,
      TELEGRAM_WEBHOOK_SECRET: 'test-secret',
      TELEGRAM_BOT_TOKEN: 'test-bot-token',
      GITHUB_TOKEN: 'test-github-token',
    };
    global.fetch = vi.fn();
  });

  afterEach(() => {
    process.env = originalEnv;
    vi.restoreAllMocks();
  });

  it('rejects with 401 when X-Telegram-Bot-Api-Secret-Token is missing', async () => {
    const request = new Request('https://example.com', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        update_id: 1,
        message: {
          message_id: 1,
          from: { id: 123, first_name: 'Test' },
          chat: { id: 456, type: 'private' },
          date: 1234567890,
          text: 'Hello',
        }
      })
    });

    const response = await handler(request);
    expect(response.status).toBe(401);
    expect(await response.text()).toBe('Unauthorized');
  });

  it('rejects with 401 when X-Telegram-Bot-Api-Secret-Token is incorrect', async () => {
    const request = new Request('https://example.com', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Telegram-Bot-Api-Secret-Token': 'wrong-secret'
      },
      body: JSON.stringify({
        update_id: 1,
        message: {
          message_id: 1,
          from: { id: 123, first_name: 'Test' },
          chat: { id: 456, type: 'private' },
          date: 1234567890,
          text: 'Hello',
        }
      })
    });

    const response = await handler(request);
    expect(response.status).toBe(401);
    expect(await response.text()).toBe('Unauthorized');
  });

  it('accepts the request when X-Telegram-Bot-Api-Secret-Token is correct', async () => {
    const request = new Request('https://example.com', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Telegram-Bot-Api-Secret-Token': 'test-secret'
      },
      body: JSON.stringify({
        update_id: 1,
        message: {
          message_id: 1,
          from: { id: 123, first_name: 'Test' },
          chat: { id: 456, type: 'private' },
          date: 1234567890,
          text: 'Hello',
        }
      })
    });

    // Mock fetch for GitHub issue creation and Telegram message sending
    (global.fetch as ReturnType<typeof vi.fn>).mockImplementation((url: string) => {
      if (url.includes('api.github.com')) {
        return Promise.resolve(new Response(JSON.stringify({ number: 123, html_url: 'https://github.com/issue/123' }), {
          status: 201,
          headers: { 'Content-Type': 'application/json' }
        }));
      }
      if (url.includes('api.telegram.org')) {
        return Promise.resolve(new Response('{}', { status: 200 }));
      }
      return Promise.resolve(new Response('OK', { status: 200 }));
    });

    const response = await handler(request);
    expect(response.status).toBe(200);
    expect(await response.text()).toBe('OK');
  });
});
