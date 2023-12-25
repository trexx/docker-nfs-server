FROM alpine:3.19.0
LABEL org.opencontainers.image.source https://github.com/trexx/docker-nfs-server

# renovate: datasource=repology depName=alpine_3_19/nfs-utils versioning=loose
ENV NFS_UTILS_VERSION="2.6.4-r0"

RUN apk --update --no-cache add nfs-utils="${NFS_UTILS_VERSION}"

RUN mkdir -p /var/lib/nfs/rpc_pipefs                                                     && \
    mkdir -p /var/lib/nfs/v4recovery                                                     && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" > /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]