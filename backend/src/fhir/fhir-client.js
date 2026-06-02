const axios = require('axios');
const { decrypt } = require('../auth/ihce-oauth');

class FhirClient {
  constructor(baseUrl) {
    this.baseUrl = baseUrl || process.env.IHCE_FHIR_BASE_URL;
  }

  async getPatient(id, encryptedToken) {
    const token = decrypt(encryptedToken);
    try {
      const response = await axios.get(`${this.baseUrl}/Patient/${id}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/fhir+json'
        }
      });
      return response.data;
    } catch (error) {
      console.error(`Error fetching Patient ${id}:`, error.response?.data || error.message);
      throw error;
    }
  }

  async getRDA(patientId, encryptedToken) {
    const token = decrypt(encryptedToken);
    try {
      // Composition with type RDA (Resumen Digital de Atención)
      // Reference: https://co.fhir.guide/core/
      const response = await axios.get(`${this.baseUrl}/Composition`, {
        params: {
          patient: patientId,
          type: 'http://loinc.org|60591-5' // Example LOINC for Patient summary
        },
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/fhir+json'
        }
      });
      return response.data;
    } catch (error) {
      console.error(`Error fetching RDA for Patient ${patientId}:`, error.response?.data || error.message);
      throw error;
    }
  }

  async searchPatient(params, encryptedToken) {
    const token = decrypt(encryptedToken);
    try {
      const response = await axios.get(`${this.baseUrl}/Patient`, {
        params: params,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/fhir+json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error searching patient:', error.response?.data || error.message);
      throw error;
    }
  }
}

module.exports = { FhirClient };
