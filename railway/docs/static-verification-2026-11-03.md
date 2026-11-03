# Static verification — Supabase Self-Hosted template — 2026-11-03

What was checked without Docker and without a live Railway
deploy, and what is still untested.

## Passed

1. railway-template.json parses as JSON. 11 services plus 1
   bucket. Every `${{...}}` reference resolves: the service
   exists and the variable is defined on it, or it is a
   Railway provided variable (RAILWAY_PRIVATE_DOMAIN,
   RAILWAY_PUBLIC_DOMAIN). Zero reference errors.
2. Gateway entrypoint run end to end against the real
   official Envoy templates fetched from the fork
   (envoy.yaml, cds.yaml, lds.template.yaml), with a stub
   Envoy binary standing in for the real one:
   - Listener port substitution works: PORT=8123 produced
     exactly one `port_value: 8123` and zero `port_value: 8000`.
   - All 8 listener placeholders substituted, zero remaining:
     ANON_KEY, SERVICE_ROLE_KEY, SUPABASE_PUBLIC_URL,
     DASHBOARD_BASIC_AUTH, and the four asymmetric / new key
     placeholders (empty in legacy mode).
   - All 7 backend cluster hostnames rewritten to the test
     private domains, zero bare docker hostnames left, old
     realtime hostname gone.
   - The derived anon key verifies: header HS256, role anon,
     issuer supabase, expiry exactly 5 years after issue,
     HMAC-SHA256 signature matches JWT_SECRET.
3. The key derivation code block is byte identical in all
   four entrypoints (gateway, studio, storage, functions),
   proven by diff.
4. All four entrypoints pass `sh -n` syntax check.
5. Secret scan clean across all 13 files: no keys, tokens,
   passwords, or private material. Every value in the spec
   is a placeholder, a Railway reference, a generated at
   deploy marker, or an official default.
6. Image tags in Dockerfiles and the spec match the pins in
   AGENTS.md, which match the fork's official compose at
   last sync.
7. Fork contents confirmed: official main worker
   (docker/volumes/functions/main/index.ts) and hello
   example (docker/volumes/functions/hello/index.ts) both
   exist, so the Functions Dockerfile COPY of the whole
   functions directory has what the main service needs.

## Deliberately not claimed

- No live Railway deploy has happened (trial expired, no
  paid plan). Nothing here proves the stack boots on
  Railway.
- No Docker build has run (no Docker in this environment),
  so Dockerfile build success on Railway is unproven.
- The items in railway-template.json under
  stillUntestedAtPublish and verifyAtPublish stay open
  until the first live deploy checks them.
