import { describe, it, expect, vi, beforeEach } from 'vitest';
import { POST, getViolationCounts, clearViolationCounts } from './csp-report';

describe('CSP Report Endpoint', () => {
  beforeEach(() => {
    clearViolationCounts();
    vi.spyOn(console, 'warn').mockImplementation(() => {});
  });

  it('tracks valid directives', async () => {
    const report = {
      'csp-report': {
        'violated-directive': 'script-src'
      }
    };

    const request = new Request('http://localhost/api/csp-report', {
      method: 'POST',
      body: JSON.stringify(report)
    });

    const response = await POST({ request } as any);
    expect(response.status).toBe(204);

    const counts = getViolationCounts();
    expect(counts.get('script-src')).toBe(1);
    expect(console.warn).toHaveBeenCalledWith('[CSP Violation] directive: script-src, count: 1');
  });

  it('ignores unknown directives', async () => {
    const report = {
      'csp-report': {
        'violated-directive': 'unknown-directive-xyz'
      }
    };

    const request = new Request('http://localhost/api/csp-report', {
      method: 'POST',
      body: JSON.stringify(report)
    });

    const response = await POST({ request } as any);
    expect(response.status).toBe(204);

    const counts = getViolationCounts();
    expect(counts.has('unknown-directive-xyz')).toBe(false);
    expect(console.warn).not.toHaveBeenCalled();
  });

  it('ignores overly long directives', async () => {
    // Known directive but artificially long
    const longDirective = 'script-src' + 'a'.repeat(100);
    const report = {
      'csp-report': {
        'violated-directive': longDirective
      }
    };

    const request = new Request('http://localhost/api/csp-report', {
      method: 'POST',
      body: JSON.stringify(report)
    });

    const response = await POST({ request } as any);
    expect(response.status).toBe(204);

    const counts = getViolationCounts();
    expect(counts.has(longDirective)).toBe(false);
    expect(console.warn).not.toHaveBeenCalled();
  });

  it('ignores malformed JSON', async () => {
    const request = new Request('http://localhost/api/csp-report', {
      method: 'POST',
      body: 'invalid-json'
    });

    const response = await POST({ request } as any);
    expect(response.status).toBe(204);

    const counts = getViolationCounts();
    expect(counts.size).toBe(0);
    expect(console.warn).not.toHaveBeenCalled();
  });

  it('handles unwrapped reports', async () => {
    const report = {
      'violated-directive': 'style-src'
    };

    const request = new Request('http://localhost/api/csp-report', {
      method: 'POST',
      body: JSON.stringify(report)
    });

    const response = await POST({ request } as any);
    expect(response.status).toBe(204);

    const counts = getViolationCounts();
    expect(counts.get('style-src')).toBe(1);
    expect(console.warn).toHaveBeenCalledWith('[CSP Violation] directive: style-src, count: 1');
  });
});
