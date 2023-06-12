# spectrumprotect

IBM Spectrum Protect (Tivoli TSM) Client for containerd runtime

Runs `dsmc incr`

## how to use (one time)

min envionrment variables to set to run

``` bash
DSM_TCPSERVERADDRESS tsm.example.com
DSM_NODE backupclient
DSM_PASSWORD backuppassword
```

probably maybe also important sometimes

``` bash
DSM_INCLEXCL /tmp/inclexcl
```

other options, good to know for defaults

``` bash
HOME /tmp
DSM_TCPPORT 1500
DSM_LOG=/tmp
BACKUP_PATHS="/data/*"
```

```bash
podman run \
  -e DSM_TCPSERVERADDRESS=tsm.example.com \
  -e DSM_NODE=backupclient \
  -e DSM_PASSWORD=backuppassword \
  --mount type=bind,source=/var/to/backup,target=/data,relabel=shared \
  --mount type=bind,source=/path/to/certs/dsmcert.idx,target=/opt/tivoli/tsm/client/ba/bin/dsmcert.idx,relabel=shared \
  --mount type=bind,source=/path/to/certs/dsmcert.kdb,target=/opt/tivoli/tsm/client/ba/bin/dsmcert.kdb,relabel=shared \
  --mount type=bind,source=/path/to/certs/dsmcert.sth,target=/opt/tivoli/tsm/client/ba/bin/dsmcert.sth,relabel=shared \
  --volume tsm-certs:/etc/adsm:z  \
  bcit.io/spectrumprotect:latest
```

## how to use (systemd)

```service
# /etc/systemd/system/spectrumbackup-cron.service
[Unit]
Description=Cronjob for thingtobackup.service
Requires=thingtobackup.service
After=thingtobackup.service

[Service]
Type=oneshot
ExecStart=podman run \
  -e DSM_TCPSERVERADDRESS=tsm.example.com \
  -e DSM_NODE=backupclient \
  -e DSM_PASSWORD=backuppassword \
  --mount type=bind,source=/var/to/backup,target=/data,relabel=shared \
  --mount type=volume,source=tsm-certs,target=/etc/adsm \
  bcit.io/spectrumprotect:latest
```

```service
# /etc/systemd/system/spectrumbackup-cron.timer
[Unit]
Description=Run dsmc incr hourly
# Auto-shutdown if 'thingtobackup.service' is not available
Requires=thingtobackup.service

[Timer]
# Explicitly declare service that this timer is responsible for
Unit=spectrumbackup-cron.service
# Runs 'spectrumbackup-cron.service' relative to when the *timer-unit* has been activated
OnActiveSec=60min
# Runs 'spectrumbackup-cron.service' relative to when *service-unit* was last deactivated
OnUnitInactiveSec=60min

[Install]
WantedBy=timers.target
```

## troubleshooting

### ANS1592E Failed to initialize SSL protocol

dsmc creates a relationship with the server when first run. The client encrypted certificates for this are stored in `/etc/adsm/`. If the volume is moved/lost, just run `dsmadmc` to login again and regenerate these certs.

addtionally dsmcert.idx/kdb/sth are the encrypted server certificates (self signed), these are genered the first time a client is connected to TSM when security mode is TRANSITIONAL, after connecting the server sets it to STRICT and will not redistribute these unless `dsmadmc` is run. Bind mount files individually these from another host as they are in a dir (`/opt/tivoli/tsm/client/ba/bin/`) with other files so it cannot be a bind mount or volume.
