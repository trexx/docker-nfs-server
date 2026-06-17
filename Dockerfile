FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_24/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r6"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN rm /etc/idmapd.conf /etc/exports

EXPOSE 2049

COPY --chmod=500 ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
