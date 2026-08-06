#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f PKGBUILD || ! -f .SRCINFO ]]; then
  echo "error: PKGBUILD and .SRCINFO must exist in $(pwd)" >&2
  exit 1
fi

sed -i 's/\r$//' PKGBUILD .SRCINFO

old_pkgrel=$(sed -n 's/^pkgrel=\([0-9]\{1,\}\)$/\1/p' PKGBUILD)
if [[ -z "$old_pkgrel" ]]; then
  echo "error: could not parse pkgrel from PKGBUILD" >&2
  exit 1
fi

new_pkgrel=$((old_pkgrel + 1))

sed -i "s/^pkgrel=${old_pkgrel}$/pkgrel=${new_pkgrel}/" PKGBUILD
sed -i "s/^\tpkgrel = ${old_pkgrel}$/\tpkgrel = ${new_pkgrel}/" .SRCINFO

if command -v makepkg >/dev/null 2>&1; then
  makepkg --printsrcinfo > .SRCINFO
  echo ".SRCINFO regenerated via makepkg"
else
  pkgver=$(sed -n 's/^pkgver=\(.*\)$/\1/p' PKGBUILD)
  sed -i "s/^\tpkgver = \(.*\)$/\tpkgver = ${pkgver}/" .SRCINFO
  echo ".SRCINFO updated manually (makepkg not found; sha256sums may be stale)"
fi

echo "pkgrel: ${old_pkgrel} -> ${new_pkgrel}"

git add PKGBUILD .SRCINFO
git diff --cached --stat
git commit -m "bump pkgrel to ${new_pkgrel}"
git push origin HEAD
