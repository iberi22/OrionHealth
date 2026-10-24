import type { APIRoute } from 'astro';

const violationCounts = new Map<string, number>();

export const POST: APIRoute = async ({ request }) => {
  try {
    const text = await request.text();
    const data = JSON.parse(text);

    // Extract the violated directive from 'csp-report' which is the standard envelope
    const report = data['csp-report'] || data;
    const directive = report['violated-directive'];

    if (typeof directive === 'string') {
      const count = (violationCounts.get(directive) || 0) + 1;
      violationCounts.set(directive, count);
      console.warn(`[CSP Violation] directive: ${directive}, count: ${count}`);
    }
  } catch (err) {
    // Ignore JSON parse errors or other issues
    // Do not log URL or body to avoid personal data leaks
  }

  // Always return 204 No Content
  return new Response(null, { status: 204 });
};
