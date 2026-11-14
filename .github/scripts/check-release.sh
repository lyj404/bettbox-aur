#!/usr/bin/env bash
set -euo pipefail
source .github/scripts/release-common.sh

full=$(aur_version)
current=${full%-*}
current=${current#*:}
valid_version "$current" || fail "Unsupported AUR version: $full"

# A failed API request is an error, never evidence of a withdrawn release.
if ! get_release "v$current" /tmp/bettbox-current-release.json; then
  alert "当前 AUR 版本 $full 对应的上游 release 不存在。"
fi
if ! release_assets /tmp/bettbox-current-release.json "$current"; then
  alert "当前 AUR 版本 $full 的双架构 deb 或 SHA-256 不完整。"
fi

releases=$(gh api 'repos/appshubcc/Bettbox/releases?per_page=30') || fail 'Failed to list upstream releases'
jq -e 'type == "array"' <<<"$releases" >/dev/null || fail 'Invalid releases response'
latest_tag=''
while IFS= read -r tag; do
  version=${tag#v}
  [[ $tag == "v$version" ]] && valid_version "$version" || continue
  jq --arg tag "$tag" '.[] | select(.tag_name == $tag)' <<<"$releases" > /tmp/bettbox-candidate-release.json
  if release_assets /tmp/bettbox-candidate-release.json "$version"; then
    latest_tag=$tag
    break
  fi
done < <(jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name' <<<"$releases")

[[ -n $latest_tag ]] || alert '最近 30 个 release 中没有双架构完整的稳定版本。'
latest=${latest_tag#v}
comparison=$(compare_versions "$latest" "$current") || fail 'vercmp failed'
case "$comparison" in
  -1) alert "上游候选版本 $latest 低于 AUR 当前版本 $full；自动降级已禁止。" ;;
  0) echo 'skip=true' >> "$GITHUB_OUTPUT" ;;
  1) printf 'skip=false\nversion=%s\ntag=%s\n' "$latest" "$latest_tag" >> "$GITHUB_OUTPUT" ;;
  *) fail "Unexpected vercmp output: $comparison" ;;
esac
