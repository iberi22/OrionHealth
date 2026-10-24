import { describe, it, expect } from 'vitest';
import { createInvite, inviteUrl, parseInviteUrl, inviteRoom, computeSas, InviteError } from './invite';
import { generateBoxPair, b64u, randomBytes } from '../crypto/index';

describe('invite', () => {
  it('creates and encodes an invite', () => {
    const now = 1600000000000;
    const invite = createInvite('circle-123', now);
    expect(invite.c).toBe('circle-123');
    expect(invite.s).toBeTypeOf('string');
    expect(invite.e).toBe(now + 24 * 60 * 60 * 1000);

    const url = inviteUrl(invite);
    expect(url).toContain('https://orionhealth.swal.network/app/join#');

    // Test parsing the same url
    const parsed = parseInviteUrl(url, now);
    expect(parsed).toEqual(invite);
  });

  it('rejects expired invites', () => {
    const now = 1600000000000;
    const invite = createInvite('circle-123', now);
    const url = inviteUrl(invite);

    expect(() => parseInviteUrl(url, now + 24 * 60 * 60 * 1000 + 1)).toThrow(
      new InviteError('Invite has expired', 'INVITE_EXPIRED')
    );
  });

  it('rejects malformed urls', () => {
    const now = 1600000000000;
    expect(() => parseInviteUrl('not-a-url', now)).toThrow(
      new InviteError('Malformed invite URL', 'INVITE_MALFORMED')
    );
    expect(() => parseInviteUrl('https://example.com/join', now)).toThrow(
      new InviteError('Missing fragment', 'INVITE_MALFORMED')
    );
    expect(() => parseInviteUrl('https://example.com/join#!!badb64', now)).toThrow(
      new InviteError('Invalid fragment encoding', 'INVITE_MALFORMED')
    );
    expect(() => parseInviteUrl('https://example.com/join#' + b64u(new TextEncoder().encode('not-json')), now)).toThrow(
      new InviteError('Invalid JSON in fragment', 'INVITE_MALFORMED')
    );
    expect(() => parseInviteUrl('https://example.com/join#' + b64u(new TextEncoder().encode(JSON.stringify({ c: '1' }))), now)).toThrow(
      new InviteError('Missing required fields', 'INVITE_MALFORMED')
    );
  });

  it('generates a stable room ID', async () => {
    const secret = b64u(randomBytes(32));
    const room1 = await inviteRoom(secret);
    const room2 = await inviteRoom(secret);
    expect(room1).toBe(room2);
    expect(room1.length).toBeLessThanOrEqual(22); // base64url encoding of 32 bytes can be longer, wait - slice(0, 22)? Let's check length
    expect(room1.length).toBe(22);
  });

  it('computes a 6-digit SAS symmetrically', async () => {
    const secret = b64u(randomBytes(32));
    const pairA = await generateBoxPair();
    const pairB = await generateBoxPair();

    const sas1 = await computeSas(secret, pairA.publicSpki, pairB.publicSpki);
    const sas2 = await computeSas(secret, pairB.publicSpki, pairA.publicSpki);

    expect(sas1).toMatch(/^\d{3} \d{3}$/);
    expect(sas1).toBe(sas2);
  });
});
