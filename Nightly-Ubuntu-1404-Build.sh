#!/bin/bash -xe


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
export BUILD_SCRIPTS=${BUILD_SCRIPTS:-/ecbuilds/contrail-build-scripts/scripts}
export BUILD_SCRIPT_CLONE=${BUILD_SCRIPT_CLONE:-/ecbuilds/contrail-build-scripts}
export BUILD_SCRIPT_BIN=${BUILD_SCRIPT_BIN:-/ecbuilds/contrail-build-scripts/ec-bin}
export BUILD_PLATFORM=${BUILD_PLATFORM:-ubuntu-14-04}
export BUILD_ARCHIVE_DIR=${BUILD_ARCHIVE_DIR:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}}
export BUILD_ENV_FILE=${BUILD_ENV_FILE:-/volume/contrail/${BUILD_BRANCH}/${BUILD_ID}/${BUILD_PLATFORM}/${BUILD_SKU}/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh}
export BUILD_NOTIFY_USERS=${BUILD_NOTIFY_USERS:-vmahuli@juniper.net}
export BUILD_HOST_INSTALLERS=${BUILD_HOST_INSTALLERS:-/ecbuilds/contrail-build-scripts/installers}
export BUILD_SANDBOX=${BUILD_SANDBOX:-sb}

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

#cd $BUILD_WORKAREA/sb/vrouter
#git config --global user.email "builder@juniper.net"
#git config --global user.name "Contrail Builder"
#git fetch https://review.opencontrail.org/Juniper/contrail-vrouter refs/changes/83/21783/2 && git checkout FETCH_HEAD
#git fetch https://review.opencontrail.org/Juniper/contrail-vrouter refs/changes/17/24617/1 && git cherry-pick FETCH_HEAD
#git fetch https://review.opencontrail.org/Juniper/contrail-vrouter refs/changes/45/24645/1 && git cherry-pick FETCH_HEAD
#$BUILD_SCRIPT_STEPS/03_CompileCode.sh
#$BUILD_SCRIPT_STEPS/04_getgitlogs.sh


python third_party/fetch_packages.py
python distro/third_party/fetch_packages.py
python contrail-webui-third-party/fetch_packages.py

date
$BUILD_SCRIPT_STEPS/07_Packaging.sh
date

#install docker engine
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo sh -c 'echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list'
sudo apt-get update
sudo apt-get -y install docker-engine

#start docker service
sudo service docker start || true

#test docker
sudo docker run hello-world

#add group
sudo groupadd docker || true

#add user
sudo usermod -aG docker contrail-builder

#restart docker
sudo service docker restart

sudo bash -x $BUILD_SCRIPTS/build_docker_containers.sh $BUILD_SKU $BUILD_BRANCH
date
sudo $BUILD_SCRIPT_STEPS/08_ContainerAppBuild.sh $BUILD_SKU $BUILD_BRANCH $BUILD_PLATFORM $BUILD_ID $BUILD_WORKAREA $BUILD_SANDBOX $BUILD_ARCHIVE_DIR
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
#export API_TOKEN="53e49510bf0157984b85239068b2e04b"

curl --user builder:b086ef3449c0a260aa4accdf961ac7e9 http://anamika.englab.juniper.net:8080/job/start_sanity/build --form json='{"parameter": [{"name":"BUILD_SKU", "value":"${BUILD_SKU}"}, {"name":"BUILD_PLATFORM", "value":"ubuntu-14-04"}, {"name":"BUILD_ID", "value":"${BUILD_ID}"}, {"name":"GITHUB_BUILD", "value":"${/github-build}"}, {"name":"BUILD_BRANCH", "value":"${BUILD_BRANCH}"}]}'
date
