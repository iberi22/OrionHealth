const express = require('express');
const { authMiddleware, verifyPatientOwnership } = require('../middleware/auth');
const { asyncHandler } = require('../utils/errorHandler');
const { FhirClient } = require('../fhir/fhir-client');
const { RdaParser } = require('../fhir/rda-parser');

const router = express.Router();
const fhirClient = new FhirClient();

// Get Patient by ID (supports case-insensitive route params or casing variants)
router.get(['/patient/:id', '/Patient/:id'], authMiddleware, verifyPatientOwnership, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const tokenData = req.session.tokenData;
  const patient = await fhirClient.getPatient(id, tokenData.accessToken);
  res.json(patient);
}));

// Get RDA (Resumen Digital de Atención)
router.get(['/rda', '/RDA'], authMiddleware, asyncHandler(async (req, res) => {
  const tokenData = req.session.tokenData;
  const rdaBundle = await fhirClient.getRDA(tokenData.patient, tokenData.accessToken);
  const parsedRda = RdaParser.parse(rdaBundle);
  res.json(parsedRda || rdaBundle);
}));

module.exports = router;
