#!/bin/bash

echo "Started at `date`" 

# Set some environmental variables for GOVC

export GOVC_URL='vcenter.lab.hayweb.org'
export GOVC_USERNAME='administrator@vsphere.hayweb'
export GOVC_PASSWORD='Vi0lin2*'
export GOVC_INSECURE=1

# Set MAC addresses of the nodes in a hash table or associative array
declare -A netconfig
netconfig[bootstrap]="00:50:56:af:51:a9"
netconfig[master-1]="00:50:56:af:88:a3"
netconfig[master-2]="00:50:56:af:c3:10"
netconfig[master-3]="00:50:56:af:ca:59"
netconfig[worker-1]="00:50:56:af:82:5f"
netconfig[worker-2]="00:50:56:af:6b:cb"
netconfig[worker-3]="00:50:56:af:68:1f"

# Set some configuration to drive oct.sh

masters_count=3
workers_count=3
# Change both url and name when changing Fedora versions
template_url="https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/35.20220327.3.0/x86_64/fedora-coreos-35.20220327.3.0-vmware.x86_64.ova"
template_name="fedora-coreos-35.20220327.3.0-vmware.x86_64"
vcenter_content_library="contentstore"
cluster_name="cluster3"
cluster_folder="cluster3"
network_name="VM Network"
install_folder=`pwd`
okd_tools_release="4.10"

# Common functions 

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Do you want to continue? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            ;;
        *)
            exit 0
            ;;
    esac
}

# Print Configuration
echo ""
echo "-------Static MAC Addresses"
echo ${netconfig[@]}
echo ${!netconfig[*]}

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
confirm && ./oct.sh --provision-infrastructure --template-name "${template_name}" --library "${vcenter_content_library}" --cluster-name "${cluster_name}" --cluster-folder "${cluster_folder}" --network-name "${network_name}" --installation-folder "${install_folder}" --master-node-count ${masters_count} --worker-node-count ${workers_count} --static-mac-addresses "${netconfig[@]}"

# Turn on the cluster nodes
echo ""
echo "-------Turn on the cluster nodes"
./oct.sh --cluster-power on --cluster-name "${cluster_name}"  --master-node-count ${masters_count} --worker-node-count ${workers_count}

# Run the OpenShift installer 
# Switch log-level to info for a quieter output or debug for more
openshift-install --dir=$(pwd) wait-for bootstrap-complete  --log-level=debug

echo "Finished at `date`" 
