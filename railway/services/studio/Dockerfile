FROM supabase/studio:2026.10.12-sha-3699278
RUN (command -v openssl >/dev/null 2>&1) || (command -v apt-get >/dev/null 2>&1 && apt-get update && apt-get install -y openssl) || (command -v apk >/dev/null 2>&1 && apk add --no-cache openssl) || true
COPY railway/services/studio/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
