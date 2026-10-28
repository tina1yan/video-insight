#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' 'Usage: bash scripts/video-insight.sh VIDEO_OR_URL [--quick|--deep] [--out-dir DIR] [--transcript-file FILE] [--from SECONDS] [--to SECONDS]'
}
fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 2
}
if [[ $# -eq 0 ]]; then usage; exit 2; fi
if [[ "$1" == "--help" || "$1" == "-h" ]]; then usage; exit 0; fi

SOURCE="$1"
shift
MODE="quick"
OUT_DIR="${VIDEO_INSIGHT_OUT_DIR:-$PWD/video-insight-output}"
TRANSCRIPT_FILE=""
FROM=""
TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick) MODE="quick"; shift ;;
    --deep) MODE="deep"; shift ;;
    --out-dir|--transcript-file|--from|--to)
      opt="$1"
      [[ $# -ge 2 ]] || fail "$opt requires a value"
      case "$opt" in
        --out-dir) OUT_DIR="$2" ;;
        --transcript-file) TRANSCRIPT_FILE="$2" ;;
        --from) FROM="$2" ;;
        --to) TO="$2" ;;
      esac
      shift 2 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

if [[ -n "$FROM" && ! "$FROM" =~ ^[0-9]+([.][0-9]+)?$ ]]; then fail '--from must be seconds (>=0)'; fi
if [[ -n "$TO" && ! "$TO" =~ ^[0-9]+([.][0-9]+)?$ ]]; then fail '--to must be seconds (>=0)'; fi
if [[ -n "$TRANSCRIPT_FILE" && ! -f "$TRANSCRIPT_FILE" ]]; then fail "Subtitle file missing: $TRANSCRIPT_FILE"; fi

for dep in node ffmpeg ffprobe; do
  command -v "$dep" >/dev/null 2>&1 || fail "Missing $dep; see references/engine.md"
done
node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 20 ? 0 : 1)' ||
  fail 'Node.js 20 or newer is required'

case "$SOURCE" in
  http://*|https://*)
    command -v yt-dlp >/dev/null 2>&1 || fail 'yt-dlp is required for URL inputs'
    ;;
  *)
    [[ -f "$SOURCE" ]] || fail "Local video not found: $SOURCE"
    ;;
esac

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENGINE_DIR="${VIDEO_INSIGHT_ENGINE_DIR:-$REPO_DIR/.cache/dsh-video-storyboard}"
[[ -f "$ENGINE_DIR/bin/storyboard.mjs" ]] ||
  fail 'Engine not installed. First run: bash scripts/setup-engine.sh'

if [[ "$MODE" == "deep" ]]; then
  CELLS=12
  SHEETS=2
  DETAIL="high"
else
  CELLS=6
  SHEETS=1
  DETAIL="med"
fi

mkdir -p -- "$OUT_DIR"
RUN_DIR="$(mktemp -d "${OUT_DIR%/}/run-XXXXXXXX")"
ARGS=("$SOURCE" --cells "$CELLS" --sheets "$SHEETS" --out "$RUN_DIR/storyboard.png" --manifest "$RUN_DIR/manifest.json" --text --detail "$DETAIL" --transcript auto)
if [[ "$SOURCE" == http://* || "$SOURCE" == https://* ]]; then ARGS+=(--allow-anonymous); fi
if [[ -n "$TRANSCRIPT_FILE" ]]; then ARGS+=(--transcript-file "$TRANSCRIPT_FILE"); fi
if [[ -n "$FROM" ]]; then ARGS+=(--from "$FROM"); fi
if [[ -n "$TO" ]]; then ARGS+=(--to "$TO"); fi

printf 'Mode=%s  Output=%s\n' "$MODE" "$RUN_DIR"
node "$ENGINE_DIR/bin/storyboard.mjs" "${ARGS[@]}" | tee "$RUN_DIR/notes.txt"
printf '\nDone. Read storyboard image(s), manifest.json and notes.txt in %s\n' "$RUN_DIR"
