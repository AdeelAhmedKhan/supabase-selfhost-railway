FROM supabase/postgres:17.6.1.136
COPY docker/volumes/db/realtime.sql /docker-entrypoint-initdb.d/migrations/99-realtime.sql
COPY docker/volumes/db/webhooks.sql /docker-entrypoint-initdb.d/init-scripts/98-webhooks.sql
COPY docker/volumes/db/roles.sql /docker-entrypoint-initdb.d/init-scripts/99-roles.sql
COPY docker/volumes/db/jwt.sql /docker-entrypoint-initdb.d/init-scripts/99-jwt.sql
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "log_min_messages=fatal"]
