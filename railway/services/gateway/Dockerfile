FROM envoyproxy/envoy:v1.39.1
COPY docker/volumes/api/envoy/envoy.yaml /etc/envoy/envoy.yaml
COPY docker/volumes/api/envoy/cds.yaml /etc/envoy/cds.yaml
COPY docker/volumes/api/envoy/lds.template.yaml /etc/envoy/lds.template.yaml
COPY railway/services/gateway/entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
