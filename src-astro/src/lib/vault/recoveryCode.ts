import { randomBytes, sha256, hkdf, utf8, aesKey, sealBlob, openBlob } from '../crypto/index.ts';

const ALPHABET = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

export class RecoveryCodeError extends Error {
  code: string;
  constructor(message: string, code: string) {
    super(message);
    this.name = 'RecoveryCodeError';
    this.code = code;
  }
}

export function newRecoveryCode(): Uint8Array {
  return randomBytes(32);
}

export async function formatCode(bytes: Uint8Array): Promise<string> {
  if (bytes.length !== 32) {
    throw new RecoveryCodeError('Bytes must be exactly 32 bytes', 'INVALID_LENGTH');
  }

  const hash = await sha256(bytes);

  // 32 bytes = 256 bits
  // Checksum = 10 bits
  // Total = 266 bits
  const bitArray = new Uint8Array(34);
  bitArray.set(bytes);
  bitArray[32] = hash[0];
  bitArray[33] = hash[1] & 0b11000000; // Only first 2 bits from second byte needed for 10 bits

  // Calculate bit sequence for base32 mapping
  let result = '';
  let currentVal = 0;
  let currentBits = 0;

  // We need to read exactly 266 bits
  let bitsRead = 0;
  const totalBits = 266;

  for (let i = 0; i < bitArray.length && bitsRead < totalBits; i++) {
    const byte = bitArray[i];

    // Read bits from byte
    for (let bitIdx = 7; bitIdx >= 0 && bitsRead < totalBits; bitIdx--) {
      const bit = (byte >> bitIdx) & 1;
      currentVal = (currentVal << 1) | bit;
      currentBits++;
      bitsRead++;

      if (currentBits === 5) {
        result += ALPHABET[currentVal];
        currentVal = 0;
        currentBits = 0;
      }
    }
  }

  if (currentBits > 0) {
    currentVal = currentVal << (5 - currentBits);
    result += ALPHABET[currentVal];
  }

  // Insert hyphens every 4 chars
  const groups = result.match(/.{1,4}/g) || [];
  return groups.join('-');
}

export async function parseCode(text: string): Promise<Uint8Array> {
  let normalized = text
    .toUpperCase()
    .replace(/[-\s]/g, '')
    .replace(/[O]/g, '0')
    .replace(/[IL]/g, '1');

  if (!/^[0-9ABCDEFGHJKMNPQRSTVWXYZ]+$/.test(normalized)) {
    throw new RecoveryCodeError('Invalid characters in code', 'BAD_CHARACTERS');
  }

  // Base32 decode to bits
  let bitArray = new Uint8Array(34);
  let bitIndex = 0;

  for (let i = 0; i < normalized.length; i++) {
    const char = normalized[i];
    const val = ALPHABET.indexOf(char);

    // 54 chars * 5 bits = 270 bits, but we only have 266 bits of data.
    // The last char has 4 extra bits (we only need its top 1 bit).
    let bitsToRead = 5;
    if (i === normalized.length - 1) {
      bitsToRead = 1;
    }

    for (let b = 4; b >= 4 - bitsToRead + 1; b--) {
      const bit = (val >> b) & 1;
      const byteIdx = Math.floor(bitIndex / 8);
      const bitInByte = 7 - (bitIndex % 8);
      bitArray[byteIdx] |= (bit << bitInByte);
      bitIndex++;
    }
  }

  const bytes = bitArray.slice(0, 32);
  const checksumBits = new Uint8Array(2);
  checksumBits[0] = bitArray[32];
  checksumBits[1] = bitArray[33] & 0b11000000;

  const expectedHash = await sha256(bytes);

  if (checksumBits[0] !== expectedHash[0] || (checksumBits[1] & 0b11000000) !== (expectedHash[1] & 0b11000000)) {
    throw new RecoveryCodeError('Checksum mismatch', 'BAD_CHECKSUM');
  }

  return bytes;
}

export async function wrapMrsWithCode(code: string, mrs: Uint8Array, memberId: string): Promise<string> {
  const codeBytes = await parseCode(code);
  const hkdfKey = await hkdf(codeBytes, utf8(memberId), "orion/v1/recovery-code", 32);
  const key = await aesKey(hkdfKey);
  const aad = utf8("orion/v1/recovery|" + memberId);
  return sealBlob(key, mrs, aad);
}

export async function unwrapMrsWithCode(code: string, blob: string, memberId: string): Promise<Uint8Array> {
  const codeBytes = await parseCode(code);
  const hkdfKey = await hkdf(codeBytes, utf8(memberId), "orion/v1/recovery-code", 32);
  const key = await aesKey(hkdfKey);
  const aad = utf8("orion/v1/recovery|" + memberId);
  return openBlob(key, blob, aad);
}

export function pickConfirmationGroups(code: string, n: number): number[] {
  const groups = code.split('-');
  const numGroups = groups.length; // usually 14

  const indices = Array.from({ length: numGroups }, (_, i) => i);
  // Shuffle array
  for (let i = indices.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [indices[i], indices[j]] = [indices[j], indices[i]];
  }

  return indices.slice(0, n).sort((a, b) => a - b);
}
