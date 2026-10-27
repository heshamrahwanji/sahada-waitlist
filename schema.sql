-- Sahada launch waitlist — applied to Supabase project bjcxddyezrndswqqylvg on 2026-10-27
-- (migration name: launch_waitlist). Kept here for reference / re-creating the table elsewhere.

create table public.launch_waitlist (
  id            uuid primary key default gen_random_uuid(),
  contact       text not null,                 -- normalized: lowercase email, or +E.164 phone
  contact_type  text not null check (contact_type in ('email','phone')),
  sport         text not null check (sport in ('football','padel','basketball','tennis','volleyball','running','other')),
  referral_code text not null unique,
  referred_by   text references public.launch_waitlist(referral_code) on delete set null,
  lang          text not null default 'tr' check (lang in ('tr','en')),
  ip_hash       text,                          -- md5 of client IP, used only for rate limiting
  created_at    timestamptz not null default now()
);
create unique index launch_waitlist_contact_key on public.launch_waitlist (contact);
create index launch_waitlist_referred_by_idx on public.launch_waitlist (referred_by);
create index launch_waitlist_ip_recent_idx on public.launch_waitlist (ip_hash, created_at);

alter table public.launch_waitlist enable row level security;
revoke all on public.launch_waitlist from anon, authenticated;
-- Public access is ONLY via join_launch_waitlist() and launch_waitlist_count().
-- Full function bodies: see the `launch_waitlist` migration in the Supabase dashboard.

-- Useful queries ------------------------------------------------------------
-- Everyone, newest first:
--   select created_at, contact, sport, lang, referral_code, referred_by from launch_waitlist order by created_at desc;
-- Referral leaderboard (who has earned credit):
--   select w.contact, w.referral_code, count(f.id) as invites
--   from launch_waitlist w left join launch_waitlist f on f.referred_by = w.referral_code
--   group by w.id order by invites desc;
-- Sport breakdown:
--   select sport, count(*) from launch_waitlist group by sport order by 2 desc;
