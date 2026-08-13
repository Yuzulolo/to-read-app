-- Seed three reading-list items for the first (oldest) user in auth.users.
-- Sign up at least one user before running this, or it inserts nothing.
-- Runs automatically on `supabase db reset` (local); for a hosted project,
-- paste this into the dashboard SQL Editor.

insert into public.reading_items (user_id, title, genre)
select u.id, v.title, v.genre
from (select id from auth.users order by created_at limit 1) u
cross join (values
  ('My Brilliant Friend', 'Friendship'),
  ('To Live',             'Fiction'),
  ('Harry Potter',        'Fantasy')
) as v(title, genre);
