import { defineMiddleware } from 'astro:middleware';
import { withSecurityHeaders } from './lib/securityHeaders';

export const onRequest = defineMiddleware(async (_context, next) => {
  const response = await next();
  if (response.status === 101) {
    return response;
  }
  // Applies all security headers including Content-Security-Policy-Report-Only
  return withSecurityHeaders(response);
});
