# Video engine reference

## Pinned upstream

- Source: https://github.com/SAOS-3624/dsh-video-storyboard
- Revision: `0c03a7d78307d7e8e2b8e6bcaa9d1673d79d3333` (tested)
- License: MIT, copyright belongs to the upstream contributors. We **do not vendor its code**; `setup-engine.sh` fetches and checks out that exact revision by user request. Preserve the upstream LICENSE/NOTICE when distributing its code.
- Evidence from earlier local validation: 328 upstream tests passed, 6 skipped, 0 failures; a local sample storyboard CLI smoke test succeeded. That does not guarantee each URL or speech recognition setup will work.

## Dependencies

- Bash, Git, Node.js 20+, `ffmpeg`, `ffprobe`: required.
- `yt-dlp`: required for public Bilibili/YouTube HTTP(S) URL inputs. Install via its official distribution. Some sites block anonymous access or use different playlist behavior.
- Existing transcript SRT/JSON: optional, but strongly recommended for verbatim speech or on-screen prompt extraction.
- ASR: optional third-party service/configuration; no automatic ASR installation is included in this repository. Without embedded subtitles, provided transcripts, or configured ASR, image-only mode **does not recover spoken words**.

## Modes and outputs

| Mode | CLI | Evidence |
|---|---|---|
| Quick (default) | `--quick` | 6 visual cells, 1 storyboard |
| Deep | `--deep` | 12 visual cells, 2 storyboards, more text |
| Focus | `--from 110 --to 160` | Restrict to a timestamp interval |
| Supplied transcript | `--transcript-file captions.srt` | Merge accurate text with visual cells |

A successful run writes a timestamped image, `manifest.json`, and `notes.txt` under a unique local run folder. The image is visual evidence, not an automatic video summary. For a long video, first review coarse coverage, then run an interval of interest rather than processing everything repeatedly. The downstream AI needs image-input capability to interpret the grid; a text-only model can read the manifest and notes but cannot see the picture.

## Safety and economics

- Never publish source videos, transcripts containing private data, authentication cookies, or API keys in this public GitHub repo.
- Only download content you are authorized to process. Prefer local files when URLs are blocked. Do not export browser authentication secrets into automation or disable SSL verification.
- The upstream's “384 image tokens” refers to a particular DSH accounting setup, not every provider. No universal two-cent price is promised. ASR, downloads, context size, and provider-specific multimodal pricing are separate costs.
- HTTPS certificate-chain errors in yt-dlp should be fixed with trusted certificates or a legitimate alternate source, **not** by skipping certificate verification.
- Keep any per-run files and `.cache` out of commits (see `.gitignore`).

## Failure checklist

1. `node --version` (need 20+), `ffmpeg -version`, `ffprobe -version`.
2. For URLs: `yt-dlp --version` and confirm anonymous access is allowed.
3. Run `bash scripts/setup-engine.sh` manually once; set `VIDEO_INSIGHT_ENGINE_DIR` if a custom install directory is desired.
4. If speech is absent, supply an authorized .srt/.json transcript. Do not guess what was said.
5. If URL download fails, retry using a locally owned copy instead of weakening TLS or exposing login credentials.
