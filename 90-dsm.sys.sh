[ -f /opt/tivoli/tsm/client/ba/bin/dsm.sys ] && return

cat << EOF > /opt/tivoli/tsm/client/ba/bin/dsm.sys
servername  ${DSM_TCPSERVERADDRESS}
    commmethod  TCPip
    inclexcl  ${DSM_INCLEXCL}
    managedservices  SCHEDULE
    node  ${DSM_NODE}
    password  ${DSM_PASSWORD}
    tcpport  ${DSM_TCPPORT}
    tcpserveraddress  ${DSM_TCPSERVERADDRESS}
EOF
