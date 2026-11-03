# Supabase Self-Hosted on Railway

Your own app backend, in one click. This repo holds only the
selfhost part: the official Supabase docker recipe plus the
Railway template adaptation. Nothing else from the monorepo
is in here.

## What is inside

- `docker/` — the official selfhost recipe, extracted from
  supabase/supabase at commit
  e6e5c5626470976cad4e1287375347214178fbbc. This is the
  compose file, the Envoy gateway configs, the database init
  scripts, the pooler config, the functions worker and hello
  example, and the key generation utilities.
- `railway/` — the Railway template: the composer spec, the
  Dockerfile wrappers, the key derivation entrypoints, the
  plain language guide, and the verification report. Start
  with `railway/README.md` for deploy steps and the after
  deploy guide.

## Deploy

Deploy from the Railway template page (link added here on
publish). One click, zero input: every secret is generated
at deploy, and the API keys are derived automatically when
each service starts.

## Updates

When official Supabase ships a new selfhost release, run:

```sh
sh scripts/sync-upstream.sh <release-or-commit>
```

That copies the new `docker/` over the old one. It does not
commit. Review the diff, update the image pins in `railway/`
to match, rerun the static checks, then commit. See
`scripts/sync-upstream.sh` for details.

## Licenses

Files under `docker/` keep their original upstream licenses.
The `railway/` additions are MIT, see LICENSE.
