#!/usr/bin/env bash
# End-to-end test: run the image as an NFS server, mount the export from the
# host, read and write through it, then check the container stops cleanly.
# Needs root, Docker and the nfsd kernel module (a GitHub-hosted Ubuntu runner has all three).

set -euo pipefail

IMAGE="${1:?usage: $0 IMAGE}"
NAME="nfs-server-e2e"
WORK="$(mktemp -d)"
MNT="${WORK}/mnt"

fail() {
    echo "FAIL: $*" >&2
    docker logs "${NAME}" >&2 || true
    exit 1
}

cleanup() {
    umount -f "${MNT}" 2>/dev/null || true
    docker rm -f "${NAME}" >/dev/null 2>&1 || true
    rm -rf "${WORK}"
}
trap cleanup EXIT

command -v mount.nfs4 >/dev/null || { apt-get update -qq && apt-get install -y -qq nfs-common >/dev/null; }
modprobe nfsd

mkdir -p "${WORK}/data" "${MNT}"
chmod 777 "${WORK}/data"
echo "/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)" > "${WORK}/etab"

docker run -d --name "${NAME}" \
    --cap-add SYS_ADMIN --security-opt apparmor=unconfined \
    -v "${WORK}/data:/data" \
    -v "${WORK}/etab:/var/lib/nfs/etab:ro" \
    "${IMAGE}" >/dev/null
IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${NAME}")"

for _ in $(seq 30); do
    mount -t nfs4 -o vers=4.2,soft,timeo=50,retrans=2 "${IP}:/" "${MNT}" 2>/dev/null && break
    sleep 1
done
mountpoint -q "${MNT}" || fail "could not mount ${IP}:/"
echo "mounted ${IP}:/ over NFS $(awk -v m="${MNT}" '$2 == m { print $4 }' /proc/mounts)"

echo "from-server" > "${WORK}/data/server.txt"
timeout 60 grep -qx "from-server" "${MNT}/server.txt" || fail "client could not read a file written on the server"

timeout 60 sh -c "echo from-client > '${MNT}/client.txt'" || fail "client could not write to the export"
docker exec "${NAME}" grep -qx "from-client" /data/client.txt || fail "server did not see the file written by the client"
echo "read and write OK"

umount "${MNT}"
docker stop -t 30 "${NAME}" >/dev/null
EXIT_CODE="$(docker inspect -f '{{.State.ExitCode}}' "${NAME}")"
[ "${EXIT_CODE}" = "0" ] || fail "container exited with ${EXIT_CODE} on SIGTERM"
echo "clean shutdown OK"
