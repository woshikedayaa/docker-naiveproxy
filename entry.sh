#!/bin/sh
set -ex;
PATH=/bin:/sbin

echo "NAIVEPROXY_VERSION: ${NAIVEPROXY_VERSION}"
if [[ $# -gt 0 ]];then
    exec /usr/bin/naive $@;
    exit 0;
fi

if [[ -f /etc/naive/config.json ]];then
    exec /usr/bin/naive -c /etc/naive/config.json
    exit 0;
fi

if [[ -z ${PROXY} ]];then
    echo "Empty PROXY-URL, Missing environment PROXY ?"
    exit 1;
fi

# run from env;
exec /usr/bin/naive --listen=${SCHEME}://${LISTEN}:${PORT} \
--proxy=${PROXY} \
--insecure-concurrency=${CONCURRENCY};
