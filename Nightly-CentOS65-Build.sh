#!/bin/bash -x

set -e

BUILD_PLATFORM=centos65
BUILD_WORKAREA=${WORKSPACE}

PATH=$PATH:/ecbuilds/contrail-build-scripts/ec-bin:/ecbuilds/contrail-build-scripts/ec-steps
mkdir -p /ecbuilds/maven-repo
export MAVEN_OPTS=-Dmaven.repo.local=/ecbuilds/maven-repo

export PATH
export GITHUB_BUILD
export BUILD_ARCHIVE_ROOT
export BUILD_BRANCH
export BUILD_PLATFORM
export BUILD_SKU
export BUILD_ID
export BUILD_WORKAREA
export BUILD_ARCHIVE_DIR
export BUILD_ENV_DIR
export BUILD_ENV_FILE
export BUILD_START
export BUILD_SCRIPT_STEPS
export BUILD_SCRIPT_REPO
export BUILD_SCRIPT_CLONE
export BUILD_SCRIPT_BIN
export BUILD_SCRIPT_STEPS

mkdir -p $BUILD_WORKAREA/sb

#hack to copy build-env.sh
touch $BUILD_WORKAREA/Build-env.sh

cat <<EOF >> ~/.ssh/config
UserKnownHostsFile=/dev/null
LogLevel=QUIET
StrictHostKeyChecking=no
EOF

$BUILD_SCRIPT_STEPS/01_CreateSandbox.sh
$BUILD_SCRIPT_STEPS/02_CheckOutSource.sh
$BUILD_SCRIPT_STEPS/03_CompileCode.sh
$BUILD_SCRIPT_STEPS/04_getgitlogs.sh
$BUILD_SCRIPT_STEPS/07_Packaging.sh

$BUILD_SCRIPT_STEPS/08_ArchiveBuild.sh
$BUILD_SCRIPT_STEPS/09_UpdateLatest.sh

$BUILD_SCRIPT_STEPS/10_CopyImage.sh
$BUILD_SCRIPT_STEPS/15_CopyImagePhase2.sh

curl --user builder:b086ef3449c0a260aa4accdf961ac7e9 http://anamika.englab.juniper.net:8080/job/JenkinsInfra-SanityScheduler/build --form json='{"parameter": [{"name":"DISTRO", "value":"centos64"}, {"name":"SKU", "value":"${BUILD_SKU}"}, {"name":"ID", "value":"${BUILD_ID}"}, {"name":"BRANCH", "value":"${BUILD_BRANCH}"}]}'


