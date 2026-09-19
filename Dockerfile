FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_24/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r6"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN rm /etc/idmapd.conf /etc/exports

COPY --chmod=500 ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
