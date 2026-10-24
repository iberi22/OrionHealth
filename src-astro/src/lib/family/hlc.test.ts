import { describe, it, expect } from 'vitest';
import { createHlc, compareHlc } from './hlc.js';

describe('hlc', () => {
  it('creates valid hlc string', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.now()).toBe('1696200000000-00000000-devA');
  });

  it('tick increments counter if in same millisecond', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.now()).toBe('1696200000000-00000000-devA');
    expect(hlc.tick()).toBe('1696200000000-00000001-devA');
    expect(hlc.tick()).toBe('1696200000000-00000002-devA');
  });

  it('tick uses new millisecond and resets counter', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.tick()).toBe('1696200000000-00000001-devA');

    now += 5;
    expect(hlc.tick()).toBe('1696200000005-00000000-devA');
  });

  it('tick maintains monotonicity if clock goes backwards', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.tick()).toBe('1696200000000-00000001-devA');

    now -= 1000; // clock backwards by 1 second
    expect(hlc.tick()).toBe('1696200000000-00000002-devA');
  });

  it('receive handles remote in future', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000005-0000-devB');
    expect(res).toBe('1696200000005-00000001-devA');
  });

  it('receive handles remote in past', () => {
    let now = 1696200000005;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000000-0000-devB');
    expect(res).toBe('1696200000005-00000001-devA');
  });

  it('receive handles same millisecond remote', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000000-0005-devB');
    expect(res).toBe('1696200000000-00000006-devA');
  });

  it('compareHlc sorts correctly', () => {
    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0000-devA')).toBe(0);
    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0001-devA')).toBe(-1);
    expect(compareHlc('1696200000000-0001-devA', '1696200000000-0000-devA')).toBe(1);

    expect(compareHlc('1696200000000-0000-devA', '1696200000005-0000-devA')).toBe(-1);

    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0000-devB')).toBe(-1);
    expect(compareHlc('1696200000000-0000-devB', '1696200000000-0000-devA')).toBe(1);
  });

  it('compareHlc handles mixed widths', () => {
    // 4-digit vs 8-digit
    expect(compareHlc('1696200000000-0001-devA', '1696200000000-00000002-devA')).toBe(-1);
    expect(compareHlc('1696200000000-00000002-devA', '1696200000000-0001-devA')).toBe(1);

    // Since 0001 !== 00000001 as strings, compareHlc will return strings fallback a < b -> -1
    // so 00000001 is sorted before 0001
    expect(compareHlc('1696200000000-00000001-devA', '1696200000000-0001-devA')).toBe(-1);

    // String length should not mislead the sort if numerically larger
    expect(compareHlc('1696200000000-10000-devA', '1696200000000-9999-devA')).toBe(1); // 10000 > 9999
    expect(compareHlc('1696200000000-9999-devA', '1696200000000-10000-devA')).toBe(-1); // 9999 < 10000

    // New 8-digit width larger vs 4-digit
    expect(compareHlc('1696200000000-00009999-devA', '1696200000000-00010000-devA')).toBe(-1);
  });

  it('tick handles increments past 9999', () => {
    const now = 1696200000000;
    const hlc = createHlc('devA', () => now);

    // Trick the hlc by manually changing internal state via receive
    hlc.receive('1696200000000-00009999-devA');
    expect(hlc.now()).toBe('1696200000000-00010000-devA');
    expect(hlc.tick()).toBe('1696200000000-00010001-devA');
  });

  it('receives HLCs whose device id contains dashes', () => {
    const h = createHlc('dev-a', () => 1000);
    expect(() => h.receive('0000000002000-00000003-dev-b-1')).not.toThrow();
    expect(h.now().startsWith('0000000002000-00000004-')).toBe(true);
  });
});
