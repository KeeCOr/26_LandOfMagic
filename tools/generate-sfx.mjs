import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const sampleRate = 44100;

function writeWav(path, seconds, render) {
  const frames = Math.floor(sampleRate * seconds);
  const buffer = Buffer.alloc(44 + frames * 2);
  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + frames * 2, 4);
  buffer.write('WAVEfmt ', 8);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(1, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * 2, 28);
  buffer.writeUInt16LE(2, 32);
  buffer.writeUInt16LE(16, 34);
  buffer.write('data', 36);
  buffer.writeUInt32LE(frames * 2, 40);
  for (let i = 0; i < frames; i += 1) {
    const value = Math.max(-1, Math.min(1, render(i / sampleRate, i / frames)));
    buffer.writeInt16LE(Math.round(value * 32767), 44 + i * 2);
  }
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, buffer);
}

const out = resolve('assets/generated/audio');
writeWav(resolve(out, 'lm-projectile-launch-v1.wav'), 0.16, (t, p) => Math.sin(2 * Math.PI * (680 - p * 270) * t) * (1 - p) * 0.23);
writeWav(resolve(out, 'lm-impact-v1.wav'), 0.13, (t, p) => (Math.sin(2 * Math.PI * 120 * t) + Math.sin(2 * Math.PI * 245 * t) * 0.45) * (1 - p) * (1 - p) * 0.28);
writeWav(resolve(out, 'lm-heal-v1.wav'), 0.36, (t, p) => Math.sin(2 * Math.PI * (390 + p * 340) * t) * Math.sin(Math.PI * p) * 0.18);
writeWav(resolve(out, 'lm-clue-discovered-v1.wav'), 0.46, (t, p) => (Math.sin(2 * Math.PI * 523.25 * t) + Math.sin(2 * Math.PI * 659.25 * Math.max(0, t - 0.12))) * Math.sin(Math.PI * Math.min(1, p * 1.35)) * (1 - p * 0.45) * 0.13);
