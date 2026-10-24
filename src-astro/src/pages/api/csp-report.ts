import type { APIRoute } from 'astro';

const violationCounts = new Map<string, number>();

const KNOWN_DIRECTIVES = new Set([
  'default-src', 'script-src', 'style-src', 'img-src', 'connect-src',
  'font-src', 'object-src', 'media-src', 'frame-src', 'sandbox',
  'report-uri', 'child-src', 'form-action', 'frame-ancestors',
  'plugin-types', 'base-uri', 'report-to', 'worker-src',
  'manifest-src', 'prefetch-src', 'navigate-to',
  'require-trusted-types-for', 'trusted-types',
  'upgrade-insecure-requests', 'block-all-mixed-content',
  'script-src-elem', 'script-src-attr', 'style-src-elem', 'style-src-attr'
]);

export const POST: APIRoute = async ({ request }) => {
  try {
    const text = await request.text();
    const data = JSON.parse(text);

    // Extract the violated directive from 'csp-report' which is the standard envelope
    const report = data['csp-report'] || data;
    let directive = report['violated-directive'];

    if (typeof directive === 'string') {
      directive = directive.trim();

      // Keep only up to 64 characters and ensure it is a known directive
      if (directive.length <= 64 && KNOWN_DIRECTIVES.has(directive)) {
        const count = (violationCounts.get(directive) || 0) + 1;
        violationCounts.set(directive, count);
        console.warn(`[CSP Violation] directive: ${directive}, count: ${count}`);
      }
    }
  } catch (err) {
    // Ignore JSON parse errors or other issues
    // Do not log URL or body to avoid personal data leaks
  }

  // Always return 204 No Content
  return new Response(null, { status: 204 });
};

export const getViolationCounts = () => violationCounts;
export const clearViolationCounts = () => violationCounts.clear();
