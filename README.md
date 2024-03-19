# docker-nfs-server

A simple nfs-server Docker image based on Alpine.
NFS 4.2 enabled. NFS v2 & v3 disabled.

I don't need a 1k line bash script to automate NFS for my needs. I use this myself to simply share a directory with Kodi.  
Regular Trivy security scans as part of Actions ensure I try to stay on top of Security Alerts in the base Alpine image.

I hope to work on getting automated builds going soon.


## Usage

Here I skip using `/etc/exports` and write an etab file to `/var/lib/nfs/etab` this can be via a docker / podman volume or configmap.


```
{
	"etab": "/data *(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,fsid=0,anonuid=65534,anongid=65534,sec=sys)"
}
```
