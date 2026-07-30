-- Profiles: extends auth.users with app-specific preferences
create table public.profiles (
  id                uuid references auth.users on delete cascade primary key,
  display_name      text,
  avatar_url        text,
  daily_limit_mg    integer not null default 400,
  sleep_cutoff_hour integer not null default 14,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create a profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Caffeine entries
create table public.caffeine_entries (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users on delete cascade not null,
  drink_type text        not null,
  mg         integer     not null check (mg > 0),
  logged_at  timestamptz not null,
  source     text        not null default 'phone' check (source in ('phone', 'watch')),
  created_at timestamptz not null default now()
);

alter table public.caffeine_entries enable row level security;

create policy "Users can view own entries"
  on public.caffeine_entries for select
  using (auth.uid() = user_id);

create policy "Users can insert own entries"
  on public.caffeine_entries for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own entries"
  on public.caffeine_entries for delete
  using (auth.uid() = user_id);

-- Index for fast date-range queries (today's entries, last 7 days, etc.)
create index caffeine_entries_user_logged_at
  on public.caffeine_entries (user_id, logged_at desc);
