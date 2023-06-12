FROM bcit.io/alpine:latest as rpms
# vim: syntax=dockerfile

WORKDIR /src

RUN wget -O - https://public.dhe.ibm.com/storage/tivoli-storage-management/maintenance/client/v8r1/Linux/LinuxX86/BA/v8117/8.1.17.0-TIV-TSMBAC-LinuxX86.tar \
  | tar x

RUN ls -al

FROM bcit.io/almalinux:9

LABEL maintainer="jesse@weisner.ca, chriswood.ca@gmail.com"
LABEL build_id="1686599543"

WORKDIR /rpms
COPY --from=rpms /src/gskcrypt64-*.x86_64.rpm /rpms/
COPY --from=rpms /src/gskssl64-*.x86_64.rpm /rpms/
COPY --from=rpms /src/TIVsm-BA.x86_64.rpm /rpms/
COPY --from=rpms /src/TIVsm-API64.x86_64.rpm /rpms/

RUN ls -alh

RUN yum -y install \
  /rpms/gskcrypt64-*.rpm \
  /rpms/gskssl64-*.rpm \
  /rpms/TIVsm-BA.x86_64.rpm \
  /rpms/TIVsm-API64.x86_64.rpm

ENV HOME /tmp
ENV DSM_TCPSERVERADDRESS tsm.example.com
ENV DSM_NODE backupclient
ENV DSM_PASSWORD backuppassword
ENV DSM_TCPPORT 1500
ENV DSM_INCLEXCL /tmp/inclexcl
ENV DSM_LOG=/tmp
ENV BACKUP_PATHS="/data/*"

COPY 90-dsm.opt.sh \
     90-dsm.sys.sh \
     90-inclexcl.sh \
  /docker-entrypoint.d/

RUN mkdir /data \
 && chown 0:0 /data /opt/tivoli/tsm/client/ba/bin \
 && chmod 775 /data /opt/tivoli/tsm/client/ba/bin \
 && ln -sf /dev/stdout /opt/tivoli/tsm/dsmsched.log \
 && ln -sf /dev/stderr /opt/tivoli/tsm/error.log

VOLUME /data
VOLUME /etc/adsm

WORKDIR /data

CMD ["/usr/bin/dsmc", "incr"]
