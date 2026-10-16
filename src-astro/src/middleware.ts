import { defineMiddleware } from 'astro:middleware';
import { withSecurityHeaders } from './lib/securityHeaders';

export const onRequest = defineMiddleware(async (_context, next) => {
  const response = await next();
  if (response.status === 101) {
    return response;
  }
  return withSecurityHeaders(response);
});
