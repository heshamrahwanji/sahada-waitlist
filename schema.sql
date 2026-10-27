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
-- Full function bodies: see the `launch_waitlist` and `launch_waitlist_antifarm` migrations
-- in the Supabase dashboard.
--
-- Anti-farming (migration launch_waitlist_antifarm):
--   * The client IP comes from cf-connecting-ip (set by Cloudflare, cannot be forged by the caller).
--     The first x-forwarded-for entry is caller-controlled and is NOT used.
--   * launch_waitlist_invites(code) counts DISTINCT networks (ip_hash) among the people a code
--     referred, excluding the inviter's own network. Fake signups from one connection count as 0;
--     friends sharing one Wi-Fi count as 1. Internal only (not callable by anon).
--   * There is no email/phone verification, so review credits by hand before granting them.

-- Useful queries ------------------------------------------------------------
-- Everyone, newest first:
--   select created_at, contact, sport, lang, referral_code, referred_by from launch_waitlist order by created_at desc;
-- Referral leaderboard (counted invites = what the page shows; raw = every referred signup):
--   select w.contact, w.referral_code, launch_waitlist_invites(w.referral_code) as invites,
--          (select count(*) from launch_waitlist f where f.referred_by = w.referral_code) as raw
--   from launch_waitlist w order by invites desc, raw desc;
-- Credits to review before granting (look for throwaway-looking contacts / bursts of signups):
--   select w.contact as inviter, f.contact as friend, f.created_at, left(f.ip_hash, 8) as net
--   from launch_waitlist w join launch_waitlist f on f.referred_by = w.referral_code
--   where launch_waitlist_invites(w.referral_code) >= 3
--   order by w.contact, f.created_at;
-- Sport breakdown:
--   select sport, count(*) from launch_waitlist group by sport order by 2 desc;
