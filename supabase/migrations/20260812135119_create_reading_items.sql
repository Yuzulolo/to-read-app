-- Reading list ("to-read") items, one row per thing a user wants to read.
-- Follows Supabase RLS best practices: RLS enabled (public schema is API-exposed),
-- per-user ownership enforced with TO authenticated + auth.uid() predicates,
-- and UPDATE guarded by both USING and WITH CHECK so user_id can't be reassigned.

create type public.reading_status as enum ('to_read', 'reading', 'done');

create table public.reading_items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  title       text not null check (char_length(title) between 1 and 500),
  author      text,
  genre       text,
  url         text,
  notes       text,
  status      public.reading_status not null default 'to_read',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Fast "my list, newest first" and status filtering.
create index reading_items_user_id_created_at_idx
  on public.reading_items (user_id, created_at desc);

-- Keep updated_at fresh on every UPDATE.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger reading_items_set_updated_at
  before update on public.reading_items
  for each row execute function public.set_updated_at();

-- RLS: owner-only access.
alter table public.reading_items enable row level security;

create policy "Users can view their own reading items"
  on public.reading_items for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert their own reading items"
  on public.reading_items for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own reading items"
  on public.reading_items for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own reading items"
  on public.reading_items for delete
  to authenticated
  using ((select auth.uid()) = user_id);
