#!/bin/bash -xe

export BUILD_NUMBER
BUILDDIR="/ecbuilds"
cd ${BUILDDIR}/contrail-vnc-private

mv Build-Branch Build-Branch-bak

echo "${BRANCH}" >> Build-Branch
echo "Running the contrail-create-buildarchive command"

PATH=${BUILDDIR}/contrail-build-scripts/ec-bin:${PATH}
cd ${BUILDDIR}

if [ -d /volume/contrail/$BRANCH ]; then
    cd /volume/contrail/$BRANCH
    if [ -s LATEST ]; then
        CURR_BNO=`ls -l LATEST | cut -d '>' -f2`
        BNO=`expr ${CURR_BNO} \+ 1`
    else
        BNO=1
    fi
    export BNO
    echo "${BNO}" > ${WORKSPACE}/build_id.txt
    cd -
else
    echo "No such branch found!!"
    exit 1
fi

export BUILD_NUMBER=${BNO}

#sed -i "s/buildId = \"BUILD_NUMBER\"/buildId = \"${BUILD_NUMBER}\"/" ${BUILDDIR}/contrail-build-scripts/ec-bin/contrail-create-buildarchive

${BUILDDIR}/contrail-build-scripts/ec-bin/contrail-create-buildarchive -v -p "${BUILDDIR}/contrail-vnc-private" parse

export PATH=${PATH}
export GITHUB_BUILD=/github-build-jenkins
export BUILD_ARCHIVE_ROOT=/volume/contrail
export BUILD_BRANCH=${BRANCH}
export BUILD_ID=${BUILD_NUMBER}
export BUILD_WORKAREA=${WORKSPACE}
export BUILD_ENV_DIR=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/build-envs
export BUILD_START=${BUILD_ID}
export BUILD_SCRIPT_STEPS=/ecbuilds/contrail-build-scripts/ec-steps
export BUILD_SCRIPT_REPO=git@github.com:Juniper/contrail-build-scripts.git
export BUILD_SCRIPT_CLONE=/ecbuilds/contrail-build-scripts
export BUILD_SCRIPT_BIN=$BUILD_SCRIPT_CLONE/ec-bin
export BUILD_SCRIPT_STEPS=$BUILD_SCRIPT_CLONE/ec-steps
export BUILD_PLATFORM=ubuntu-14-04
export BUILD_SKU=kilo
export BUILD_ARCHIVE_DIR=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/$BUILD_SKU
export BUILD_ENV_FILE=$BUILD_ARCHIVE_DIR/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh
export BUILD_NOTIFY_USERS="vmahuli@juniper.net"
mkdir -p $BUILD_WORKAREA/sb
touch $BUILD_WORKAREA/Build-env.sh

LATEST=`ls -l $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/LATEST | cut -d '>' -f2 | tr -d '[[:space:]]'`
PRIOR_MANIFEST=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/${LATEST}/ubuntu-14-04/kilo/manifest.xml
$BUILD_SCRIPT_STEPS/09_UpdateLatest.sh

#EC_SYNC
if [ ${EC_SYNC} = "TRUE" ]; then
    MANIFEST=`find /volume/contrail/${BRANCH}/LATEST -name  manifest.xml -follow`
    for file in ${MANIFEST}
    do
      if [ -f ${file} ]; then
          sshpass -p Juniper1 scp root@contrail-ec-build04.juniper.net:${file} ${file}
          if [ $? = 0 ]; then
              echo "Copied root@contrail-ec-build04.juniper.net:${file}..."
          fi
      fi
    done
fi

$BUILD_SCRIPT_STEPS/01_CreateSandbox.sh
$BUILD_SCRIPT_STEPS/02_CheckOutSource.sh

echo "${BUILD_BRANCH}-${BNO}-${BUILD_SKU}" > ${WORKSPACE}/build_ver.txt

echo "Getting git commit information"
cd $BUILD_WORKAREA/sb
if [ -f $PRIOR_MANIFEST ]; then
    echo "Getting git commit information"
    $BUILD_SCRIPT_BIN/getgitcommits.py $PRIOR_MANIFEST  $BUILD_WORKAREA/sb/.repo/manifest.xml

    cp $BUILD_WORKAREA/sb/git-commits.html $BUILD_ARCHIVE_DIR/.
    sort -u $BUILD_WORKAREA/sb/commit-users > $BUILD_ARCHIVE_DIR/commit-users

    BUILD_NOTIFY_USERS="$(cat $BUILD_ARCHIVE_DIR/commit-users | grep "juniper.net" | paste -s -d';' - )"
    export BUILD_NOTIFY_USERS
fi

