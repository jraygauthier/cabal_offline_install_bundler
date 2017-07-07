#!/usr/bin/env bash

set -euf -o pipefail

DEFAULT_TARBALL_FILENAME="$(basename "$0" | sed -r -e 's#deploy_([^\.]+)\.sh#\1.tar.gz#g')"
DEFAULT_TARBALL_FILE="$PWD/$DEFAULT_TARBALL_FILENAME"
TARBALL_FILE="${1:-$DEFAULT_TARBALL_FILE}"

test -e "$TARBALL_FILE" || \
  { echo "The specified or companion tarball file at \"$TARBALL_FILE\" does not exist."; exit 1; }

if command -v cygpath >/dev/null 2>&1 ; then
  CABAL_DOT_DIR="$(cabal help | tail -n2 | grep -E 'config$' | sed -r -e 's/^[ ]*//' | xargs -0 cygpath -u | xargs dirname)"
else
  CABAL_DOT_DIR="$(cabal help | tail -n2 | grep -E 'config$' | sed -r -e 's/^[ ]*//' | xargs dirname)"
fi

CABAL_DOT_DIR_BKUP="${CABAL_DOT_DIR}_bkup_$(date +"%y%m%d%H%M%S")"
test -d "$CABAL_DOT_DIR" && mv "$CABAL_DOT_DIR" "$CABAL_DOT_DIR_BKUP"
mkdir -p "$CABAL_DOT_DIR"
tar -zxvf "$TARBALL_FILE" -C "$CABAL_DOT_DIR"
