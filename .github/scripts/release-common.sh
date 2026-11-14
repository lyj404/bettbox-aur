#!/usr/bin/env bash
# Shared helpers for release checks and the manually approved rollback.

fail() { echo "Error: $*" >&2; exit 1; }

valid_version() { [[ $1 =~ ^[0-9]+(\.[0-9]+)*$ ]]; }

aur_version() {
  local response version
  response=$(curl -fsS 'https://aur.archlinux.org/rpc/v5/info?arg[]=bettbox-bin') || fail 'AUR RPC request failed'
  version=$(jq -er 'select(.resultcount == 1) | .results[0].Version | select(type == "string" and length > 0)' <<<"$response") || fail 'AUR RPC did not return one package version'
  printf '%s\n' "$version"
}

get_release() {
  local tag=$1 output=$2 status
  status=$(curl -sS -L -o "$output" -w '%{http_code}' \
    -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $GH_TOKEN" \
    "https://api.github.com/repos/appshubcc/Bettbox/releases/tags/$tag") || fail 'GitHub API request failed'
  case "$status" in
    200) jq -e 'type == "object" and (.assets | type == "array")' "$output" >/dev/null || fail 'Invalid GitHub release response' ;;
    404) return 1 ;;
    *) fail "GitHub API returned HTTP $status for $tag" ;;
  esac
}

# Exact asset names match the URLs in PKGBUILD. Expose both SHA-256 digests.
release_assets() {
  local file=$1 version=$2 arch digest name
  for arch in amd64 arm64; do
    name="Bettbox-${version}-linux-${arch}.deb"
    digest=$(jq -r --arg name "$name" '[.assets[] | select(.name == $name and .state == "uploaded") | .digest] | if length == 1 then .[0] else "" end // ""' "$file")
    [[ $digest =~ ^sha256:[0-9a-f]{64}$ ]] || return 1
    if [[ $arch == amd64 ]]; then SHA_AMD64=${digest#sha256:}; else SHA_ARM64=${digest#sha256:}; fi
  done
}

# Ubuntu runners lack pacman's vercmp. Use the official Arch image for Arch's
# exact comparison rules, keeping epoch out of upstream version comparisons.
compare_versions() { docker run --rm archlinux:base vercmp "$1" "$2"; }

alert() {
  echo "::error::$*"
  printf '## 上游版本异常，已停止自动更新\n\n%s\n\n请核实后使用 Actions 中的手动回退工作流。\n' "$*" >> "$GITHUB_STEP_SUMMARY"
  exit 1
}
