FROM alpine:3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_23/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r6"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN rm /etc/idmapd.conf /etc/exports

EXPOSE 2049

COPY --chmod=500 ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
