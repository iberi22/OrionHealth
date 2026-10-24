export const SECURITY_HEADERS: Record<string, string> = {
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'X-Content-Type-Options': 'nosniff',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'X-Frame-Options': 'DENY',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
};

/**
 * Returns a copy of the response with security headers applied.
 * Existing headers are never overwritten.
 * Responses with status 101 (e.g. WebSocket upgrade) are returned unchanged.
 */
/** Report-only policy for responses without Astro's CSP: connections, images, framing; scripts are Astro's. */
export function fallbackPolicy(signalingUrl: string | undefined = import.meta.env?.PUBLIC_SIGNALING_URL): string {
  const connect = ["'self'", 'wss://signal.orionhealth.swal.network'];
  if (signalingUrl && !connect.includes(signalingUrl)) connect.push(signalingUrl);
  return `connect-src ${connect.join(' ')}; img-src 'self' data:; frame-ancestors 'none'; report-uri /api/csp-report`;
}

export function withSecurityHeaders(response: Response): Response {
  if (response.status === 101) {
    return response;
  }

  const headers = new Headers(response.headers);
  for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
    if (!headers.has(name)) {
      headers.set(name, value);
    }
  }

  // Intercept Astro's generated Content-Security-Policy header and convert it to Report-Only
  const astroCsp = headers.get('Content-Security-Policy');
  if (astroCsp) {
    headers.delete('Content-Security-Policy');
    const hasReportUri = astroCsp.includes('report-uri');
    const newCsp = hasReportUri ? astroCsp : `${astroCsp}; report-uri /api/csp-report`;
    headers.set('Content-Security-Policy-Report-Only', newCsp);
  } else if (!headers.has('Content-Security-Policy-Report-Only')) {
    // Prerendered pages carry Astro's CSP (script/style hashes) in a <meta> tag; this header must not
    // add a second script policy that would flag those same scripts. It covers the other directives.
    headers.set('Content-Security-Policy-Report-Only', fallbackPolicy());
  }

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
