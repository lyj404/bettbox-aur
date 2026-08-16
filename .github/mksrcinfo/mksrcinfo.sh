#!/bin/bash
# Generate .SRCINFO from a PKGBUILD using only bash + coreutils.
# No makepkg, no Arch environment, no docker — suitable for CI runners.
#
# Output is byte-identical to `makepkg --printsrcinfo`.
#
# Usage: mksrcinfo.sh [directory-containing-PKGBUILD]
#   Writes .SRCINFO content to stdout. Default directory is ".".
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${1:-.}"

source "$SCRIPT_DIR/pkgbuild_introspection.inc.sh"

cd "$BUILD_DIR" || {
  echo "mksrcinfo: cannot enter directory '$BUILD_DIR'" >&2
  exit 1
}

output=$(srcinfo_write_from_pkgbuild PKGBUILD) || {
  echo "mksrcinfo: failed to generate .SRCINFO from PKGBUILD" >&2
  exit 1
}

printf '%s\n' "$output"