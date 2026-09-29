#!/bin/sh
# Download openSUSE ASCII logos from fastfetch and store them in ./ascii.
#
# Source: https://github.com/fastfetch-cli/fastfetch (MIT licensed), directory
# src/logo/ascii/o/. See NOTICE for the upstream copyright notice.
#
# Usage: scripts/scrape-ascii.sh

set -eu

REPO="fastfetch-cli/fastfetch"
SRC_DIR="src/logo/ascii/o"
DEST="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/ascii"

LOGOS="
opensuse
opensuse_small
opensuse_leap
opensuse_tumbleweed
opensuse_tumbleweed_small
opensuse_microos
"

mkdir -p "$DEST"

for logo in $LOGOS; do
    printf 'Fetching %s.txt ... ' "$logo"
    gh api "repos/$REPO/contents/$SRC_DIR/$logo.txt" --jq '.content' \
        | base64 -d > "$DEST/$logo.txt"
    printf 'ok\n'
done

printf 'Saved %s logos to %s\n' "$(printf '%s\n' $LOGOS | wc -l | tr -d ' ')" "$DEST"
