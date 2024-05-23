FROM alpine:3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd
LABEL org.opencontainers.image.source https://github.com/trexx/docker-nfs-server

# renovate: datasource=repology depName=alpine_3_19/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION "2.6.4-r0"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"
RUN echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" > /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
