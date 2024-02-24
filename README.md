# docker-nfs-server

A simple nfs-server Docker image based on Alpine.
NFS 4.2 enabled. NFS v2 & v3 disabled.

## Usage

Here I skip using `/etc/exports` and write an etab file to `/var/lib/nfs/etab`


```
{
	"etab": "/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)"
}
```