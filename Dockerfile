FROM alpine:3.18.3

RUN apk --update --no-cache add nfs-utils

RUN mkdir -p /var/lib/nfs/rpc_pipefs                                                     && \
    mkdir -p /var/lib/nfs/v4recovery                                                     && \
    echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" > /etc/fstab && \
    echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab

EXPOSE 2049

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]