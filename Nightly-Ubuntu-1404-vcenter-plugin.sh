#!/bin/bash -x
set -e

BUILD_PLATFORM=ubuntu-14-04
BUILD_WORKAREA=${WORKSPACE}

PATH=$PATH:/ecbuilds/contrail-build-scripts/ec-bin:/ecbuilds/contrail-build-scripts/ec-steps
mkdir -p /ecbuilds/maven-repo
export MAVEN_OPTS=-Dmaven.repo.local=/ecbuilds/maven-repo

umask 022
export PATH=${PATH:-/ecbuilds/contrail-build-scripts/ec-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games}
export GITHUB_BUILD=${GITHUB_BUILD:-/github-build}
export BUILD_ARCHIVE_ROOT=${BUILD_ARCHIVE_ROOT:-/volume/contrail}
export BUILD_PLATFORM=${BUILD_PLATFORM:-ubuntu-14-04}
export BUILD_SKU
export BUILD_BRANCH
export BUILD_ID
export BUILD_WORKAREA=${BUILD_WORKAREA:-${WORKSPACE}}
export BUILD_ENV_DIR=${BUILD_ENV_DIR:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/build-envs}
export BUILD_START=${BUILD_START:-${BUILD_ID}}
export BUILD_SCRIPT_STEPS=${BUILD_SCRIPT_STEPS:-/ecbuilds/contrail-build-scripts/ec-steps}
export BUILD_SCRIPT_REPO=${BUILD_SCRIPT_REPO:-git@github.com:Juniper/contrail-build-scripts.git}
export BUILD_SCRIPT_CLONE=${BUILD_SCRIPT_CLONE:-/ecbuilds/contrail-build-scripts}
export BUILD_SCRIPT_BIN=${BUILD_SCRIPT_BIN:-/ecbuilds/contrail-build-scripts/ec-bin}
export BUILD_PLATFORM=${BUILD_PLATFORM:-ubuntu-14-04}
export BUILD_SKU=${BUILD_SKU:-vcenter}
export BUILD_ARCHIVE_DIR=${BUILD_ARCHIVE_DIR:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}}
export BUILD_ENV_FILE=${BUILD_ENV_FILE:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh}
export BUILD_NOTIFY_USERS=${BUILD_NOTIFY_USERS:-vmahuli@juniper.net}
export BUILD_HOST_INSTALLERS=${BUILD_HOST_INSTALLERS:-/ecbuilds/contrail-build-scripts/installers}

date
sudo bash -x ${BUILD_HOST_INSTALLERS}/pkg_install_ubuntu-14-04.sh

mkdir -p $BUILD_WORKAREA/sb

#hack to copy build-env.sh
touch $BUILD_WORKAREA/Build-env.sh

cat <<EOF >> ~/.ssh/config
UserKnownHostsFile=/dev/null
LogLevel=QUIET
StrictHostKeyChecking=no
EOF

cd ${BUILD_WORKAREA}
/ecbuilds/contrail-build-scripts/ec-bin/contrail-build -s sb -b ${BUILD_BRANCH} -a vcenter-plugin -k ${BUILD_SKU} -n ${BUILD_ID} -p python2.7 sandbox

cd sb
$BUILD_SCRIPT_STEPS/04_getgitlogs.sh

cd ..
/ecbuilds/contrail-build-scripts/ec-bin/contrail-build -n ${BUILD_ID} -s sb build

echo "Copying the Sandbox to Archive"

# Call the archive tool
# NOT YET /ecbuilds/contrail-build-scripts/ec-bin/contrail-archive -s /ecbuilds/PipeLine-vcenter/sb -b ${BUILD_BRANCH} -k ${BUILD_SKU} -a vcenter-plugin -n ${BUILD_ID} archive
# Just use rsync to do the copy

cd sb
mkdir -p /volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/vcenter-plugin/${BUILD_SKU}/store/sandbox
rsync -ac . /volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/vcenter-plugin/${BUILD_SKU}/store/sandbox

echo "Copying logs to sandbox"
mkdir -p /volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/vcenter-plugin/${BUILD_SKU}/build-logs

echo "Job number ${BUILD_ID} copied to filer /volume/contrail/${BUILD_BRANCH}/${BUILD_ID}"

cd /volume/contrail/${BUILD_BRANCH}/${BUILD_ID}

rsync -avR vcenter-plugin/juno/store/sandbox/build/contrail-vcenter-plugin* stack@anamika.englab.juniper.net:/github-build/${BUILD_BRANCH}/${BUILD_ID}/
rsync -avR vcenter-plugin/juno/store/sandbox/build/contrail-install-vcenter-plugin* stack@anamika.englab.juniper.net:/github-build/${BUILD_BRANCH}/${BUILD_ID}/
echo "rsyncs are done"

ssh stack@anamika.englab.juniper.net "touch /github-build/${BUILD_BRANCH}/${BUILD_ID}/vcenter-plugin/${BUILD_SKU}/COPY-DONE"
echo "Job number ${BUILD_ID} copied to anamika.englab.juniper.net"

echo ${NODE_NAME}
