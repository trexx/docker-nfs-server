FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_20/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r3"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN rm /etc/idmapd.conf /etc/exports
RUN echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" > /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
