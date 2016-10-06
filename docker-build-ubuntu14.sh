#!/bin/bash -xe

if [ ${BUILD_BRANCH} = "mainline" ]; then
    wget https://raw.githubusercontent.com/Juniper/contrail-controller/master/src/base/version.info --timeout=10
else
    wget https://raw.githubusercontent.com/Juniper/contrail-controller/${BUILD_BRANCH}/src/base/version.info --timeout=10
fi

version=$(cat version.info)

mkdir -p ${WORKSPACE}
export BUILD_WORKAREA=${WORKSPACE}
export GITHUB_BUILD=${GITHUB_BUILD:-/github-build}
export BUILD_PLATFORM=${BUILD_PLATFORM:-ubuntu-14-04}
export BUILD_ARCHIVE_DIR="${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}"
export TEST_PKG="${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/artifacts_extra/contrail-test-ci-*.tgz"
export TEST_PKG2="${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/artifacts_extra/contrail-test-${version}-*.tgz"
export FAB_UTILS="${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/artifacts_extra/contrail-fabric-utils-*.tgz"
export CONTRAIL_INSTALL_PKGS=`ls ${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/contrail-install-packages*.deb`
export SVL_ARCHIVE_DIR="/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}"

mkdir -p ${BUILD_WORKAREA}/build/artifacts && cd ${BUILD_WORKAREA}


clean_up() {
    for j in `docker images| tr -s ' ' | cut -d ' ' -f3 | grep -v IMAGE`
    do
        docker rmi -f $j
    done

    for i in `docker ps -a | tr -s ' ' | cut -d ' ' -f1 | grep -v CONTAINER`
    do
        docker rm -f $i
    done
}

clean_up
if [ ${USE_LATEST} = "true" ]; then
    if [ ${BUILD_BRANCH} = "mainline" ]; then
        wget https://raw.githubusercontent.com/Juniper/contrail-test-ci/master/install.sh && chmod 755 install.sh
    else
        wget https://raw.githubusercontent.com/Juniper/contrail-test-ci/${BUILD_BRANCH}/install.sh && chmod 755 install.sh
    fi
    ./install.sh docker-build --ci-repo https://github.com/Juniper/contrail-test-ci.git --ci-ref ${BUILD_BRANCH} --fab-repo https://github.com/Juniper/contrail-fabric-utils.git --fab-ref ${BUILD_BRANCH} -u http://mayamruga.englab.juniper.net${CONTRAIL_INSTALL_PKGS} --export ${BUILD_WORKAREA}/build/artifacts contrail-test-ci
    clean_up
    ./install.sh docker-build --ci-repo https://github.com/Juniper/contrail-test-ci.git --ci-ref ${BUILD_BRANCH} --test-repo https://github.com/Juniper/contrail-test.git --test-ref ${BUILD_BRANCH} --fab-repo https://github.com/Juniper/contrail-fabric-utils.git --fab-ref ${BUILD_BRANCH} -u http://mayamruga.englab.juniper.net${CONTRAIL_INSTALL_PKGS} --export ${BUILD_WORKAREA}/build/artifacts contrail-test
    clean_up
else
    cp ${TEST_PKG} ${BUILD_WORKAREA}
    cp ${TEST_PKG2} ${BUILD_WORKAREA}
    cp ${FAB_UTILS} ${BUILD_WORKAREA}
    tar -xzvf ${TEST_PKG}
    ./contrail-test-ci/install.sh docker-build --ci-artifact ./contrail-test-ci-*.tgz --fab-artifact contrail-fabric-utils-*-${BUILD_ID}~${BUILD_SKU}.tgz -u http://mayamruga.englab.juniper.net${CONTRAIL_INSTALL_PKGS} --export ${BUILD_WORKAREA}/build/artifacts contrail-test-ci
    clean_up
    ./contrail-test-ci/install.sh docker-build --ci-artifact ./contrail-test-ci-*.tgz --test-artifact ./contrail-test-${version}-*.tgz --fab-artifact contrail-fabric-utils-*-${BUILD_ID}~${BUILD_SKU}.tgz -u http://mayamruga.englab.juniper.net${CONTRAIL_INSTALL_PKGS} --export ${BUILD_WORKAREA}/build/artifacts contrail-test
    clean_up
fi

cd ${BUILD_WORKAREA}/build/artifacts

DOCKER_PKG1=`ls docker-image-contrail-test-ci-${BUILD_SKU}-*-${BUILD_ID}.tar.gz`
DOCKER_PKG2=`ls docker-image-contrail-test-${BUILD_SKU}-*-${BUILD_ID}.tar.gz`

scp ${DOCKER_PKG1} contrail-builder@contrail-ec-build04:${SVL_ARCHIVE_DIR}/artifacts
scp ${DOCKER_PKG2} contrail-builder@contrail-ec-build04:${SVL_ARCHIVE_DIR}/artifacts

chmod 777 ${BUILD_ARCHIVE_DIR}/artifacts
chmod 777 ${BUILD_ARCHIVE_DIR}/artifacts_extra
chmod 777 ${BUILD_ARCHIVE_DIR}
chmod 777 ${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}

cp ${DOCKER_PKG1} ${BUILD_ARCHIVE_DIR}/artifacts
cp ${DOCKER_PKG2} ${BUILD_ARCHIVE_DIR}/artifacts

chmod 544 ${BUILD_ARCHIVE_DIR}/artifacts
chmod 544 ${BUILD_ARCHIVE_DIR}/artifacts_extra
chmod 544 ${BUILD_ARCHIVE_DIR}
chmod 544 ${GITHUB_BUILD}/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}
