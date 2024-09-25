FROM alpine:3.20.3@sha256:a8f120106f5549715aa966fd7cefaf3b7045f6414fed428684de62fec8c2ca4b
LABEL org.opencontainers.image.source https://github.com/trexx/docker-nfs-server

# renovate: datasource=repology depName=alpine_3_19/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION "2.6.4-r0"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" > /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
