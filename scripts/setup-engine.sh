#!/usr/bin/env bash
set -euo pipefail

# Explicit, user-initiated installation of the pinned MIT-licensed upstream.
UPSTREAM_URL="https://github.com/SAOS-3624/dsh-video-storyboard.git"
UPSTREAM_COMMIT="0c03a7d78307d7e8e2b8e6bcaa9d1673d79d3333"

for dep in git node; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    printf 'Missing dependency: %s\n' "$dep" >&2
    exit 2
  fi
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENGINE_DIR="${VIDEO_INSIGHT_ENGINE_DIR:-$REPO_DIR/.cache/dsh-video-storyboard}"

if [[ -e "$ENGINE_DIR" ]]; then
  if [[ ! -d "$ENGINE_DIR/.git" ]]; then
    printf 'Refusing to overwrite existing path: %s\n' "$ENGINE_DIR" >&2
    exit 2
  fi
  current="$(git -C "$ENGINE_DIR" rev-parse HEAD)"
  if [[ "$current" != "$UPSTREAM_COMMIT" ]]; then
    printf 'Existing engine has a different commit (%s). Use another VIDEO_INSIGHT_ENGINE_DIR.\n' "$current" >&2
    exit 2
  fi
  printf 'Pinned engine already installed: %s\n' "$ENGINE_DIR"
  exit 0
fi

mkdir -p -- "$(dirname -- "$ENGINE_DIR")"
printf 'Cloning MIT-licensed %s at %s\n' "$UPSTREAM_URL" "$UPSTREAM_COMMIT"
git clone -- "$UPSTREAM_URL" "$ENGINE_DIR"
git -C "$ENGINE_DIR" checkout --detach "$UPSTREAM_COMMIT"
resolved="$(git -C "$ENGINE_DIR" rev-parse HEAD)"
if [[ "$resolved" != "$UPSTREAM_COMMIT" ]]; then
  printf 'Unexpected upstream revision: %s\n' "$resolved" >&2
  exit 1
fi
printf 'Engine ready: %s\n' "$ENGINE_DIR"
printf 'Next: bash scripts/video-insight.sh VIDEO_OR_URL --quick\n'
