import { describe, it, expect } from 'vitest';
import { createHlc, compareHlc } from './hlc.js';

describe('hlc', () => {
  it('creates valid hlc string', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.now()).toBe('1696200000000-0000-devA');
  });

  it('tick increments counter if in same millisecond', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.now()).toBe('1696200000000-0000-devA');
    expect(hlc.tick()).toBe('1696200000000-0001-devA');
    expect(hlc.tick()).toBe('1696200000000-0002-devA');
  });

  it('tick uses new millisecond and resets counter', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.tick()).toBe('1696200000000-0001-devA');

    now += 5;
    expect(hlc.tick()).toBe('1696200000005-0000-devA');
  });

  it('tick maintains monotonicity if clock goes backwards', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);
    expect(hlc.tick()).toBe('1696200000000-0001-devA');

    now -= 1000; // clock backwards by 1 second
    expect(hlc.tick()).toBe('1696200000000-0002-devA');
  });

  it('receive handles remote in future', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000005-0000-devB');
    expect(res).toBe('1696200000005-0001-devA');
  });

  it('receive handles remote in past', () => {
    let now = 1696200000005;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000000-0000-devB');
    expect(res).toBe('1696200000005-0001-devA');
  });

  it('receive handles same millisecond remote', () => {
    let now = 1696200000000;
    const hlc = createHlc('devA', () => now);

    const res = hlc.receive('1696200000000-0005-devB');
    expect(res).toBe('1696200000000-0006-devA');
  });

  it('compareHlc sorts correctly', () => {
    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0000-devA')).toBe(0);
    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0001-devA')).toBe(-1);
    expect(compareHlc('1696200000000-0001-devA', '1696200000000-0000-devA')).toBe(1);

    expect(compareHlc('1696200000000-0000-devA', '1696200000005-0000-devA')).toBe(-1);

    expect(compareHlc('1696200000000-0000-devA', '1696200000000-0000-devB')).toBe(-1);
    expect(compareHlc('1696200000000-0000-devB', '1696200000000-0000-devA')).toBe(1);
  });
});
