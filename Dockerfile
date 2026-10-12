FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS nfs-utils
RUN apk add --no-cache nfs-utils

FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-nfs-server"

# Only the server binaries are needed; the nfs-utils package also pulls in python3 for client tools
RUN apk add --no-cache libblkid libtirpc libuuid
COPY --from=nfs-utils /usr/sbin/rpc.nfsd /usr/sbin/rpc.mountd /usr/sbin/exportfs /usr/sbin/
COPY --from=nfs-utils /var/lib/nfs /var/lib/nfs
# Fail the build if a future nfs-utils needs a library not installed above
RUN ldd /usr/sbin/rpc.nfsd /usr/sbin/rpc.mountd /usr/sbin/exportfs >/dev/null

COPY --chmod=500 ./entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
