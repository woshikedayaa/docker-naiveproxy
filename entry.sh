#!/bin/sh
set -ex;
PATH=/bin:/sbin

echo "NAIVEPROXY_VERSION: ${NAIVEPROXY_VERSION}"
if [ $# -gt 0 ];then
    exec /usr/bin/naive $@;
    exit 0;
fi

if [ ! -f /etc/naive/config.json ];then
    rm -rf /etc/naive/config.json;
    echo '{"listen":"${SCHEME}://${LISTEN}:${PORT}","proxy":"${PROXY}"}' > /etc/naive/config.json;
    exit 0;
fi

# run from env;
exec /usr/bin/naive \
-c /etc/naive/config.json \
--insecure-concurrency=${CONCURRENCY};
