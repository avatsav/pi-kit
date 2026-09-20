# pi-kit

A Docker Sandboxes (`sbx`) kit for running [`pi`](https://pi.dev/) with provider credentials kept on the host.

Adds OpenAI support to the upstream Pi kit:

- OpenAI API key via `OPENAI_API_KEY`
- ChatGPT Plus/Pro OAuth for Pi's `openai-codex` provider
- Anthropic API key via `ANTHROPIC_API_KEY`

## Quick start

Allow this publisher once:

```bash
sbx settings set kit.allowedSources '["docker.io/","ghcr.io/avatsav/"]'
```

Run Pi for a project directory:

```bash
sbx run ghcr.io/avatsav/pi-kit:latest ~/my-project
```

`sbx run` defaults the workspace to the current directory:

```bash
cd ~/my-project
sbx run ghcr.io/avatsav/pi-kit:latest
```

## Authentication

ChatGPT Plus/Pro OAuth:

```bash
sbx secret set openai --oauth
```

OpenAI API key:

```bash
echo "$OPENAI_API_KEY" | sbx secret set openai
```

Anthropic API key:

```bash
echo "$ANTHROPIC_API_KEY" | sbx secret set anthropic
```

Recreate the sandbox after changing credentials; sbx wires credential bindings at create time.

Do not run `/login` inside the sandbox for managed credentials.

## Optional shell helper

Add to `~/.zshrc`:

```zsh
sbx-pi() {
  sbx run ghcr.io/avatsav/pi-kit:latest
}
```

Add to `~/.config/fish/config.fish`:

```fish
function sbx-pi
    sbx run ghcr.io/avatsav/pi-kit:latest
end
```

Usage:

```bash
cd ~/my-project
sbx-pi
```

## Development

See [Local development](docs/local-development.md) for building and testing changes locally.

## License

MIT. See [LICENSE](LICENSE).
