#!/usr/bin/env bash
# 从 PKGBUILD 提取字段生成 .SRCINFO
set -euo pipefail

# 提取变量定义（不包含函数），处理多行数组
eval "$(awk '/^package\(\)/{exit} {print}' PKGBUILD | grep -v '^#')"

echo "pkgbase = ${pkgname}"
echo "	pkgver = ${pkgver}"
echo "	pkgrel = ${pkgrel}"
echo "	pkgdesc = ${pkgdesc}"

for a in "${arch[@]}"; do
  echo "	arch = $a"
done

echo "	url = ${url}"

for l in "${license[@]}"; do
  echo "	license = $l"
done

for d in "${depends[@]}"; do
  echo "	depend = $d"
done

for o in "${options[@]}"; do
  echo "	option = $o"
done

for s in "${source_x86_64[@]}"; do
  echo "	source_x86_64 = $s"
done

for s in "${source_aarch64[@]}"; do
  echo "	source_aarch64 = $s"
done

for s in "${sha256sums_x86_64[@]}"; do
  echo "	sha256sums_x86_64 = $s"
done

for s in "${sha256sums_aarch64[@]}"; do
  echo "	sha256sums_aarch64 = $s"
done

echo ""
echo "pkgname = ${pkgname}"
