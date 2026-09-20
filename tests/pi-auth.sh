#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
RESOLVER="$ROOT/files/home/.local/bin/pi-auth.sh"

check() {
    openai_mode=$1
    anthropic_mode=$2
    expected=$3
    home=$(mktemp -d)
    trap 'rm -rf "$home"' EXIT HUP INT TERM

    HOME="$home" \
        SBX_CRED_OPENAI_MODE="$openai_mode" \
        SBX_CRED_ANTHROPIC_MODE="$anthropic_mode" \
        sh "$RESOLVER"

    actual=
    if [ -f "$home/.pi/agent/sbx-auth.env" ]; then
        actual=$(cat "$home/.pi/agent/sbx-auth.env")
    fi
    if [ "$actual" != "$expected" ]; then
        printf 'openai=%s anthropic=%s: expected <%s>, got <%s>\n' \
            "$openai_mode" "$anthropic_mode" "$expected" "$actual" >&2
        exit 1
    fi

    rm -rf "$home"
    trap - EXIT HUP INT TERM
}

check oauth none 'unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY'
check apikey none 'unset ANTHROPIC_API_KEY'
check none apikey 'unset OPENAI_API_KEY'
check none none 'unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY'
check oauth apikey 'unset OPENAI_API_KEY'

printf 'pi auth resolver tests passed\n'
