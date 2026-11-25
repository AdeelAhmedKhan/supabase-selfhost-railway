FROM supabase/studio:2026.11.02-sha-a05e7ec
RUN (command -v openssl >/dev/null 2>&1) || (command -v apt-get >/dev/null 2>&1 && apt-get update && apt-get install -y openssl) || (command -v apk >/dev/null 2>&1 && apk add --no-cache openssl) || true
COPY railway/services/studio/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
# The stock image's CMD must be restated: defining ENTRYPOINT in a
# Dockerfile resets the inherited CMD to empty, so without this line
# the entrypoint's exec "$@" runs nothing and the container exits 0
# ("Completed") without ever starting the server.
CMD ["node", "apps/studio/server.js"]
