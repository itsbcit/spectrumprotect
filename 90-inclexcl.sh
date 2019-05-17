[ -e "${DSM_INCLEXCL}" ] && return

echo -n > $DSM_INCLEXCL
echo "exclude.dir /*"          >> $DSM_INCLEXCL
echo "include ${BACKUP_PATHS}" >> $DSM_INCLEXCL
