#!/bin/bash -xe

WORKSPACE1=${WORKSPACE}
export BUILD_NUMBER
export HOSTNAME=`hostname`

for i in R3.0 R2.20 R2.0
do
    [ -d ${WORKSPACE}/.${i}_ubuntu14_juno ] && rm -rf ${WORKSPACE}/.${i}_ubuntu14_juno
    mkdir -p ${WORKSPACE}/.${i}_ubuntu14_juno; cd ${WORKSPACE}/.${i}_ubuntu14_juno
    repo init -u git@github.com:Juniper/contrail-vnc-private -m ${i}/ubuntu-14-04/manifest-juno.xml
    repo sync

    cd ${WORKSPACE}/.${i}_ubuntu14_juno/third_party
    python fetch_packages.py

    cd ../distro/third_party
    python fetch_packages.py

    cd ${WORKSPACE}/.${i}_ubuntu14_juno

    /usr/bin/scons

    cd ${WORKSPACE}
    rm -rf ${i}_ubuntu14_juno
    mv .${i}_ubuntu14_juno ${i}_ubuntu14_juno
    sudo /usr/local/opengrok-0.12.1/bin/OpenGrok index
done

for i in mainline R2.20 R3.0
do
    [ -d ${WORKSPACE}/.${i}_ubuntu14_kilo ] && rm -rf ${WORKSPACE}/.${i}_ubuntu14_kilo
    mkdir -p ${WORKSPACE}/.${i}_ubuntu14_kilo; cd ${WORKSPACE}/.${i}_ubuntu14_kilo
    repo init -u git@github.com:Juniper/contrail-vnc-private -m ${i}/ubuntu-14-04/manifest-kilo.xml
    repo sync

    cd ${WORKSPACE}/.${i}_ubuntu14_kilo/third_party
    python fetch_packages.py

    cd ../distro/third_party
    python fetch_packages.py

    cd ${WORKSPACE}/.${i}_ubuntu14_kilo

    /usr/bin/scons

    cd ${WORKSPACE}
    rm -rf ${i}_ubuntu14_kilo
    mv .${i}_ubuntu14_kilo ${i}_ubuntu14_kilo
    sudo /usr/local/opengrok-0.12.1/bin/OpenGrok index
done

#sudo /usr/local/opengrok-0.12.1/bin/OpenGrok index
