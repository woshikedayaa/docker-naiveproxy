#!/bin/bash
# init
set -e;
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin";

# check command
MISSING_COMMAND=""
check() {
    for i in $(seq $#);do
        if  [[ ! -z $1 ]] && [[ -z $(command -v $1) ]];then
            MISSING_COMMAND="${MISSING_COMMAND} $1";
        fi
        shift 1;
    done
}
check jq docker curl tar mkdir;
if [[ ! -z ${MISSING_COMMAND} ]];then
    echo "Missing command ${MISSING_COMMAND}";
    exit 1;
fi

# init cache
CACHE=$(pwd)/.cache
mkdir -p ${CACHE}
if [[ ! -d ${CACHE} ]] || [[ ! -z $(ls -A ${CACHE}) ]];then
    echo "Warning cache dir is non-empty, backup to ${CACHE}.bak";
    cp -rp ${CACHE} ${CACHE}.bak;
    rm -rf ${CACHE}/*;
fi

# get the latest version
GITHUB_RELEASE_INFO_API="https://api.github.com/repos/klzgrad/naiveproxy/releases/latest";
NAIVEPROXY_VERSION=$(curl -Ls ${GITHUB_RELEASE_INFO_API} | jq -r .tag_name)
if [[ -z ${NAIVEPROXY_VERSION} ]];then
    echo "Error when getting the naiveproxy latest release version: NAIVEPROXY_VERSION is empty";
    exit 1;
fi
echo "naiveproxy latest release version: ${NAIVEPROXY_VERSION}";

# download
GITHUB_RELEASE_DOWNLOAD="https://github.com/klzgrad/naiveproxy/releases/download/${NAIVEPROXY_VERSION}/naiveproxy-${NAIVEPROXY_VERSION}-linux-x64.tar.xz"
RELEASE_PATH="${CACHE}/naiveproxy.tar.xz"
curl -o ${RELEASE_PATH} -L ${GITHUB_RELEASE_DOWNLOAD}

# extract
echo "extracting ${RELEASE_PATH}"
tar --xz -x -f ${RELEASE_PATH} -C ${CACHE}

# binary file path
NAIVEPROXY_BIN=./.cache/naiveproxy-${NAIVEPROXY_VERSION}-linux-x64/naive
if [[ ! -f ${NAIVEPROXY_BIN} ]];then
    echo "can not found the naieproxy binary file: ${NAIVEPROXY_BIN}";
    exit 1;
fi

# prepare to build
export NAIVEPROXY_BIN
export NAIVEPROXY_VERSION

# start to build
echo "start to build image: naiveproxy:${NAIVEPROXY_VERSION}"
docker buildx build -t naiveproxy:${NAIVEPROXY_VERSION} \
--build-arg NAIVEPROXY_BIN=${NAIVEPROXY_BIN} \
--build-arg NAIVEPROXY_VERSION=${NAIVEPROXY_VERSION} \
$@ \
-f Dockerfile .
