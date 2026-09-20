#!/usr/bin/env bash
# Install the sbx CLI from docker/sbx-releases on Linux.
#
# Usage:
#   scripts/install-sbx.sh [version]
#   scripts/install-sbx.sh          # latest release
#   scripts/install-sbx.sh nightly  # nightly/pre-release channel, if available
#
# Environment:
#   PREFIX        install root, default $HOME/.docker/sbx
#   GITHUB_TOKEN  optional for public releases, required if docker/sbx-releases
#                 is private for your account/runner
#
# Prints the directory to add to PATH on stdout.

set -euo pipefail

if [ $# -gt 1 ]; then
  echo "usage: $0 [version]" >&2
  exit 2
fi

version=${1:-}
PREFIX=${PREFIX:-$HOME/.docker/sbx}

exec 3>&1 1>&2

log() { echo "$@"; }
die() { echo "error: $*"; exit 1; }

case "$(uname -s)" in
  Linux) asset="DockerSandboxes-linux.tar.gz" ;;
  *) die "$(uname -s) is not supported by this script; install sbx by hand" ;;
esac

curl_headers=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  curl_headers=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

if [ -z "$version" ]; then
  log "==> resolving latest sbx release"
  json=$(curl -fsSL "${curl_headers[@]}" https://api.github.com/repos/docker/sbx-releases/releases/latest)
  version=$(python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])' <<<"$json")
  [ -n "$version" ] && [ "$version" != "null" ] || die "could not resolve latest release"
fi
log "    version ${version}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

log "==> downloading ${asset}"
curl -fsSL "${curl_headers[@]}" \
  "https://github.com/docker/sbx-releases/releases/download/${version}/${asset}" \
  -o "${tmp}/${asset}"
tar xzf "${tmp}/${asset}" -C "$tmp"

mkdir -p "$(dirname "$PREFIX")"

log "==> installing into ${PREFIX}"
if [ "$(id -u)" -eq 0 ]; then
  PREFIX="$PREFIX" "${tmp}/docker-sbx/install.sh"
else
  sudo PREFIX="$PREFIX" "${tmp}/docker-sbx/install.sh"
fi

log "==> installed: $("${PREFIX}/bin/sbx" version 2>/dev/null | head -1 || echo "sbx (version unavailable)")"
echo "${PREFIX}/bin" >&3
