FROM alpine:3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a
LABEL org.opencontainers.image.source https://github.com/trexx/docker-nfs-server

# renovate: datasource=repology depName=alpine_3_20/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION "2.6.4-r1"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" > /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
