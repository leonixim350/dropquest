-- DropQuest: esquema inicial para Supabase/Postgres.
-- Ejecuta todo este archivo en Supabase > SQL Editor > New query.
-- Activa Auth por correo antes de publicar el flujo de acceso.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  alias text not null default 'Jugador' check (char_length(alias) between 1 and 24),
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.season_stats (
  user_id uuid not null references public.profiles(id) on delete cascade,
  season_key text not null check (char_length(season_key) between 1 and 40),
  chests integer not null default 0 check (chests >= 0),
  hours numeric(9,1) not null default 0 check (hours >= 0),
  personal_goal integer not null default 150 check (personal_goal > 0),
  odds_denominator bigint not null default 137500 check (odds_denominator > 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, season_key)
);

create table if not exists public.daily_token_reports (
  user_id uuid not null references public.profiles(id) on delete cascade,
  report_date date not null,
  created_at timestamptz not null default now(),
  primary key (user_id, report_date)
);

alter table public.profiles enable row level security;
alter table public.season_stats enable row level security;
alter table public.daily_token_reports enable row level security;

-- Perfiles: cada quien gestiona el suyo; los visitantes solo pueden leer
-- los perfiles que explícitamente eligieron hacer públicos.
drop policy if exists "read public profiles or own" on public.profiles;
create policy "read public profiles or own" on public.profiles
  for select using (is_public or (select auth.uid()) = id);
drop policy if exists "insert own profile" on public.profiles;
create policy "insert own profile" on public.profiles
  for insert with check ((select auth.uid()) = id);
drop policy if exists "update own profile" on public.profiles;
create policy "update own profile" on public.profiles
  for update using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Estadísticas: legibles por su dueño y por cualquier visitante solo si
-- el dueño habilitó el perfil público.
drop policy if exists "read public season stats or own" on public.season_stats;
create policy "read public season stats or own" on public.season_stats
  for select using (
    (select auth.uid()) = user_id or exists (
      select 1 from public.profiles p
      where p.id = season_stats.user_id and p.is_public = true
    )
  );
drop policy if exists "insert own season stats" on public.season_stats;
create policy "insert own season stats" on public.season_stats
  for insert with check ((select auth.uid()) = user_id);
drop policy if exists "update own season stats" on public.season_stats;
create policy "update own season stats" on public.season_stats
  for update using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
drop policy if exists "delete own season stats" on public.season_stats;
create policy "delete own season stats" on public.season_stats
  for delete using ((select auth.uid()) = user_id);

-- Check-ins privados: un usuario registra y consulta solo los propios.
drop policy if exists "read own token reports" on public.daily_token_reports;
create policy "read own token reports" on public.daily_token_reports
  for select using ((select auth.uid()) = user_id);
drop policy if exists "insert own token report" on public.daily_token_reports;
create policy "insert own token report" on public.daily_token_reports
  for insert with check ((select auth.uid()) = user_id);
drop policy if exists "delete own token report" on public.daily_token_reports;
create policy "delete own token report" on public.daily_token_reports
  for delete using ((select auth.uid()) = user_id);

-- Devuelve solo un agregado diario; no expone la lista de usuarios que reportó.
create or replace function public.count_daily_token_reports(p_date date)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)
  from public.daily_token_reports
  where report_date = p_date
    and p_date = (now() at time zone 'America/Mexico_City')::date;
$$;
revoke all on function public.count_daily_token_reports(date) from public;
grant execute on function public.count_daily_token_reports(date) to anon, authenticated;

-- Crea el perfil básico automáticamente cuando alguien se registra con Supabase Auth.
create or replace function public.create_dropquest_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, alias)
  values (
    new.id,
    coalesce(nullif(left(new.raw_user_meta_data ->> 'alias', 24), ''), 'Jugador')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created_dropquest on auth.users;
create trigger on_auth_user_created_dropquest
after insert on auth.users
for each row execute procedure public.create_dropquest_profile();
