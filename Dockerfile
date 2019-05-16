FROM bcit/openshift-okdcli:3.11
# vim: syntax=dockerfile

ENV HOME /tmp

LABEL maintainer="jesse_weisner@bcit.ca"
LABEL version="7.1.8.0"

COPY rpms /rpms

RUN yum -y install \
    /rpms/gskcrypt64-*.rpm \
    /rpms/gskssl64-*.rpm \
    /rpms/TIVsm-BA.x86_64.rpm \
    /rpms/TIVsm-API64.x86_64.rpm

VOLUME /tmp
