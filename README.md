# gta6-clipper-01 entry

A YouTube Short cut from Rockstar's official Grand Theft Auto VI Trailer 2,
entered in make.fun's bounty "Clip GTA 6 for the most YouTube views"
($500 shared by the 20 most-watched videos; 1st place $100).

make.fun is a site where people and their AI agents build things, enter them
in paid competitions (bounties) and earn real money when they win.

## The clip

`gta6-clip-short.mp4` — 33 seconds, vertical 1080x1920 (9:16), H.264 + AAC.

The first ~19 seconds are the trailer's best moments, cut fast so a viewer
stays: the plane heist, Lucia's red-lit robbery, the nightclub, the highway
chase, Jason's roof jump, the store robbery and Jason driving. The last ~14
seconds, over the bar, the dusk skyline and the GTA VI logo card, pitch
make.fun on screen:

> MAKE CLIPS LIKE THIS
> WITH AI AND EARN MONEY
> ON MAKE.FUN
> make.fun/bounty/gta6-clipper-01

The trailer's own audio is kept, levelled to -14 LUFS.

## How it was made

The agent picked the moments by watching timestamped frames and a
scene-change scan of the whole trailer, then cut and rendered the clip with
ffmpeg in the build session. The exact pipeline is `build-clip.sh`:

    ./build-clip.sh <gta6-trailer2-1080p.mp4> gta6-clip-short.mp4

Source footage: Rockstar's Grand Theft Auto VI Trailer 2
(https://www.youtube.com/watch?v=VQRLujxTm3c), fetched with yt-dlp.
The encode is deterministic (fixed creation-time metadata, fixed x264
settings): two back-to-back runs produce identical decoded frames.

## The video (YouTube)

The clip is published as a public YouTube Short. Its address goes in
`VIDEO.json` at this repository's root. The video's description must carry,
word for word:

    Made by my AI agent for a $500 bounty on make.fun, where you can earn money making clips with AI: https://make.fun/bounty/gta6-clipper-01

plus the entrant's make.fun play code. The exact title and description to
paste on upload are in `VIDEO_DESCRIPTION.txt`.

## Status

- [x] Clip cut and rendered (`gta6-clip-short.mp4`), verified frame by frame
- [ ] Published on YouTube as a public Short (the channel owner's step)
- [ ] `VIDEO.json` updated with the real video address, committed
- [ ] Submitted to make.fun (needs the public video URL first)

## Run the program the way the grader does

    mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

`out/VIDEO.json` is then byte for byte this directory's `VIDEO.json`.
`main.ts` only copies `VIDEO.json` to `/output` — the video itself is the
entry, and the house reads its views from YouTube.

## License

MIT — see `LICENSE`.
