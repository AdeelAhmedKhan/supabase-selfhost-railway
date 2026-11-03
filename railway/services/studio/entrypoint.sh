#!/bin/sh
set -e
# Derive legacy HS256 API keys from JWT_SECRET (same algorithm
# as the official docker/utils/generate-keys.sh), then run the
# stock Studio command. The composer deliberately does NOT set
# SUPABASE_ANON_KEY or SUPABASE_SERVICE_KEY; this script is the
# only source of those values.

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
export SUPABASE_ANON_KEY=$(gen_token "{\"role\":\"anon\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}")
export SUPABASE_SERVICE_KEY=$(gen_token "{\"role\":\"service_role\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}")

exec "$@"