#for BUILD_PLATFORM in ubuntu-14-04 ubuntu-12-04 redhat70 centos65 centos71 vcenter-plugin
for BUILD_PLATFORM in redhat70
do
   for BUILD_SKU in icehouse juno kilo vcenter liberty mitaka
   do
      if [ -d $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU} ]; then
          # Create property file for kilo
          echo "umask 022" > $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "PATH=${PATH}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "GITHUB_BUILD=/github-build-jenkins" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_ARCHIVE_ROOT=/volume/contrail" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_BRANCH=${BRANCH}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SKU=${BUILD_SKU}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_ID=${BUILD_NUMBER}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          #echo "BUILD_WORKAREA=${WORKSPACE}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_ARCHIVE_DIR=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/$BUILD_SKU" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_ENV_DIR=$BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/build-envs" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_ENV_FILE=$BUILD_ARCHIVE_DIR/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_START=${BUILD_ID}" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SCRIPT_STEPS=/ecbuilds/contrail-build-scripts/ec-steps" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SCRIPT_REPO=git@github.com:Juniper/contrail-build-scripts.git" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SCRIPT_CLONE=/ecbuilds/contrail-build-scripts" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SCRIPT_BIN=$BUILD_SCRIPT_CLONE/ec-bin" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_SCRIPT_STEPS=$BUILD_SCRIPT_CLONE/ec-steps" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_NOTIFY_USERS=$BUILD_NOTIFY_USERS" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          echo "BUILD_PLATFORM=$BUILD_PLATFORM" >> $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties
          mkdir -p $BUILD_ENV_DIR
          cp $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/${BUILD_SKU}.properties $BUILD_ENV_DIR/Build-${BUILD_BRANCH}-${BUILD_ID}-${BUILD_PLATFORM}-${BUILD_SKU}-env.sh
          touch $BUILD_ARCHIVE_ROOT/$BUILD_BRANCH/$BUILD_ID/$BUILD_PLATFORM/${BUILD_SKU}/Jenkins_build

          
          if [ ${BUILD_PLATFORM} = "ubuntu-14-04" -o ${BUILD_PLATFORM} = "centos71" -o ${BUILD_PLATFORM} = "redhat70" ]; then
              [ ${BUILD_PLATFORM} = "ubuntu-14-04" ] && GECOS="--disabled-password --gecos"
              [ ${BUILD_PLATFORM} = "centos71" -o ${BUILD_PLATFORM} = "redhat70" ]     && GECOS="--comment"
              echo "Launching build VM..."
              echo
              source ${BUILD_SCRIPT_CLONE}/scripts/spawn-vm.sh
              
              [ ${BUILD_PLATFORM} = "ubuntu-14-04" ] && ci-create-vm-ubuntu-14-04 | tee /tmp/createvm.$$
              [ ${BUILD_PLATFORM} = "centos71" ]     && ci-create-vm-centos       | tee /tmp/createvm.$$
              [ ${BUILD_PLATFORM} = "redhat70" ]     && ci-create-vm-redhat       | tee /tmp/createvm.$$
              ip=`cat /tmp/createvm.$$ | grep " floating_ip_address " | cut -d "|" -f3 | xargs`
              [ ! -f ~/jenkins-cli.jar ] && wget http://cs-build.contrail.juniper.net:8080/jnlpJars/jenkins-cli.jar --timeout=10 -P ~/
              
              #to connect jenkins slave install default-jre
              #sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip sudo apt-get install -y default-jre
              #Download jre from http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jre-8u92-linux-x64.tar.gz"
              #sshpass -p c0ntrail123 scp -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null ~/jre-8u92-linux-x64.tar.gz root@$ip:~/
              set +x
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "curl -O http://10.84.5.120/cs-shared/images/jre-8u92-linux-x64.tar.gz"
              if [ $? != 0 ]; then
                  set -x
                  #try with a different server
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "curl -O http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jre-8u92-linux-x64.tar.gz"
              fi
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "tar -xzvf /root/jre-8u92-linux-x64.tar.gz"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "ln -s /root/jre1.8.0_92/bin/java /usr/bin/java"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "adduser $GECOS 'contrail-builder' contrail-builder"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "mkdir -p /ecbuilds/jenkins  /volume/contrail /github-build/distro-packages/build /cs-shared/builder /home/contrail-builder/.ssh"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "echo 'contrail-builder:c0ntrail123' | chpasswd"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "chown contrail-builder:contrail-builder /ecbuilds"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "chown contrail-builder:contrail-builder /ecbuilds/jenkins"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "chown contrail-builder:contrail-builder /home/contrail-builder/.ssh"            
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "echo '10.160.0.156:/contrail/contrail02/Dry-run  /volume/contrail nfs      rw             0        0' >> /etc/fstab"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "echo '10.160.0.156:/contrail/contrail/distro-packages/build/  /github-build/distro-packages/build nfs      rw             0        0' >> /etc/fstab"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "echo 'contrail-builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "ln -s /github-build/distro-packages/build /cs-shared/builder/cache"
              if [ ${BUILD_PLATFORM} = "ubuntu-14-04" ]; then
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "apt-get install -y nfs-common git"
              fi
              if [ ${BUILD_PLATFORM} = "redhat70" ]; then
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "yum update -y"
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "yum downgrade redhat-release-server -y"
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "yum downgrade redhat-release-server -y"
              fi
              if [ ${BUILD_PLATFORM} = "centos71" -o ${BUILD_PLATFORM} = "redhat70" ]; then
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "yum install -y nfs-utils git"
                  sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "sed -i 's/Defaults    requiretty//' /etc/sudoers"
              fi
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "mount -a"
              sshpass -p c0ntrail123 scp -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null ~/.ssh/id_rsa* contrail-builder@$ip:/home/contrail-builder/.ssh/.
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$ip "chown contrail-builder:contrail-builder /home/contrail-builder/.ssh/*"
              sshpass -p c0ntrail123 ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null contrail-builder@$ip "ssh -o StrictHostKeyChecking=no git@github.com || true"
              echo "Adding Node to Jenkins at http://cs-build.contrail.juniper.net:8080/computer"
              echo
              slave_ip=`echo $ip | sed -e 's/\./-/g'`
              bash -x ${BUILD_SCRIPT_CLONE}/scripts/add-node.sh http://cs-build.contrail.juniper.net:8080/ contrail-build-${BUILD_PLATFORM}-${slave_ip}-${BUILD_SKU} $ip ${BUILD_PLATFORM}    
              sleep 10
          fi
      fi
   done  
done



#rm -rf $BUILD_SCRIPT_CLONE

