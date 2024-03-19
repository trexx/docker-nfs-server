# docker-nfs-server

A simple nfs-server Docker image based on Alpine.
NFS 4.2 enabled. NFS v2 & v3 disabled.

I don't need a 1k line bash script to automate NFS for my needs. I use this myself to simply share a directory with Kodi.  
Regular Trivy security scans as part of Actions ensure I try to stay on top of Security Alerts in the base Alpine image.

Automated builds going soon.


## Usage

Here I skip using `/etc/exports` and write an etab file to `/var/lib/nfs/etab` this can be via a docker / podman volume or configmap.


```json
{
	"etab": "/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)"
}
```
### Pod Example
```yaml
template:
  spec:
    initContainers:
      - name: nfs-modules
        image: busybox:1.36.1-uclibc@sha256:97e3873d1f61ba651b632e4755fc52e1d90c9f6e4f01d9b720f37af5efed17e5
        args:
          - "modprobe"
          - "nfs"
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
        image: ghcr.io/trexx/docker-nfs-server:v3.19.1@sha256:93d12012c55c011cabfd3d05de07fd229d1afeb691f644edd8793473340ea809
        ports:
          - name: nfsv4
            containerPort: 2049
            hostPort: 2049
            protocol: TCP
        securityContext:
          privileged: true
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