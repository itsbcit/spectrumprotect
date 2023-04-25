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
