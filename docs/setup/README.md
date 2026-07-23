# Setup guides

One-time setup steps that some skills need before their `--execute` or write paths work. Each guide is self-contained: prerequisites, a walkthrough, testing, and troubleshooting. Skills run in their default read-or-plan mode without any of this; you only need a guide when you want the execute path it describes.

## Guides

- [Claygent column: Claude API production-usage check](claygent-claude-usage-column.md) - build the Clay Claygent web-research column and inbound webhook that `audience-builder --execute` uses to confirm a company runs the Claude API in production. Required only for `--execute` with the app-side Claude-usage check; plan mode and the WebSearch fallback need nothing here.

More guides will be added as Tier 1 skills land.
