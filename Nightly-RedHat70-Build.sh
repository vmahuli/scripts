#!/bin/bash -x
set -e

BUILD_PLATFORM=redhat70
BUILD_WORKAREA=${WORKSPACE}

PATH=$PATH:/ecbuilds/contrail-build-scripts/ec-bin:/ecbuilds/contrail-build-scripts/ec-steps
mkdir -p /ecbuilds/maven-repo
export MAVEN_OPTS=-Dmaven.repo.local=/ecbuilds/maven-repo

umask 022
export PATH=${PATH:-/ecbuilds/contrail-build-scripts/ec-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games}
export GITHUB_BUILD=${GITHUB_BUILD:-/github-build}
export BUILD_ARCHIVE_ROOT=${BUILD_ARCHIVE_ROOT:-/volume/contrail}
export BUILD_PLATFORM=${BUILD_PLATFORM:-redhat70}
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
export BUILD_ARCHIVE_DIR=${BUILD_ARCHIVE_DIR:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}}
export BUILD_ENV_FILE=${BUILD_ENV_FILE:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh}
export BUILD_NOTIFY_USERS=${BUILD_NOTIFY_USERS:-vmahuli@juniper.net}
export BUILD_HOST_INSTALLERS=${BUILD_HOST_INSTALLERS:-/ecbuilds/contrail-build-scripts/installers}
export BUILD_SANDBOX=${BUILD_SANDBOX:-sb}

date
# There are problems while creating redhat70 build host, hence use redhat build vm from snapshot
#sudo bash -x ${BUILD_HOST_INSTALLERS}/pkg_install_redhat70.sh

mkdir -p $BUILD_WORKAREA/sb

#hack to copy build-env.sh
touch $BUILD_WORKAREA/Build-env.sh

cat <<EOF >> ~/.ssh/config
UserKnownHostsFile=/dev/null
LogLevel=QUIET
StrictHostKeyChecking=no
EOF

date
#install android repo
if [[ ! -r /usr/local/bin/repo ]]; then
    echo info: installing /usr/local/bin/repo
    sudo sh -c 'curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo'
    sudo chmod 755 /usr/local/bin/repo
fi
date

#check for slave_start service
sudo service slave_start  stop || true
sudo rm /tmp/cache || true

date
$BUILD_SCRIPT_STEPS/01_CreateSandbox.sh
date
$BUILD_SCRIPT_STEPS/02_CheckOutSource.sh
date

PREV_ID="$(expr ${BUILD_ID} \- 1)"
PRIOR_MANIFEST=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/${PREV_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/manifest.xml

cd $BUILD_WORKAREA/sb
if [ -f $PRIOR_MANIFEST ]; then
    echo "Getting git commit information"
    $BUILD_SCRIPT_BIN/getgitcommits.py $PRIOR_MANIFEST  $BUILD_WORKAREA/sb/.repo/manifest.xml

    cp $BUILD_WORKAREA/sb/git-commits.html $BUILD_ARCHIVE_DIR/.
    sort -u $BUILD_WORKAREA/sb/commit-users > $BUILD_ARCHIVE_DIR/commit-users

    BUILD_NOTIFY_USERS="$(cat $BUILD_ARCHIVE_DIR/commit-users | grep "juniper.net" | paste -s -d';' - )"
    export BUILD_NOTIFY_USERS
fi

mkdir -p /tmp/cache
rsync -avz contrail-builder@contrail-ec-build19.juniper.net:/tmp/cache/contrail-builder /tmp/cache/.

date
python third_party/fetch_packages.py
python distro/third_party/fetch_packages.py
python contrail-webui-third-party/fetch_packages.py

date
$BUILD_SCRIPT_STEPS/07_Packaging.sh
date
$BUILD_SCRIPT_STEPS/08_ArchiveBuild.sh
date
$BUILD_SCRIPT_STEPS/09_UpdateLatest.sh
date
$BUILD_SCRIPT_STEPS/10_CopyImage.sh
date
$BUILD_SCRIPT_STEPS/15_CopyImagePhase2.sh
date

echo ${NODE_NAME}
