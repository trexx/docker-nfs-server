FROM alpine:3.21.0@sha256:e323a465c03a31ad04374fc7239144d0fd4e2b92da6e3e0655580476d3a84621
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# renovate: datasource=repology depName=alpine_3_20/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r1"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" > /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
