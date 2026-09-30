# TEST Migration History Reset for Clean Baseline — 30 September 2026

## Authoritative TEST database
Supabase project: `twfbmjwwqzxdxvclxbun`
Project ref: `twfbmjwwqzxdxvclxbun`

## Pre-reset state
The TEST database contains 314 rows in `supabase_migrations.schema_migrations`, spanning versions `20260914214703` through `20260930192850`.

The GitHub `main` branch contains the current version-controlled migration SQL. The remote migration timestamps do not consistently match the filenames in GitHub; many remote rows were recorded under different timestamps. This is the migration-history drift we are repairing.

The database schema and application data are NOT being reset. This operation concerns migration tracking metadata only.

## Planned clean-baseline operation
Clear the remote migration-history records on TEST only, while leaving all database schema objects and business data untouched. Then the dedicated local clean-baseline workspace can run `supabase db pull` against TEST. With an empty remote migration history and pg-delta enabled, Supabase documents that the initial pull diffs the remote database against an empty shadow database and creates a baseline migration.

## Safety boundaries
- TEST only.
- Do not touch LIVE / production.
- Do not run `supabase db push`.
- Do not run `supabase db reset --linked`.
- Do not delete business tables or application data.
- Do not replace the GitHub migration directory until the generated baseline has been inspected.
