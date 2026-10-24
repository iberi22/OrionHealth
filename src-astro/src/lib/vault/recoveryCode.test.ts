import { describe, it, expect } from 'vitest';
import { newRecoveryCode, formatCode, parseCode, wrapMrsWithCode, unwrapMrsWithCode, pickConfirmationGroups, RecoveryCodeError } from './recoveryCode.ts';
import { randomBytes } from '../crypto/index.ts';

describe('recoveryCode', () => {
  it('should generate a 32-byte recovery code', () => {
    const code = newRecoveryCode();
    expect(code).toBeInstanceOf(Uint8Array);
    expect(code.length).toBe(32);
  });

  it('should format and parse code successfully', async () => {
    const bytes = randomBytes(32);
    const formatted = await formatCode(bytes);

    // Check format (54 chars without hyphens = 14 groups. Last group is 2 chars. 13*4+2 = 54)
    // 54 chars -> 13 hyphens -> 67 chars total
    expect(formatted.length).toBe(67);
    expect(formatted.split('-').length).toBe(14);

    const parsed = await parseCode(formatted);
    expect(parsed).toEqual(bytes);
  });

  it('parseCode should handle spaces, dashes, lowercase, and O/I/L mappings', async () => {
    const bytes = randomBytes(32);
    const formatted = await formatCode(bytes);

    // Manipulate formatted string to test mappings
    let modified = formatted
      .replace(/-/g, ' ')
      .toLowerCase();

    if (modified.includes('0')) modified = modified.replace(/0/g, 'o');
    if (modified.includes('1')) modified = modified.replace(/1/g, 'l');

    const parsed = await parseCode(modified);
    expect(parsed).toEqual(bytes);
  });

  it('parseCode should reject bad characters', async () => {
    await expect(parseCode('invalid-chars-*')).rejects.toThrow(
      new RecoveryCodeError('Invalid characters in code', 'BAD_CHARACTERS')
    );
  });

  it('parseCode should reject invalid checksum (BAD_CHECKSUM)', async () => {
    const bytes = randomBytes(32);
    const formatted = await formatCode(bytes);

    // Mess with the string to cause bad checksum
    const parts = formatted.split('');
    // Flip first character from valid alphabet to another valid character
    const oldChar = parts[0];
    parts[0] = oldChar === '0' ? '1' : '0';

    await expect(parseCode(parts.join(''))).rejects.toThrow(
      new RecoveryCodeError('Checksum mismatch', 'BAD_CHECKSUM')
    );
  });

  it('should wrap and unwrap MRS successfully', async () => {
    const codeBytes = newRecoveryCode();
    const formattedCode = await formatCode(codeBytes);

    const mrs = randomBytes(32);
    const memberId = 'member123';

    const blob = await wrapMrsWithCode(formattedCode, mrs, memberId);
    expect(typeof blob).toBe('string');

    const unwrapped = await unwrapMrsWithCode(formattedCode, blob, memberId);
    expect(unwrapped).toEqual(mrs);
  });

  it('unwrap should fail with wrong memberId or code', async () => {
    const codeBytes = newRecoveryCode();
    const formattedCode = await formatCode(codeBytes);

    const mrs = randomBytes(32);
    const memberId = 'member123';

    const blob = await wrapMrsWithCode(formattedCode, mrs, memberId);

    // Wrong memberId
    await expect(unwrapMrsWithCode(formattedCode, blob, 'wrong-member')).rejects.toThrow();

    // Wrong code
    const wrongCode = await formatCode(randomBytes(32));
    await expect(unwrapMrsWithCode(wrongCode, blob, memberId)).rejects.toThrow();
  });

  it('should pick confirmation groups', async () => {
    const codeBytes = newRecoveryCode();
    const formattedCode = await formatCode(codeBytes);

    const groups = pickConfirmationGroups(formattedCode, 3);

    expect(groups.length).toBe(3);
    expect(new Set(groups).size).toBe(3); // unique
    expect(groups[0]).toBeGreaterThanOrEqual(0);
    expect(groups[2]).toBeLessThan(formattedCode.split('-').length);
    expect(groups[0]).toBeLessThan(groups[1]);
    expect(groups[1]).toBeLessThan(groups[2]); // sorted
  });
});
