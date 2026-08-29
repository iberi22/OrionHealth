/**
 * Authentication and Authorization Middlewares
 */

function authMiddleware(req, res, next) {
  const tokenData = req.session ? req.session.tokenData : null;
  if (!tokenData || !tokenData.patient) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  req.user = {
    id: tokenData.patient,
    isAdmin: Boolean(tokenData.isAdmin)
  };

  next();
}

function verifyPatientOwnership(req, res, next) {
  const targetPatientId = req.params.id || req.params.patientId || req.body?.patientId;

  if (targetPatientId && req.user.id !== targetPatientId && !req.user.isAdmin) {
    return res.status(403).json({ error: 'forbidden' });
  }

  next();
}

module.exports = {
  authMiddleware,
  verifyPatientOwnership
};
