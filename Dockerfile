FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_23/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r6"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN rm /etc/idmapd.conf /etc/exports

EXPOSE 2049

COPY --chmod=500 ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
