-- BS F.C. (Soccer) — shared backend schema
--
-- Run this ONCE in your Supabase project: Dashboard → SQL Editor → New query →
-- paste this in → Run. Then copy your project URL and anon (public) key from
-- Settings → API into SUPABASE_URL / SUPABASE_ANON_KEY at the top of the script
-- in index.html.
--
-- The whole app state is two JSON documents in one tiny key/value table:
--   bsfc-squad    — the players (name, positions, playing, hidden rating)
--   bsfc-history  — the last few weeks' splits and results
-- The app reads/writes these blobs; last write wins. That's plenty for a Friday
-- kickabout among ~16 friends.

create table if not exists public.app_state (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

-- Row Level Security is on, with open policies: anyone with the anon key (i.e.
-- anyone the URL is shared with) can read and write the shared list. This is a
-- team sheet, not a bank — there are no secrets here beyond the group link.
alter table public.app_state enable row level security;

drop policy if exists "anon read app_state"   on public.app_state;
drop policy if exists "anon insert app_state"  on public.app_state;
drop policy if exists "anon update app_state"  on public.app_state;

create policy "anon read app_state"
  on public.app_state for select
  using (true);

create policy "anon insert app_state"
  on public.app_state for insert
  with check (true);

create policy "anon update app_state"
  on public.app_state for update
  using (true) with check (true);

-- Enable live sync: pushes changes to every open device in real time.
-- If this errors with "relation is already member of publication", it's already
-- enabled — safe to ignore.
alter publication supabase_realtime add table public.app_state;
