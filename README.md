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

### Storage: the key limitation

Data is saved via a `window.storage` key/value API that only exists inside the
Claude artifact host. **In a normal browser there is no persistence**, and more
importantly, **every user gets their own private copy** — there is no shared
state. This is the single biggest thing to fix.

## What to build next (in priority order)

### 1. Shared backend (the whole point of moving here)
Replace the per-device `window.storage` calls with a real shared datastore so
the whole group sees one squad, one draw, one history. Recommended: **Supabase**
(hosted Postgres + instant REST/realtime, generous free tier) or **Firebase**.

Data model is small:
- `players` (id, name, positions[], playing, rating, created_at)
- `weeks` (id, date, team_a[], team_b[], result)

Wrap the existing storage calls behind a tiny async `store` module so the swap
is localised. The draw logic, repeat avoidance and rating maths stay exactly
as-is — they already operate on plain arrays.

### 2. Deploy to a real URL
Vercel or Netlify. One link the group taps. If it stays a static file + Supabase
from the browser, deployment is trivial (drag-and-drop or `vercel`).

### 3. (Optional) Availability + light auth
Let each player mark themselves in/out for the week from their own phone instead
of the organiser relaying it. Magic-link or a shared group code is plenty — this
is a kickabout, not a bank.

### 4. (Optional) Nice-to-haves
- A private organiser-only form table (ranking, W/D/L) — keep it behind a code,
  it's socially spicy to show publicly.
- Push/notification or a WhatsApp share button that formats the teams (the
  `asText()` function already produces the group-chat text).

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
