FROM supabase/edge-runtime:v1.77.4
RUN (command -v openssl >/dev/null 2>&1) || (command -v apt-get >/dev/null 2>&1 && apt-get update && apt-get install -y openssl) || (command -v apk >/dev/null 2>&1 && apk add --no-cache openssl) || true
COPY railway/services/functions/entrypoint.sh /entrypoint.sh
COPY docker/volumes/functions/ /home/deno/functions/
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
# --ip :: binds the IPv6 wildcard: Railway private networking is IPv6,
# and with the edge runtime's IPv4 default the gateway could not connect
# (503) even with Functions Online (proven on the 2026-11-22 test deploy).
CMD ["start", "--ip", "::", "--user-worker-request-idle-timeout", "150000", "--main-service", "/home/deno/functions/main"]
