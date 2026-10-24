import { describe, it, expect } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { SECURITY_HEADERS, withSecurityHeaders } from './securityHeaders';
import { onRequest } from '../middleware';

describe('Security Headers', () => {
  it('CSP Report-Only uses the correct inline script hash', () => {
    // Read the SiteLayout.astro file to extract the script content
    const layoutPath = fs.existsSync(path.resolve(process.cwd(), 'src/layouts/SiteLayout.astro'))
      ? path.resolve(process.cwd(), 'src/layouts/SiteLayout.astro')
      : path.resolve(process.cwd(), 'src-astro/src/layouts/SiteLayout.astro');

    const layoutContent = fs.readFileSync(layoutPath, 'utf-8');
    const match = layoutContent.match(/<script is:inline>([\s\S]*?)<\/script>/);

    expect(match).not.toBeNull();
    const scriptContent = match![1];

    const hash = crypto.createHash('sha256').update(scriptContent).digest('base64');
    const expectedHash = `sha256-${hash}`;

    const csp = SECURITY_HEADERS['Content-Security-Policy-Report-Only'];
    expect(csp).toBeDefined();
    expect(csp).toContain(`'${expectedHash}'`);
    expect(csp).toContain('report-uri /api/csp-report');
  });

  it('middleware adds every security header to response', async () => {
    const rawResponse = new Response('Hello world', {
      status: 200,
      headers: { 'Content-Type': 'text/plain' },
    });

    const context = {} as any;
    const next = async () => rawResponse;
    const response = (await onRequest(context, next)) as Response;

    for (const [key, value] of Object.entries(SECURITY_HEADERS)) {
      expect(response.headers.get(key)).toBe(value);
    }
    expect(response.headers.get('Content-Type')).toBe('text/plain');
  });

  it('an existing header value is not overwritten', async () => {
    const customHsts = 'max-age=60';
    const customXfo = 'SAMEORIGIN';
    const rawResponse = new Response('Custom', {
      status: 200,
      headers: {
        'Strict-Transport-Security': customHsts,
        'X-Frame-Options': customXfo,
      },
    });

    const response = withSecurityHeaders(rawResponse);
    expect(response.headers.get('Strict-Transport-Security')).toBe(customHsts);
    expect(response.headers.get('X-Frame-Options')).toBe(customXfo);
    // Missing headers should still be added
    expect(response.headers.get('X-Content-Type-Options')).toBe('nosniff');
    expect(response.headers.get('Referrer-Policy')).toBe('strict-origin-when-cross-origin');
    expect(response.headers.get('Permissions-Policy')).toBe(SECURITY_HEADERS['Permissions-Policy']);
  });

  it('skips responses with status 101', async () => {
    const wsResponse = {
      status: 101,
      headers: new Headers({ Connection: 'Upgrade', Upgrade: 'websocket' }),
    } as unknown as Response;

    const context = {} as any;
    const next = async () => wsResponse;
    const response = (await onRequest(context, next)) as Response;

    expect(response.status).toBe(101);
    expect(response.headers.get('Strict-Transport-Security')).toBeNull();
    expect(response.headers.get('Upgrade')).toBe('websocket');
  });

  it('public/_headers contains every name: value of SECURITY_HEADERS to prevent drift', () => {
    const headersPath = fs.existsSync(path.resolve(process.cwd(), 'public/_headers'))
      ? path.resolve(process.cwd(), 'public/_headers')
      : path.resolve(process.cwd(), 'src-astro/public/_headers');
    expect(fs.existsSync(headersPath)).toBe(true);

    const content = fs.readFileSync(headersPath, 'utf-8');
    for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
      const line = `${name}: ${value}`;
      expect(content).toContain(line);
    }
  });
});
