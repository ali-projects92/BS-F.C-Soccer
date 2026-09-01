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
- **Ratings are organiser-set stars.** Each player's `rating` is a plain number the
  draw balances on; the organiser sets it as 1–5 stars on `#admin`
  (`setStars`/`starToRating`/`ratingToStars`, 1★=30 … 5★=70). Nothing moves a rating
  automatically — `recordResult` only logs the week's outcome for W/D/L, it does NOT
  touch ratings.
- **Draw internals** (`buildShortlist` split, `oneDraw`, repeat avoidance
  `teammateCosts`/`scoreDraw`) are otherwise untouched — leave them alone.
- **Check-in mode** is a `#checkin` hash + `body.checkin` CSS (`applyMode()`); it
  only hides UI, it adds no new mutation logic (reuses `toggle(id)`).
- **Organiser screen** is `#admin` + `body.admin`, gated by the `ADMIN_CODE` constant
  (a light client-side lock — see the caveat in `README.md`). It renders the ratings +
  W/D/L table (`renderRatings`, W/D/L derived from `history`). The organiser sets each
  player's star rating (`setStars`) and positions (`togglePosition`) there; this is the
  ONLY place editing exists.
- **WhatsApp** is `shareWhatsApp()`, which just wraps the existing `asText()`.
- **Trades** — pending swaps live in `trades` (`bsfc-trades` via the store). They apply
  to the *shared* locked teams: `activeGame()` is `history[0]` while `result == null`.
  `renderTrades()` draws the player-facing "Tonight's teams" + propose panel + a votable
  request list (id-based, so it works on any device); `submitTrade()` adds a request.
  Each request carries a `votes` map (`voterId()`→`'y'|'n'`, one per device); `voteTrade()`
  toggles a vote and `tallyOf()` counts them (shown to players and in `#admin`). The
  organiser still decides: `approveTrade()` (swaps the two ids between `history[0].a`/`.b`,
  mirrors into the on-screen `teams` via `swapInTeams`, drops now-stale requests) or
  `rejectTrade()`. `lockIn()` clears old requests.
  - **Sub** (`#admin`) — `doSub()` swaps a player on the locked teams for a bench player
    (`benchIds()` = squad not in `history[0]`); edits `history[0]`, mirrors into `teams`
    via `subInTeams`, marks the sub-in playing, and drops now-stale trade requests.
- **Roster / seed migration** — the squad comes from `SEED`. To push a new roster to
  everyone, edit `SEED` and bump `SEED_VERSION`; `load()` then rebuilds the squad from
  `SEED` once per version, carrying over each existing player's rating / positions /
  in-out **by name**, clears `history` (records reset), and stores the applied version
  under `bsfc-seedv`. It propagates to all devices through the shared store.

## Hard rules (don't regress these)
- Player ratings are HIDDEN from players. Never render a rating (number or stars) in
  the player-facing UI. The ONLY place a rating is shown — or set — is the
  passcode-gated `#admin` screen, for the organiser. Nothing else moves a rating.
- Positions shape the teams (now via the fixed formation); rating is only a tiebreak.
- Keep the existing visual style.

## If you pick it up next
- The shared store is a single `app_state` key/value blob (last-write-wins). If
  concurrent per-phone edits ever clash, split it into proper `players` / `weeks`
  tables — that's the only reason to touch the storage layer again.
- Deploy is zero-config static (`vercel.json` / `netlify.toml` included).
- **Auto-update** — the deploy workflow stamps `__APP_VERSION__` in `index.html` with
  the commit sha (a `sed` step). `checkForUpdate()` fetches the freshest page
  (`cache:'no-store'`), and if the live sha differs it reloads to `?v=<sha>` — so users
  get new builds without a manual hard-refresh. It no-ops locally (placeholder unstamped)
  and guards against reload loops via `sessionStorage`.
