#!/bin/sh
# Sync docker/ from official supabase/supabase at a given ref.
#
# Usage (run from the root of this repo):
#   sh scripts/sync-upstream.sh <ref>
#
# <ref> is a release tag, branch, or commit, for example:
#   sh scripts/sync-upstream.sh self-hosted/v0.8.2
#
# This script only copies files into ./docker. It does NOT
# commit anything. After it runs:
#   1. Review the diff (git diff --stat, then git diff).
#   2. Update the image pins in railway/ to match the new
#      official versions (see railway/AGENTS.md).
#   3. Rerun the static checks: template JSON parses,
#      references resolve, secret scan clean, gateway
#      entrypoint test against the new Envoy templates.
#   4. Commit the result.
#
# Existing user deployments do not auto update when the
# template changes. New deployers get the new version.

set -e

REF=${1:-}
if [ -z "$REF" ]; then
  echo "usage: sh scripts/sync-upstream.sh <ref>" >&2
  exit 1
fi

if [ ! -f railway/railway-template.json ]; then
  echo "error: run this from the root of the slim repo (railway/railway-template.json not found)" >&2
  exit 1
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

echo "Fetching upstream at ref: $REF"
if git clone --depth 1 --branch "$REF" --filter=blob:none --sparse https://github.com/supabase/supabase.git "$TMP/upstream" 2>/dev/null; then
  echo "Cloned branch or tag: $REF"
else
  echo "Not a branch or tag, trying as a commit SHA..."
  git init -q "$TMP/upstream"
  git -C "$TMP/upstream" remote add origin https://github.com/supabase/supabase.git
  git -C "$TMP/upstream" fetch --depth 1 origin "$REF"
  git -C "$TMP/upstream" checkout -q FETCH_HEAD
fi

git -C "$TMP/upstream" sparse-checkout set docker

echo "Copying docker/ over ./docker ..."
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$TMP/upstream/docker/" ./docker/
else
  echo "warning: rsync not found, copying without deleting removed upstream files (clean those up by hand)"
  cp -r "$TMP/upstream/docker/." ./docker/
fi

echo "Done. Review with: git status --short && git diff --stat"
echo "Then update pins, run the static checks, and commit."
