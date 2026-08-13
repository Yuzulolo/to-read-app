-- Seed three books into the existing public."to-read" table.
-- Assumes the table already exists (created by earlier migrations that live on
-- the remote database). Idempotent: skips any book already present by name, so
-- it is safe to apply against a database that already contains these rows.

insert into public."to-read" ("book name", "Category", created_at)
select v.name, v.category, now()
from (values
  ('My Brilliant Friend', 'Friendship'),
  ('To Live',             'Fiction'),
  ('Harry Potter',        'Fantasy')
) as v(name, category)
where not exists (
  select 1 from public."to-read" t where t."book name" = v.name
);
