# Notes for Claude Code

This is a working single-file app (`index.html`). Read `README.md` first — it
explains what exists and the build priorities.

## The one job that matters
Give the group a single shared live version. Today every device has its own
private copy because storage runs through `window.storage`, which only exists in
the Claude artifact host and isn't shared. Swap it for a real backend
(Supabase recommended) and deploy it.

## Where to touch the code
- Storage is isolated in four spots: `saveSquad()`, `saveHistory()`, and the
  `load()` function's `window.storage.get(...)` calls. Route these through a new
  async `store` module and the rest of the app doesn't need to change.
- Draw logic (`buildShortlist`, `oneDraw`, `assignSlots`), repeat avoidance
  (`teammateCosts`, `scoreDraw`) and the hidden rating update (`recordResult`)
  all work on plain arrays — leave them alone.

## Hard rules (don't regress these)
- Player ratings are HIDDEN. Never render a number. No slider, no manual edit.
- Positions shape the teams; rating is only a tiebreak.
- Keep the existing visual style.

## First steps suggested
1. `git init`, commit the current file as the baseline.
2. Stand up a Supabase project, create `players` and `weeks` tables.
3. Write the `store` shim, migrate the seed data once, delete `window.storage`.
4. Deploy to Vercel; share the URL.
