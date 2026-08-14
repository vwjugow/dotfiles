---
name: langfuse
description: Interact with Langfuse and access its documentation. Use when needing to (1) query or modify Langfuse data programmatically via the CLI - traces, prompts, datasets, scores, sessions, and any other API resource, (2) look up Langfuse documentation, concepts, integration guides, or SDK usage, or (3) understand how any Langfuse feature works. This skill covers CLI-based API access (via npx) and multiple documentation retrieval methods.
---

# Langfuse

Covers all common workflows: instrumenting apps, migrating prompts, debugging traces, accessing data programmatically.

## Core Principles

Follow for ALL Langfuse work:

1. **Documentation First**: NEVER implement from memory. Fetch current docs before writing code (Langfuse updates frequently).
2. **CLI for Data Access**: Use `langfuse-cli` for querying/modifying data.
3. **Best Practices by Use Case**: Check relevant reference file before implementing.
4. **Use latest Langfuse versions**: Unless user specified otherwise.

## Use case references

- instrumenting existing function/app: references/instrumentation.md
- migrating prompts from codebase: references/prompt-migration.md
- capturing user feedback as scores on traces: references/user-feedback.md
- CLI tips: references/cli.md
- upgrading/migrating SDKs: references/sdk-upgrade.md
- submitting skill feedback: references/skill-feedback.md

## 1. Langfuse API via CLI

Use `langfuse-cli` via npx (no install needed):

```bash
# Discover all available resources
npx langfuse-cli api __schema

# List actions for a resource
npx langfuse-cli api <resource> --help

# Show args/options for a specific action
npx langfuse-cli api <resource> <action> --help
```

### Credentials

```bash
export LANGFUSE_PUBLIC_KEY=pk-lf-...
export LANGFUSE_SECRET_KEY=sk-lf-...
export LANGFUSE_HOST=https://cloud.langfuse.com # EU cloud. US: us.cloud.langfuse.com. Can also be self-hosted URL. Server must always be specified.
```

If not set, ask user for API keys (Langfuse UI -> Settings -> API Keys).

For workflows, tips, full usage patterns: [references/cli.md](references/cli.md).

## 2. Langfuse Documentation

Three methods, in order of preference. Always prefer native web fetch/search tools over `curl`.

### 2a. Documentation Index (llms.txt)

```bash
curl -s https://langfuse.com/llms.txt
```

Returns structured list of all doc pages with titles + URLs. Find right page, then fetch directly. Alt: start at `https://langfuse.com/docs`.

### 2b. Fetch Individual Pages as Markdown

```bash
curl -s "https://langfuse.com/docs/observability/overview.md"
curl -s "https://langfuse.com/docs/observability/overview" -H "Accept: text/markdown"
```

### 2c. Search Documentation

```bash
curl -s "https://langfuse.com/api/search-docs?query=<url-encoded-query>"
```

Example:

```bash
curl -s "https://langfuse.com/api/search-docs?query=How+do+I+trace+LangGraph+agents"
```

Returns JSON: `query`, `answer` (array of matching docs with `url`, `title`, `source.content`). GitHub Issues + Discussions indexed too. Extract only relevant portions.

### Documentation Workflow

1. **llms.txt** to orient
2. **Fetch specific pages** once identified
3. **Search** fallback when topic unclear

## Skill Feedback

Offer feedback submission when user says skill gave wrong/outdated instructions, workflow failed, skill missing something, or explicitly says "this is wrong".

Do NOT trigger for issues with Langfuse product itself - only skill instructions.

Follow process in [references/skill-feedback.md](references/skill-feedback.md).
