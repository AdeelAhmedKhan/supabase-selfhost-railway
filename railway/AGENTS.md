# Supabase Self-Hosted — Railway template (fork of official supabase/supabase)

House rules for this template. Read before changing anything.

## Source of truth

- The upstream project is supabase/supabase. This template is built
  from a slim extraction of it (this repo): https://github.com/AdeelAhmedKhan/supabase-selfhost-railway
- The fork https://github.com/AdeelAhmedKhan/supabase is kept as a reference copy only.
- Service images, versions, and wiring follow the fork's
  `docker/docker-compose.yml` at the time of the last sync. When
  upstream ships a new self-hosted release, update the image tags
  here AND in railway-template.json together, then re-check the
  official changelog for config changes.
- Never invent a version, a variable, or a capability. If a value
  came from the official compose, keep it. If it is a Railway
  adaptation, say so in the spec file.

## Image pins (last synced from official master)

- Studio supabase/studio:2026.10.12-sha-3699278
- Gateway envoyproxy/envoy:v1.39.1
- Auth supabase/gotrue:v2.197.0
- REST postgrest/postgrest:v14.18
- Realtime supabase/realtime:v2.143.3
- Storage supabase/storage-api:v1.81.0
- Imgproxy darthsim/imgproxy:v3.31.4
- Meta supabase/postgres-meta:v0.100.0
- Functions supabase/edge-runtime:v1.77.4
- Postgres supabase/postgres:17.6.1.136
- Supavisor supabase/supavisor:2.9.13

## Key design (do not break it)

- One generated secret: JWT_SECRET is generated once at deploy
  time and shared by reference to every service. Never generate
  it per service, or authentication breaks.
- Legacy HS256 API keys (ANON_KEY, SERVICE_ROLE_KEY) are DERIVED
  at container start from JWT_SECRET by the entrypoint scripts,
  using the exact algorithm from the official
  `docker/utils/generate-keys.sh` (header HS256, payloads role
  anon / service_role, issuer supabase, 5 year expiry). Stock
  Supabase images do not derive keys themselves, so every
  service that needs ANON_KEY or SERVICE_ROLE_KEY runs a
  Dockerfile-built wrapper with this entrypoint. Never ship a
  real key in this repo.
- Only the gateway is public. Every other service is private
  only. Studio is reached through the gateway at `/` behind
  dashboard basic auth.
- Storage files live in a Railway Bucket (S3 backend), not on a
  local disk volume. Database data lives on a Railway volume.

## Publishing gate

- Static verification before every push: railway-template.json
  parses as JSON, every variable referenced exists, every image
  tag matches the pins above, secret scan clean.
- A full local run of this stack is not possible in this
  environment (no Docker, 11 services), so a live Railway
  deploy is the verification that matters. The published page
  must always state what is still untested, and the list in
  railway-template.json (stillUntestedAtPublish) must match it.
- Never claim a live deploy, a working function call, or a
  measured cost before it has actually happened.
- Railway does NOT read railway-template.json automatically.
  It is the transcription of the Template Composer settings.
  Enter them in the composer at publish time and check the
  published page against this file.
