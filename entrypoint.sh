#!/usr/bin/env sh

set -ex

trap stop SIGTERM SIGINT

stop() {
    /usr/sbin/rpc.nfsd 0
    killall /usr/sbin/rpc.mountd
    umount /proc/fs/nfsd /var/lib/nfs/rpc_pipefs

    exit 0
}

mount -t nfsd nfsd /proc/fs/nfsd

/usr/sbin/rpc.nfsd --tcp --no-udp --port 2049 --grace-time 10 --nfs-version 4.2 --no-nfs-version 3
/usr/sbin/rpc.mountd --foreground --port 32767 --nfs-version 4.2 --no-nfs-version 2 --no-nfs-version 3 &

wait
