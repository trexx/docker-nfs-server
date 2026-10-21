# docker-nfs-server

A small NFS server image based on Alpine.
NFS 4.2 only; NFS v2 and v3 are disabled, so no rpcbind or extra ports are needed.

I use this myself to share a directory with Kodi.

The image contains only the server binaries (`rpc.nfsd`, `rpc.mountd`, `exportfs`) and the libraries they need.

## Requirements

- The `nfsd` kernel module loaded on the host (`modprobe nfsd`). The NFS server runs in the host kernel; the container only starts and configures it.
- `CAP_SYS_ADMIN`, to mount `/proc/fs/nfsd`. Under Docker's default AppArmor profile, mounts are blocked, so also pass `--security-opt apparmor=unconfined` (or use `--privileged`).
- TCP port 2049.

## Usage

Instead of `/etc/exports`, write the export table directly to `/var/lib/nfs/etab`, via a volume or ConfigMap. Each line is a path followed by the full option list, the same format `exportfs -v` prints:

```
/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)
```

`fsid=0` makes `/data` the NFSv4 root, so clients mount `server:/`.

### Docker

```sh
docker run -d --name nfs-server \
  --cap-add SYS_ADMIN --security-opt apparmor=unconfined \
  -p 2049:2049 \
  -v /srv/share:/data \
  -v "$PWD/etab:/var/lib/nfs/etab:ro" \
  ghcr.io/trexx/docker-nfs-server:latest

mount -t nfs4 -o vers=4.2 <host>:/ /mnt
```

### Kubernetes

```yaml
template:
  spec:
    initContainers:
      - name: nfs-modules
        image: ghcr.io/trexx/docker-nfs-server:latest
        args:
          - "modprobe"
          - "nfsd"
        securityContext:
          capabilities:
            add:
              - "SYS_MODULE"
        volumeMounts:
          - mountPath: /lib/modules
            name: modules
            readOnly: true
    containers:
      - name: nfs-server
        image: ghcr.io/trexx/docker-nfs-server:latest
        ports:
          - name: nfsv4
            containerPort: 2049
            hostPort: 2049
            protocol: TCP
        securityContext:
          capabilities:
            add:
              - "SYS_ADMIN"
        volumeMounts:
          - mountPath: /data
            name: data
            readOnly: true
          - name: nfs-exports
            mountPath: /var/lib/nfs/etab
            subPath: etab
            readOnly: true
    volumes:
      - name: modules
        hostPath:
          path: /lib/modules
      - name: nfs-exports
        configMap:
          name: nfs-exports
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: local-path
      resources:
        requests:
          storage: 500Mi
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nfs-exports
data:
  etab: "/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)"
```

## Builds

Every push builds the image and runs [`test/e2e.sh`](test/e2e.sh), which starts the server, mounts it over NFS 4.2, reads and writes a file in both directions and checks the container shuts down cleanly on `SIGTERM`.

On `main`, a build that passes is published if its contents differ from `latest`. A weekly scheduled build picks up Alpine package fixes; Renovate keeps the Alpine base image and the workflow's actions up to date and automerges minor and digest updates once the tests pass. A daily Trivy scan of `latest` reports vulnerabilities to the Security tab.

To publish a build by hand, run the **Build** workflow from the Actions tab on `main`.
