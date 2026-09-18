# Plan Format

Plans live in `docs/plans/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/plans/` directory lazily: only when the first plan is needed.

## Template

```md
# {Short title of the change}

date: {yyyy-mm-dd}

{2-4 sentences. What's the context. What and why. Plain language.}

## Steps

{Check list with numbered items. Max 7 steps. Each step small enough to finish and verify in one sitting.}

## What we're NOT doing

{Mandatory. Never leave this empty. List tempting extras that are out of scope.}

## How we'll know it works

{1–3 plain checks. Things you can actually try.}
```

## Example "What we're NOT doing"

> **What we're NOT doing**
> - No theme customization beyond light/dark
> - No per-page theme overrides
> - No settings page — just the header toggle

## Example "How we'll know it works"

> Toggle the switch, refresh, theme persists.
