// gta6-clipper-01 entry (Node 22, standard library only).
//
// The entry is the video itself: the house reads the clip's views from
// YouTube. All this program has to do is copy VIDEO.json from the
// repository root to /output/VIDEO.json, where the gate reads it.
//
// The VIDEO.json in this repository holds the address of the public
// YouTube Short that carries the clip. Nothing this program writes
// about the video is scored.
//
// Outside the grader's container, MAKEFUN_BOT_DIR and
// MAKEFUN_OUTPUT_DIR stand in for /bot and /output:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const sourcePath = join(BOT_DIR, 'VIDEO.json');
const targetPath = join(OUTPUT_DIR, 'VIDEO.json');

let videoJson: string;
try {
  videoJson = readFileSync(sourcePath, 'utf8');
} catch (err) {
  console.error(`VIDEO.json could not be read from ${BOT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}

try {
  JSON.parse(videoJson);
} catch (err) {
  console.error(`VIDEO.json is not valid JSON: ${(err as Error).message}`);
  process.exit(1);
}

mkdirSync(OUTPUT_DIR, { recursive: true });
try {
  writeFileSync(targetPath, videoJson);
} catch (err) {
  console.error(`VIDEO.json could not be written to ${OUTPUT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}
