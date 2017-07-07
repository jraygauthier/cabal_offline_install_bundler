#!/usr/bin/env bash

set -euf -o pipefail

DEFAULT_TARBALL_OUT_DIR="$PWD/haskell_packages"
# An optionnal argument would be required here.
#TARBALL_OUT_DIR="${1:-$DEFAULT_TARBALL_OUT_DIR}"
TARBALL_OUT_DIR="$DEFAULT_TARBALL_OUT_DIR"

SHARED_INFIX_NAME="packages"

TARBALL_FILE="$TARBALL_OUT_DIR/${SHARED_INFIX_NAME}.tar.gz"

if command -v cygpath >/dev/null 2>&1 ; then
  GHC_DOT_DIR="$(ghc-pkg.exe --user list | head -n1 | xargs -r -0 cygpath -u | xargs -r dirname.exe | xargs -r dirname)"
  CABAL_DOT_DIR="$(cabal help | tail -n2 | grep -E 'config$' | sed -r -e 's/^[ ]*//' | xargs -0 cygpath -u | xargs dirname)"
else
  GHC_DOT_DIR="$(ghc-pkg.exe --user list | head -n1 | xargs -r dirname.exe | xargs -r dirname)"
  CABAL_DOT_DIR="$(cabal help | tail -n2 | grep -E 'config$' | sed -r -e 's/^[ ]*//' | xargs dirname)"
fi


CABAL_DOT_DIR_BKUP="${CABAL_DOT_DIR}_bkup_$(date +"%y%m%d%H%M%S")"
test -d "$CABAL_DOT_DIR" && mv "$CABAL_DOT_DIR" "$CABAL_DOT_DIR_BKUP"

GHC_DOT_DIR_BKUP="${GHC_DOT_DIR}_bkup_$(date +"%y%m%d%H%M%S")"
test -n "$GHC_DOT_DIR" && test -d "$GHC_DOT_DIR" && mv "$GHC_DOT_DIR" "$GHC_DOT_DIR_BKUP"

cabal update && cabal fetch "$@"
rm -Rf "$TARBALL_OUT_DIR"; mkdir -p "$TARBALL_OUT_DIR"
pushd "$CABAL_DOT_DIR" > /dev/null
tar -zcvf "$TARBALL_FILE" packages
popd > /dev/null
rm -R "$CABAL_DOT_DIR"
test -d "$CABAL_DOT_DIR_BKUP" && mv "$CABAL_DOT_DIR_BKUP" "$CABAL_DOT_DIR"
test -n "$GHC_DOT_DIR" && test -d "$GHC_DOT_DIR_BKUP" && mv "$GHC_DOT_DIR_BKUP" "$GHC_DOT_DIR" 

SCRIPT_DIR=`cd $(dirname $0) > /dev/null;pwd`
cp "$SCRIPT_DIR/deploy_hs_pkgs_tarball.sh" "$TARBALL_OUT_DIR/deploy_${SHARED_INFIX_NAME}.sh"
