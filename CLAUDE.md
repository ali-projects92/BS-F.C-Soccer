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
- **Formation** — every side is built to `FORMATION` (default `1 GK, 3 DEF, 1 MID,
  3 ATT` per team). `assignSlots` fills toward `aggregateFormation(n)` (keepers first,
  then flexibles fill the position furthest below target); `oneDraw`'s even split then
  lands each team on the shape. It's best-effort: if declared positions can't make the
  shape (e.g. too many single-position ATTs), it gets as close as it can.
- **Chemistry** — `chemistry` = `[[idA,idB],…]` saved under `bsfc-chemistry` via the
  same `store`. `buildShortlist` subtracts `CHEM_WEIGHT * (#pairs kept together)` from
  the score, so it's a soft pull, balance still leads. Edited only on `#admin`.
- **Draw internals** (`buildShortlist` split, `oneDraw`, repeat avoidance
  `teammateCosts`/`scoreDraw`, hidden rating update `recordResult`) are otherwise
  untouched — leave them alone.
- **Check-in mode** is a `#checkin` hash + `body.checkin` CSS (`applyMode()`); it
  only hides UI, it adds no new mutation logic (reuses `toggle(id)`).
- **Organiser screen** is `#admin` + `body.admin`, gated by the `ADMIN_CODE` constant
  (a light client-side lock — see the caveat in `README.md`). It renders a read-only
  ratings + W/D/L table (`renderRatings`, W/D/L derived from `history`) and the
  chemistry editor (`renderChemistry`). No rating editing — auto-Elo stays the only
  mover.
- **WhatsApp** is `shareWhatsApp()`, which just wraps the existing `asText()`.

## Hard rules (don't regress these)
- Player ratings are HIDDEN from players. Never render a number in the player UI, and
  there is NO manual editing anywhere (not even on `#admin`) — the auto-Elo is the only
  thing that moves a rating. The ONE place a number appears is the passcode-gated,
  read-only `#admin` screen, for the organiser only.
- Positions shape the teams (now via the fixed formation); rating is only a tiebreak.
- Keep the existing visual style.

## If you pick it up next
- The shared store is a single `app_state` key/value blob (last-write-wins). If
  concurrent per-phone edits ever clash, split it into proper `players` / `weeks`
  tables — that's the only reason to touch the storage layer again.
- Deploy is zero-config static (`vercel.json` / `netlify.toml` included).
