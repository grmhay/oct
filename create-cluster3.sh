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

# Import the template
echo ""
echo "-------Import the template"
./oct.sh --import-template --library "${vcenter_content_library}" --template-url "${template_url}"

# Install the desired OKD tools
echo ""
echo "-------Install the desired OKD tools"
./oct.sh --install-tools --release "${okd_tools_release}"

# Launch the prerun to generate and modify the ignition files
echo ""
echo "-------Launch the prerun to generate and modify the ignition files"
./oct.sh --prerun --auto-secret

# Deploy the nodes for the cluster with the appropriate ignition data
echo ""
echo "-------Deploy the nodes for the cluster with the appropriate ignition data"
./oct.sh --provision-infrastructure --template-name "${template_name}" --library "${vcenter_content_library}" --cluster-name "${cluster_name}" --cluster-folder "${cluster_folder}" --network-name "${network_name}" --installation-folder "${install_folder}" --master-node-count ${masters_count} --worker-node-count ${workers_count} 

# Turn on the cluster nodes
echo ""
echo "-------Turn on the cluster nodes"
#./oct.sh --cluster-power on --cluster-name "${cluster_name}"  --master-node-count ${masters_count} --worker-node-count ${workers_count}

# Run the OpenShift installer 
#openshift-install --dir=$(pwd) wait-for bootstrap-complete  --log-level=info