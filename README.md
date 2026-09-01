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
- **The draw** — generates 320 valid splits and shows the best one, built to a
  **fixed formation** (default `1 GK, 3 DEF, 1 MID, 3 ATT` per side — set by
  `FORMATION` near the top of the script). It scales for smaller turnouts, and
  flexible players fill whatever the shape is short of.
- **Repeat avoidance** — remembers the last 4 weeks and prefers splits that
  don't reuse last week's pairings (recent weeks weighted heaviest).
- **Draw again** — cycles the 10 best alternative splits.
- **Hidden balancing** — every player has a hidden rating the draw uses to pick the
  most even split (freshness as the tiebreak). The organiser sets it as **1–5 stars**
  on the `#admin` screen; players never see it. Tapping who won (Bibs / Draw / Shirts)
  after a game is logged for W/D/L but does **not** change ratings — they only move when
  the organiser changes the stars.
- **This week's squad is pre-seeded** (see `SEED` / `SEED_WEEK` near the top of
  the script) with the real 16 players and the current split.
- **Shared storage** — with a Supabase project configured, the whole group shares
  one squad / one draw / one history, updating live on every phone. With nothing
  configured it falls back to this device's `localStorage`.
- **Player self check-in** — a stripped-down `#checkin` view where each player taps
  their own name to mark in/out for the week (see below).
- **Send to WhatsApp** — one tap opens WhatsApp pre-filled with the formatted teams.
- **Trades** — once teams are locked in, everyone sees "Tonight's teams" and anyone can
  **propose a swap** (a Bibs player for a Shirts player). The group can **vote 👍/👎** on
  each request (one vote per device, live tally); the organiser sees the tally and makes
  the final call — approving or rejecting on `#admin`. Approved swaps update teams live.
- **Organiser screen** — a private, passcode-gated `#admin` view (see below) to see and
  manage the hidden balancing and trade requests.

## Organiser screen (`#admin`)

Add `#admin` to the URL (e.g. `…/BS-F.C-Soccer/#admin`) and enter the passcode set in
`ADMIN_CODE` near the top of the script (default `bsfcsoccer` — change it). It shows a
per-player card with:

- **Rating** — tap **1–5 stars** to rate each player (⭐ weakest … ⭐⭐⭐⭐⭐ strongest;
  internally 30→70, feeding the balanced-draw maths). Shown with games + W/D/L, sorted.
  Players never see it, and it only changes when you change the stars.
- **Positions** — tap `GK/DEF/MID/ATT` to set each player's role(s), including combos
  like `GK/DEF` or `MID/ATT` (every player keeps at least one).
- **Trade requests** — approve or reject player-swap proposals for tonight's teams (each
  shows the group's 👍/👎 tally to inform your call); an approved swap moves the two
  players across sides and updates the teams for everyone.

**Privacy caveat (important):** the passcode is checked in the browser, and the ratings
live in the shared data (as they always have — just hidden in the UI). So this stops
**casual** players, but it is **not** airtight: someone technical with the link could
still read the raw numbers. Fine for a kickabout; true privacy would need a separate
table with restrictive access rules + real organiser login (a later job).

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

- Real organiser auth + moving ratings to their own restricted table, if the private
  balancing ever needs to be genuinely private (see the caveat under the organiser
  screen above).
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
