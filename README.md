# BS F.C. (Soccer) — Friday team picker

A tool for splitting 16 players into two fair 8-a-side teams every Friday, so
nobody has to captain-pick and no one feels left out.

## What's here right now

`index.html` — a complete, working, single-file app. No build step, no
dependencies. Open it in a browser and it runs. Everything is vanilla HTML, CSS
and JS in the one file.

It already does:

- **Squad management** — add/remove players, set one or more positions per
  player (GK / DEF / MID / ATT), sit players out for a week.
- **The draw** — generates 320 valid splits and shows the best one. Deals each
  position group evenly across both teams, one keeper per side.
- **Repeat avoidance** — remembers the last 4 weeks and prefers splits that
  don't reuse last week's pairings (recent weeks weighted heaviest).
- **Draw again** — cycles the 10 best alternative splits.
- **Hidden balancing** — every player has a hidden rating (never shown in the
  UI). After a game you tap who won (Bibs / Draw / Shirts) and an Elo-style
  update nudges ratings; underdog wins move more. The draw uses these to pick
  the most even split, with freshness as the tiebreak. No manual rating input
  exists by design — you can't tilt it.
- **This week's squad is pre-seeded** (see `SEED` / `SEED_WEEK` near the top of
  the script) with the real 16 players and the current split.
- **Shared storage** — with a Supabase project configured, the whole group shares
  one squad / one draw / one history, updating live on every phone. With nothing
  configured it falls back to this device's `localStorage`.
- **Player self check-in** — a stripped-down `#checkin` view where each player taps
  their own name to mark in/out for the week (see below).
- **Send to WhatsApp** — one tap opens WhatsApp pre-filled with the formatted teams.

## Setup: shared backend (Supabase)

Without this the app still runs, but storage is per-device (private, not shared).
To give the group one shared live list:

1. Create a free project at [supabase.com](https://supabase.com).
2. Open **SQL Editor → New query**, paste in [`supabase-schema.sql`](./supabase-schema.sql)
   and run it. That creates the `app_state` table, opens read/write to the anon
   key, and turns on live sync.
3. In **Settings → API**, copy the **Project URL** and the **anon / public** key.
4. Paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the top of the
   `<script>` in `index.html`, then reload / redeploy.

The anon key is designed to be public — it's safe to ship in the page. It's a team
sheet, not a bank; anyone with the link can edit the list. Hidden ratings live in
the stored data but are never shown in the UI (see the design notes).

## Deploy to a real URL

It's a static file, so deployment is trivial and zero-config:

- **Vercel** — `vercel` in the repo, or import the repo at vercel.com. `vercel.json`
  is included.
- **Netlify** — drag-and-drop the folder, or connect the repo. `netlify.toml`
  is included (`publish = "."`, no build step).

## Player self check-in

Share `…/index.html#checkin` (or tap **"Just checking in?"** in the header). That
view hides everything except the squad, so a player just taps their own name to go
in/out for the week — no risk of editing the teams or removing anyone. With Supabase
configured this writes to the shared list, so the organiser sees availability update
live. The shared URL is the "group code" — keep it in the group chat, that's plenty.

## Send to WhatsApp

After a draw, **Send to WhatsApp** opens WhatsApp with the teams pre-filled (same
text as **Copy for the group chat**, produced by `asText()`).

## Ideas left on the table

- A private organiser-only form table (ranking, W/D/L) — keep it behind a code,
  it's socially spicy to show publicly.
- If per-phone editing ever gets contentious, split the single `app_state` blob into
  proper `players` / `weeks` tables so concurrent edits don't clobber each other.

## Design notes to preserve
- Ratings must **never** be shown in the UI and there must be **no manual
  rating override**. Hidden-and-automatic is what keeps it fair and
  argument-proof. The mechanism can be public; the numbers can't.
- Keep the look — Anton/Space Grotesk/Roboto Mono, pitch-green + bib-yellow +
  shirt-blue palette. It's deliberately styled like a team sheet.
- Positions still shape the teams; the hidden rating is only a tiebreaker
  between otherwise-good splits.

## Running locally
It's a static file. Any of these work:
```
python3 -m http.server 8000     # then open http://localhost:8000
npx serve
```
