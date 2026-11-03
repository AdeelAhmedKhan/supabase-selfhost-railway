#!/bin/sh
set -e
# Gateway entrypoint: derive legacy API keys, build the Envoy
# config from the official templates, then start Envoy.
#
# Key derivation uses the exact algorithm from the official
# docker/utils/generate-keys.sh in this repo: HS256 JWTs signed
# with JWT_SECRET, role anon / service_role, issuer supabase,
# 5 year expiry. Stock Supabase images do not derive keys
# themselves, so this step is what makes zero-input deploy work.

if [ -z "$JWT_SECRET" ]; then echo "error: JWT_SECRET is not set" >&2; exit 1; fi
if ! command -v openssl >/dev/null 2>&1; then echo "error: openssl is required but not found" >&2; exit 1; fi

b64url() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }

gen_token() {
  _payload="$1"
  _header='{"alg":"HS256","typ":"JWT"}'
  _header_b64=$(printf %s "$_header" | b64url)
  _payload_b64=$(printf %s "$_payload" | b64url)
  _signed="${_header_b64}.${_payload_b64}"
  _sig=$(printf %s "$_signed" | openssl dgst -binary -sha256 -hmac "$JWT_SECRET" | b64url)
  printf '%s' "${_signed}.${_sig}"
}

iat=$(date +%s)
exp=$((iat + 5 * 3600 * 24 * 365))
ANON_KEY=$(gen_token "{\"role\":\"anon\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}")
SERVICE_ROLE_KEY=$(gen_token "{\"role\":\"service_role\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}")
export ANON_KEY SERVICE_ROLE_KEY

# Dashboard basic auth, as in the official docker-entrypoint.sh.
PASSWORD_HASH=$(printf '%s' "${DASHBOARD_PASSWORD}" | openssl sha1 -binary | openssl base64)
DASHBOARD_BASIC_AUTH="${DASHBOARD_USERNAME}:{SHA}${PASSWORD_HASH}"

echo "Generating Envoy configuration..."

# Official listener substitution (lds.template.yaml -> lds.yaml).
sed -e "s|\${ANON_KEY}|${ANON_KEY}|g" \
    -e "s|\${ANON_KEY_ASYMMETRIC}|${ANON_KEY_ASYMMETRIC:-}|g" \
    -e "s|\${SERVICE_ROLE_KEY}|${SERVICE_ROLE_KEY}|g" \
    -e "s|\${SERVICE_ROLE_KEY_ASYMMETRIC}|${SERVICE_ROLE_KEY_ASYMMETRIC:-}|g" \
    -e "s|\${SUPABASE_PUBLISHABLE_KEY}|${SUPABASE_PUBLISHABLE_KEY:-}|g" \
    -e "s|\${SUPABASE_SECRET_KEY}|${SUPABASE_SECRET_KEY:-}|g" \
    -e "s|\${SUPABASE_PUBLIC_URL}|${SUPABASE_PUBLIC_URL:-}|g" \
    -e "s|\${DASHBOARD_BASIC_AUTH}|${DASHBOARD_BASIC_AUTH}|g" \
    /etc/envoy/lds.template.yaml > /etc/envoy/lds.yaml

# Listen on Railway's PORT. The template has exactly one
# port_value: 8000 in the listener, so this replacement is precise.
sed -i "s/port_value: 8000/port_value: ${PORT:-8000}/" /etc/envoy/lds.yaml

# Point backend clusters at Railway private domains. The hostnames
# below arrive as service variables from the template composer.
sed -i \
  -e "s/^\(\s*\)address: auth$/\1address: ${AUTH_HOST}/" \
  -e "s/^\(\s*\)address: rest$/\1address: ${REST_HOST}/" \
  -e "s/^\(\s*\)address: realtime-dev\.supabase-realtime$/\1address: ${REALTIME_HOST}/" \
  -e "s/^\(\s*\)address: storage$/\1address: ${STORAGE_HOST}/" \
  -e "s/^\(\s*\)address: functions$/\1address: ${FUNCTIONS_HOST}/" \
  -e "s/^\(\s*\)address: meta$/\1address: ${META_HOST}/" \
  -e "s/^\(\s*\)address: studio$/\1address: ${STUDIO_HOST}/" \
  /etc/envoy/cds.yaml

echo "Supabase URL: ${SUPABASE_PUBLIC_URL:-<check the gateway public domain in Railway>}"
echo "Anon key: ${ANON_KEY}"
echo "Envoy configuration generated successfully"
echo "Starting Envoy..."
exec envoy -c /etc/envoy/envoy.yaml "$@"
