/**
 * Global Error Handler Utilities
 */

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

function errorHandler(err, req, res, next) {
  // Log error internally for debugging without exposing PHI/PII
  console.error('[Error Handler]', err.message || err);

  const status = err.status || err.statusCode || 500;

  if (process.env.NODE_ENV === 'production') {
    return res.status(status).json({ error: 'internal_error' });
  }

  return res.status(status).json({
    error: err.message || 'internal_error',
    stack: err.stack
  });
}

module.exports = {
  asyncHandler,
  errorHandler
};
