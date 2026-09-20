#!/bin/sh
# Remove proxy-managed API-key placeholders for credentials that are not
# actually bound. Pi otherwise treats the placeholders as configured providers
# and can select a model whose requests can never be authenticated.
set -eu

# Startup hooks may run with no HOME. This kit always runs as the agent user.
HOME="${HOME:-/home/agent}"
STATE_DIR="$HOME/.pi/agent"
AUTH_ENV_FILE="$STATE_DIR/sbx-auth.env"
TMP_FILE="$AUTH_ENV_FILE.tmp.$$"

mkdir -p "$STATE_DIR"
: > "$TMP_FILE"

# OpenAI OAuth is materialized as the openai-codex entry in auth.json. In that
# mode OPENAI_API_KEY is only the apiKey declaration's unusable placeholder and
# must not make Pi's regular OpenAI provider appear configured.
case "${SBX_CRED_OPENAI_MODE:-none}" in
    apikey) ;;
    *) printf '%s\n' 'unset OPENAI_API_KEY' >> "$TMP_FILE" ;;
esac

# This kit supports Anthropic API keys, not Anthropic OAuth. The placeholder is
# useful only when sbx reports a genuinely bound API key.
case "${SBX_CRED_ANTHROPIC_MODE:-none}" in
    apikey) ;;
    *) printf '%s\n' 'unset ANTHROPIC_API_KEY' >> "$TMP_FILE" ;;
esac

if [ -s "$TMP_FILE" ]; then
    mv "$TMP_FILE" "$AUTH_ENV_FILE"
else
    rm -f "$TMP_FILE" "$AUTH_ENV_FILE"
fi

# files/home entries currently land without their source executable bit.
chmod 0755 "$HOME/.local/bin/pi" 2>/dev/null || true
