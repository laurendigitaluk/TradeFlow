# TEST Migration History Clean-Baseline Reset — 30 September 2026

TEST Supabase project `twfbmjwwqzxdxvclxbun` now has an empty `supabase_migrations.schema_migrations` table.

Verification:
- migration history rows: 0
- public tables: 93
- public functions: 178

No schema reset and no business-data deletion was performed.

Next action on the already-linked local clean-baseline workspace:
`supabase db pull --linked`

Expected result: a new baseline migration under `supabase/migrations`. Review that file before any GitHub replacement, `db push`, or LIVE work.

Safety boundary:
- TEST only.
- LIVE/production untouched.
- Do not run `db reset --linked`.
- Do not run `db push`.
- Do not run further `migration repair` commands until the baseline is reviewed.
