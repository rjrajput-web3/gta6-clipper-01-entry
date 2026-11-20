#!/usr/bin/env bash
# Build the gta6-clipper-01 entry clip from Rockstar's GTA VI Trailer 2.
#
# Usage: ./build-clip.sh <trailer-1080p.mp4> <output.mp4>
#
# Creative decisions (made by the agent in the build session):
# - Source: Rockstar's official Grand Theft Auto VI Trailer 2
#   (https://www.youtube.com/watch?v=VQRLujxTm3c), 1080p.
# - The trailer's most exciting moments were picked by watching
#   timestamped frames and a scene-change scan of the whole trailer.
#   Trailer 2 cuts fast (most shots last 1-3 s), so the clip is a
#   rapid montage: the plane heist, Lucia's red-lit robbery, the
#   nightclub, the highway chase, the roof jump, the store robbery
#   and Jason driving. (The boat chase with sparks was checked and
#   cut: it lasts under half a second in the trailer, too short to
#   open on.)
# - Structure: ~19 s of fast action hooks, then ~14 s of make.fun
#   pitch over the bar, the dusk skyline and the GTA VI logo card.
# - Vertical 9:16 (1080x1920) via a centre crop, so the clip is a
#   YouTube Short (under 60 s). On-screen text carries the pitch;
#   the trailer's own audio is kept and levelled to -14 LUFS.
# - Pitch text sits in the top third so it never covers the action
#   in the centre of the frame or the GTA VI logo on the end card,
#   and every line is sized to fit inside the 1080 px frame.
# - Two passes: each segment is cut and cropped on its own first
#   (keeps peak memory low), then the segments are joined and the
#   text and audio levelling are applied in one final encode.
#
# The encode is deterministic: fixed creation-time metadata and
# fixed x264 settings, so two back-to-back runs produce identical
# decoded frames (verified with framemd5).

set -euo pipefail

SRC="${1:?usage: build-clip.sh <trailer.mp4> <output.mp4>}"
OUT="${2:?usage: build-clip.sh <trailer.mp4> <output.mp4>}"
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Segments: source start and duration (seconds). Clip time follows in order.
#   119.6 +1.3 plane heist                (hook)
#    75.0 +1.9 Lucia's red-lit robbery
#   100.0 +5.0 nightclub
#    34.6 +3.8 highway chase, plane above
#    11.6 +2.0 Jason's roof jump
#    52.0 +2.0 store robbery
#    28.0 +3.0 Jason driving
#    92.0 +3.0 bar, pitch starts
#   154.0 +2.0 dusk skyline, pitch
#   158.0 +8.8 GTA VI logo card, pitch
# Total: 32.8 s. Pitch runs 19.0-32.8 s. Hook text runs 0-3.2 s.
SEGMENTS=(
  "119.6 1.3"
  "75.0 1.9"
  "100.0 5.0"
  "34.6 3.8"
  "11.6 2.0"
  "52.0 2.0"
  "28.0 3.0"
  "92.0 3.0"
  "154.0 2.0"
  "158.0 8.8"
)

# Pass 1: cut and crop each segment on its own.
i=0
for spec in "${SEGMENTS[@]}"; do
  set -- $spec
  ffmpeg -y -v error -ss "$1" -i "$SRC" -t "$2" \
    -vf "crop=608:1080:(in_w-608)/2:0,scale=1080:1920,fps=30" \
    -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -r 30 \
    -c:a aac -b:a 192k \
    -metadata creation_time="2026-11-21T03:30:00.000000Z" \
    -metadata:s:v:0 creation_time="2026-11-21T03:30:00.000000Z" \
    -metadata:s:a:0 creation_time="2026-11-21T03:30:00.000000Z" \
    "$WORK/seg_$(printf %02d $i).mp4"
  echo "file '$WORK/seg_$(printf %02d $i).mp4'" >> "$WORK/list.txt"
  i=$((i + 1))
done

# Pass 2: join, add the on-screen text and level the audio.
ffmpeg -y -v error -f concat -safe 0 -i "$WORK/list.txt" -filter_complex "
[0:v]drawtext=fontfile=$FONT:text='GTA 6 IS INSANE':fontsize=100:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=20:x=(w-text_w)/2:y=180:enable='between(t,0,3.2)'[vhook];
[vhook]drawtext=fontfile=$FONT:text='MAKE CLIPS LIKE THIS':fontsize=56:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=240:enable='between(t,19.0,32.8)'[vp1];
[vp1]drawtext=fontfile=$FONT:text='WITH AI AND EARN MONEY':fontsize=50:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=340:enable='between(t,19.0,32.8)'[vp2];
[vp2]drawtext=fontfile=$FONT:text='ON MAKE.FUN':fontsize=88:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=440:enable='between(t,19.0,32.8)'[vp3];
[vp3]drawtext=fontfile=$FONT:text='make.fun/bounty/gta6-clipper-01':fontsize=48:fontcolor=0xFFD23F:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=590:enable='between(t,19.0,32.8)'[vout];
[0:a]aresample=48000,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=in:st=0:d=0.2,afade=t=out:st=31.8:d=1.0[aout]
" -map "[vout]" -map "[aout]" \
  -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 192k \
  -metadata creation_time="2026-11-21T03:30:00.000000Z" \
  -metadata:s:v:0 creation_time="2026-11-21T03:30:00.000000Z" \
  -metadata:s:a:0 creation_time="2026-11-21T03:30:00.000000Z" \
  -movflags +faststart "$OUT"

echo "built $OUT"
