# Notes for Claude Code

This is a working single-file app (`index.html`). Read `README.md` first — it
explains what exists and the build priorities.

## The one job that matters — DONE
Give the group a single shared live version. This is now wired: `window.storage`
is gone, replaced by an async `store` module that talks to Supabase when a project
is configured (shared + live) and falls back to `localStorage` otherwise. To turn
sharing on, follow **Setup: shared backend** in `README.md` — run
`supabase-schema.sql` and paste the project URL + anon key into `SUPABASE_URL` /
`SUPABASE_ANON_KEY` near the top of the `<script>` in `index.html`.

## Where the code lives now
- **Storage** is behind the `store` module (`store.get` / `store.set` / `store.watch`)
  near the top of the script. `saveSquad()` / `saveHistory()` are thin wrappers over
  it; `load()` and `syncFromRemote()` read through it. Keep any backend change
  localised here — the rest of the app works on plain arrays.
- **Draw logic** (`buildShortlist`, `oneDraw`, `assignSlots`), repeat avoidance
  (`teammateCosts`, `scoreDraw`) and the hidden rating update (`recordResult`) are
  untouched — leave them alone.
- **Check-in mode** is a `#checkin` hash + `body.checkin` CSS (`applyMode()`); it
  only hides UI, it adds no new mutation logic (reuses `toggle(id)`).
- **WhatsApp** is `shareWhatsApp()`, which just wraps the existing `asText()`.

## Hard rules (don't regress these)
- Player ratings are HIDDEN. Never render a number. No slider, no manual edit.
- Positions shape the teams; rating is only a tiebreak.
- Keep the existing visual style.

## If you pick it up next
- The shared store is a single `app_state` key/value blob (last-write-wins). If
  concurrent per-phone edits ever clash, split it into proper `players` / `weeks`
  tables — that's the only reason to touch the storage layer again.
- Deploy is zero-config static (`vercel.json` / `netlify.toml` included).
