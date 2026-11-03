FROM supabase/edge-runtime:v1.77.4
RUN (command -v openssl >/dev/null 2>&1) || (command -v apt-get >/dev/null 2>&1 && apt-get update && apt-get install -y openssl) || (command -v apk >/dev/null 2>&1 && apk add --no-cache openssl) || true
COPY railway/services/functions/entrypoint.sh /entrypoint.sh
COPY docker/volumes/functions/ /home/deno/functions/
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
CMD ["start", "--user-worker-request-idle-timeout", "150000", "--main-service", "/home/deno/functions/main"]
