const axios = require('axios');
const crypto = require('crypto');
const dotenv = require('dotenv');

dotenv.config();

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY;
const IV_LENGTH = 16;

function encrypt(text) {
  if (!ENCRYPTION_KEY) {
    throw new Error('ENCRYPTION_KEY environment variable is not set');
  }
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
  let encrypted = cipher.update(text);
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decrypt(text) {
  if (!ENCRYPTION_KEY) {
    throw new Error('ENCRYPTION_KEY environment variable is not set');
  }
  const textParts = text.split(':');
  const iv = Buffer.from(textParts.shift(), 'hex');
  const encryptedText = Buffer.from(textParts.join(':'), 'hex');
  const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
  let decrypted = decipher.update(encryptedText);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  return decrypted.toString();
}

class IhceOAuth {
  constructor() {
    this.clientId = process.env.IHCE_CLIENT_ID;
    this.clientSecret = process.env.IHCE_CLIENT_SECRET;
    this.redirectUri = process.env.IHCE_REDIRECT_URI;
    this.authUrl = process.env.IHCE_AUTH_URL;
    this.tokenUrl = process.env.IHCE_TOKEN_URL;
  }

  getAuthUrl(state) {
    const params = new URLSearchParams({
      client_id: this.clientId,
      redirect_uri: this.redirectUri,
      response_type: 'code',
      scope: 'openid fhirUser patient/*.read',
      state: state
    });
    return `${this.authUrl}?${params.toString()}`;
  }

  async getTokenFromCode(code) {
    try {
      const response = await axios.post(this.tokenUrl, new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: this.redirectUri,
        client_id: this.clientId,
        client_secret: this.clientSecret
      }), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      });

      return {
        accessToken: encrypt(response.data.access_token),
        refreshToken: response.data.refresh_token ? encrypt(response.data.refresh_token) : null,
        expiresIn: response.data.expires_in,
        patient: response.data.patient // Some FHIR OAuth servers return the patient ID
      };
    } catch (error) {
      console.error('Error exchanging code for token:', error.response?.data || error.message);
      throw new Error('Failed to exchange authorization code for token');
    }
  }
}

module.exports = {
  IhceOAuth,
  encrypt,
  decrypt
};
