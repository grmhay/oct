#!/bin/bash

# Set some environmental variables for GOVC

export GOVC_URL='vcenter.lab.hayweb.org'
export GOVC_USERNAME='administrator@vsphere.hayweb'
export GOVC_PASSWORD='Vi0lin2*'
export GOVC_INSECURE=1

# Set some configuration to drive oct.sh

masters_count=3
workers_count=3
# template_url="https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/33.20210314.2.0/x86_64/fedora-coreos-33.20210314.2.0-vmware.x86_64.ova"
template_url="https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20220522.3.0/x86_64/fedora-coreos-36.20220522.3.0-vmware.x86_64.ova"
# template_name="fedora-coreos-33.20210201.2.1-vmware.x86_64"		
template_name="fedora-coreos-36.20220522.3.0-vmware.x86_64"
vcenter_content_library="contentstore"
cluster_name="cluster3"
cluster_folder="cluster3"
network_name="VM Network"
install_folder=`pwd`
okd_tools_release="4.10"

# Destroy the cluster

./oct.sh --destroy --cluster-name "${cluster_name}" --master-node-count ${masters_count} --worker-node-count ${workers_count}

rm master.ign bootstrap.ign worker.ign

rm -r ./manifests.bak
rm -r ./openshift.bak
