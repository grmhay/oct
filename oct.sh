#!/bin/bash

OC_DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz"
GOVC_DOWNLOAD_URL="https://github.com/vmware/govmomi/releases/download/v0.24.0/govc_linux_amd64.gz"
BIN_DIR=${HOME}/bin

die() {
	echo "$1"
	exit 1
}

show_help() {
  echo -e "\n-h|-?|--help

--auto-secret

Automatically use the "dummy" pull secret instead of prompting for one.

--install-tools

Calls the install_cluster_tools() function. This flag should be used in conjunction with the --release flag.

--prerun

Call the launch_prerun() function.

--provision-infrastructure

Calls the provision_cluster_infrastructure() function. This flag should be accompanied by the --template-name, --library, --cluster-name, --cluster-folder, --network-name, --installation-folder, --master-node-count, and --worker-node-count flags with their appropriate values. Optionally the static-mac-addresses if you use them to DHCP IPs in the network.

--destroy

Calls the destroy-cluster() function. This should be accompanied by the --cluster-name, --master-node-count, and --worker-node-count flags with their appropriate values.

--clean

Calls the clean() function, which removes all generated files from an installation.

--release version

The release version you wish to install the OKD/OpenShift tools for. This can be the complete release version (e.g. "4.7.0-0.okd-2021-03-07-090821") or the just the major.minor version, in which case the latest build of that version will be used (e.g. "4.7")

--cluster-power [on/off]

Calls the manage_power()function. Values are "on" and "off". This should be accompanied by the --cluster-name, --master-node-count, and --worker-node-count flags with their appropriate values.

--library name

The name of the vSphere Content Library where the VM template can be found

--template-name name

The name of the VM template to use when deploying nodes

--cluster-name name

The name of the cluster. This is used for assembling the node names and URLs (e.g. worker-1.*name.example.com)

--master-node-count number

The desired number of master nodes. This flag should be used in conjunction with --worker-node-count, --build, --destroy, and --cluster-power.

--worker-node-count number

The desired number of worker nodes. This flag should be used in conjunction with --master-node-count, --build, --destroy, and --cluster-power.

--cluster-folder folder

The folder on vSphere where the VMs will be deployed into.

--network-name name

The name of the vSphere network that the deployed VMs should use (e.g. the default "VM Network")

--installation-folder path

The path to the folder with the installation materials.

-v|--verbose

Set the verbosity level."

}	


while :; do
	case $1 in
		-h|-\?|--help)
			show_help
			exit
			;;
		--auto-secret)
			auto_secret=1
			;;    
		--install-tools)
			install_tools=1
			;;
		--install-config-template)
			if [ "$2" ]; then
                                install_config_template_path=$2
                                shift
                        else
                                die 'ERROR: "--install-config-template" requires a non-empty option argument.'
                        fi
                        ;;
		--prerun)
			prerun=1
			;;
		--provision-infrastructure)
			provision_infrastructure=1
			;;
		--destroy)
			destroy=1
			;;
    		--deploy-node)
			deploy_single_node=1
                        ;;			
		--clean)
			clean=1
			;;
                --import-template)
                        import_template=1
			;;
                --template-url)
                        if [ "$2" ]; then
                                template_url=$2
                                shift
                        else
                                die 'ERROR: "--template-url" requires a non-empty option argument.'
                        fi
                        ;;

		--release)
                        if [ "$2" ]; then
                                release=$2
                                shift
                        else
                                die 'ERROR: "--release" requires a non-empty option argument.'
                        fi
                        ;;
		--cluster-power)
			if [ "$2" ]; then
				cluster_power_action=$2
				shift
			else
				die 'ERROR: "--power" requires a non-empty option argument.'
			fi
			;;
		--library)
			if [ "$2" ]; then
				library=$2
				shift
			else
				die 'ERROR: "--library" requires a non-empty option argument.'
			fi
			;;	    
		--template-name)
			if [ "$2" ]; then
				template_name=$2
				shift
			else
				die 'ERROR: "--template-name" requires a non-empty option argument.'
			fi
			;;	    
		--cluster-name)
			if [ "$2" ]; then
				cluster_name=$2
				shift
			else
				die 'ERROR: "--cluster-name" requires a non-empty option argument.'
			fi
			;;
		--cluster-folder)
			if [ "$2" ]; then
				cluster_folder=$2
				shift
			else
				die 'ERROR: "--vm-folder" requires a non-empty option argument.'
			fi
			;;
		--network-name)
			if [ "$2" ]; then
				network_name=$2
				shift
			else
				die 'ERROR: "--network-name" requires a non-empty option argument.'
			fi
			;;	    
		--installation-folder)
			if [ "$2" ]; then
				installation_folder=$2
				shift
			else
				die 'ERROR: "--installation_folder" requires a non-empty option argument.'
			fi
			;;
		--master-node-count)
			if [ "$2" ]; then
				master_node_count=$2
				shift
			else
				die 'ERROR: "--master-node-count" requires a non-empty option argument.'
			fi
			;;
		--worker-node-count)
			if [ "$2" ]; then
				worker_node_count=$2
				shift
			else
				die 'ERROR: "--worker-node-count" requires a non-empty option argument.'
			fi
			;;

		--vm-name)
                        if [ "$2" ]; then
                                vm_name=$2
                                shift
                        else
                                die 'ERROR: "--vm-name" requires a non-empty option argument.'
                        fi
                        ;;
		--vm-cpu)
                        if [ "$2" ]; then
                               vm_cpu=$2
                                shift
                        else
                                die 'ERROR: "--vm-cpu" requires a non-empty option argument.'
                        fi
                        ;;
		--vm-memory)
                        if [ "$2" ]; then
                                vm_memory=$2
                                shift
                        else
                                die 'ERROR: "--vm-memory" requires a non-empty option argument.'
                        fi
                        ;;
		--vm-disk)
                        if [ "$2" ]; then
                                vm_disk=$2
                                shift
                        else
                                die 'ERROR: "--vm-disk" requires a non-empty option argument.'
                        fi
                        ;;
		--ignition-file)
                        if [ "$2" ]; then
                                ignition_file_path=$2
                                shift
                        else
                                die 'ERROR: "--ignition-file" requires a non-empty option argument.'
                        fi
                        ;;	
		--ipcfg)
                        if [ "$2" ]; then
                                ipcfg=$2
                                shift
                        else
                                die 'ERROR: "--ipcfg" requires a non-empty option argument.'
                        fi
                        ;;
		--static-mac-addresses)
						if [ "$2" ]; then
								static_mac_addresses=$2
								
								# Horrible hack - Now I can't get the hash array to pass in so we reset the array here for now again
								unset static_mac_addresses

								declare -A static_mac_addresses
								static_mac_addresses[bootstrap]="00:50:56:af:51:a9"
								static_mac_addresses[master-1]="00:50:56:af:88:a3"
								static_mac_addresses[master-2]="00:50:56:af:c3:10"
								static_mac_addresses[master-3]="00:50:56:af:ca:59"
								static_mac_addresses[worker-1]="00:50:56:af:82:5f"
								static_mac_addresses[worker-2]="00:50:56:af:6b:cb"
								static_mac_addresses[worker-3]="00:50:56:af:68:1f"

								echo ""
								echo "----- We have this configuration for MAC addresses"
								for key in "${!static_mac_addresses[@]}"
									do
										echo -n "hostname  : $key, "
										echo "MAC Addresses: ${static_mac_addresses[$key]}"
								done
								shift
						else
								die 'ERROR: "--static-mac-addresses" requires a non-empty option argument.'
						fi
						;;
		--boot)
                        boot_vm=1
                        ;;
		--query-fcos)
                        query_fcos=1
                        ;;	
		--stream-name)
			if [ "$2" ]; then
                                stream_name=$2
                                shift
                        else
                                die 'ERROR: "--stream-name" requires a non-empty option argument.'
                        fi
                        ;;
		-v|--verbose)
			verbose=$((verbose + 1))
			;;
		--)
			shift
			break
			;;
		-?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;
		*)
			break
	esac

	shift
done

check_oc() {
	
	if ! command -v oc &> /dev/null
        then
                while true; do
                        read -p "The oc command could not be found. Would you like to download it? " yn
                        case $yn in
                                [Yy]* )
                                        install_oc;break;;
                                [Nn]* ) exit;;
                                * ) echo "Please answer yes or no.";;
                        esac
                done
        fi

}	

install_oc() {
	curl -L ${OC_DOWNLOAD_URL} > /tmp/oc.tar.gz
	tar xvf /tmp/oc.tar.gz -C /tmp 
	mv /tmp/oc ${BIN_DIR}
	mv /tmp/kubectl ${BIN_DIR}
	echo "The oc and kubectl applications have been downloaded to directory ${BIN_DIR}"
}	

check_govc() {

	if ! command -v govc &> /dev/null
	then
		while true; do
			read -p "The govc command could not be found. Would you like to download it? " yn
			case $yn in
				[Yy]* ) 
					install_govc;break;;
				[Nn]* ) exit;;
				* ) echo "Please answer yes or no.";;
			esac
		done
	fi
}

install_govc() {
	curl -L ${GOVC_DOWNLOAD_URL} | gunzip > ${BIN_DIR}/govc 
	chmod +x ${BIN_DIR}/govc
	echo "The govc application has been downloaded to the directory ${BIN_DIR}"	
}	

import_template_from_url(){
	file_name=$(basename ${template_url})
	template_name="${file_name%.*}"
	template_exists=false

	echo "Checking for ${template_name} in library ${library}"
	library_items=$(govc library.ls "${library}/*")
	while IFS= read -r line; do
  		library_item_name=$(echo  ${line} | cut -d'/' -f 3)
  		echo "Library Item: $library_item_name"
  		if [[ "$library_item_name" ==  "$template_name" ]]; then
    			echo "Template already exists in library"
    			template_exists=true
    			break
  		fi
	done <<< "$library_items"

	if [[ "$template_exists" == false ]]; then
  		echo "Importing template to library"
  		curl -s -i -O ${template_url}
  		govc library.import -k=true "${library}" "${template_url}"
		echo "template_name"
	fi
}

install_cluster_tools(){

	if [[ -v release ]]; then
		release_info=$(oc adm release info registry.ci.openshift.org/origin/release:"${release}")
		release_version=$(echo "${release_info}" | grep Name | awk '{print $2}')
		pull_url=$(echo "${release_info}" | grep "Pull From:" | awk '{print $3}')	
	else      
		echo "Please use the --release flag to denote what version you'd like to install."
	fi

	installer_file_name="openshift-install-linux-${release_version}.tar.gz"
	client_file_name="openshift-client-linux-${release_version}.tar.gz"

	if [ ! -d bin ]; then
		mkdir bin
	fi
	echo "Downloading the cluster tools for ${release_version}..."

	oc adm release extract --to bin --tools ${pull_url} 
	tar xvf bin/${installer_file_name} -C bin
	tar xvf bin/${client_file_name} -C bin
	rm bin/${installer_file_name}
	rm bin/${client_file_name}
}

create_install_config_from_template() {
        echo "Creating an install config from ${install_config_template_path}"
	if [ -z ${auto_secret} ]; then
                echo "Please enter your pullSecret"
                read pullSecret
        else
                pullSecret='{"auths":{"fake":{"auth":"aWQ6cGFzcwo="}}}'
        fi
        cp "${install_config_template_path}" install-config.yaml
        echo "pullSecret: '${pullSecret}'" >> install-config.yaml
}	

launch_prerun() {
	bin/openshift-install create manifests --dir=$(pwd)
	rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml
	sed -i -e s/true/false/g manifests/cluster-scheduler-02-config.yml
	# Back up the manifests and openshift directories for debugging issues
	cp -r ./manifests ./manifests.bak
	cp -r ./openshift ./openshift.bak
	
	bin/openshift-install create ignition-configs --dir=$(pwd)
	# Change timeouts for Master
	sed -i "s/\"timeouts\":{}/\"timeouts\":{\"httpResponseHeaders\":50,\"httpTotal\":600}/g" master.ign
	# Change timeouts for Worker
	sed -i "s/\"timeouts\":{}/\"timeouts\":{\"httpResponseHeaders\":50,\"httpTotal\":600}/g" worker.ign

	echo "Copying bootstrap.ign to /var/www/html/..."
	sudo /usr/bin/cp bootstrap.ign /var/www/html/bootstrap.ign
	sudo /usr/bin/chown apache:apache /var/www/html/bootstrap.ign
	sudo /usr/sbin/restorecon -Rv /var/www/html
}



deploy_node() {
	podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc library.deploy --folder "${cluster_folder}" "${library}/${template_name}" "${vm_name}"
	podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.change -vm "${vm_name}" \
		-c="${vm_cpu}" \
		-m="${vm_memory}" 
	podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.change -vm "${vm_name}" -e guestinfo.ignition.config.data="$(cat ${ignition_file_path} | base64 -w0)" -e guestinfo.ignition.config.data.encoding="base64"
	
	## Set the network ##
	podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.network.change -vm "${vm_name}" -net "${network_name}" -net.address - ethernet-0
	##

	podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.disk.change -vm "${vm_name}" -disk.label "Hard disk 1" -size ${vm_disk}G

	if [[ ! -z "${ipcfg}" ]]; then
		podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.change -vm "${vm_name}" -e "guestinfo.afterburn.initrd.network-kargs=${ipcfg}"
	fi

	if [[ ! -z "${vm_mac}" ]]; then
		podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.network.change -vm ${vm_name} -net "${cluster_network}" -net.address ${vm_mac} ethernet-0
	fi

	if [[ ! -z "${boot_vm}" ]]; then
		podman run -e GOVC_URL="${GOVC_URL}" -e GOVC_USERNAME="${GOVC_USERNAME}" -e GOVC_PASSWORD="${GOVC_PASSWORD}" -e GOVC_INSECURE=true --rm -it docker.io/vmware/govc /govc vm.power -on "${vm_name}"
	fi
}

provision_cluster_infrastructure(){

	bootstrap_cpu=4
	bootstrap_memory=16384
	bootstrap_disk=120
	master_cpu=4
	master_memory=16384
	master_disk=120
	worker_cpu=4
	worker_memory=16384
	worker_disk=120

	echo "Cluster: ${cluster_name}"
	echo "Template: ${template_name}"
	echo "Cluster Folder: ${cluster_folder}"
	echo "Network: ${network_name}"
	echo "Installation Folder: ${installation_folder}"

	# Create the bootstrap node
	# Note: vm_mac was already present in deploy_node code so just using it again!
	echo "Creating a bootstrap node with ${bootstrap_cpu} cpus and ${bootstrap_memory} MB of memory"
	vm_name="bootstrap.${cluster_name}"
	vm_cpu="${bootstrap_cpu}"
	vm_memory="${bootstrap_memory}"
	vm_disk="${bootstrap_disk}"
	vm_name="bootstrap.${cluster_name}"
	ignition_file_path="${installation_folder}/append-bootstrap.ign"

    vm_mac="${static_mac_addresses[bootstrap]}"

	echo ""
	echo "-----Deploying bootstrap node with MAC ${vm_mac}"
	echo ""

	
	deploy_node


	# Create the master nodes
	echo "Creating ${master_node_count} master nodes with ${master_cpu} cpus and ${master_memory} MB of memory"
	vm_cpu="${master_cpu}"
	vm_memory="${master_memory}"
	vm_disk="${master_disk}"
	ignition_file_path="${installation_folder}/master.ign"

	# Changed the logic here as I like my node names to start at 1
	for (( i=1; i<=${master_node_count}; i++ )); do
		vm_name="master-${i}.${cluster_name}"
		vm_mac="${static_mac_addresses["master-"${i}]}"
		echo ""
		#echo "-----Deploying master node ${vm_name} with MAC ${vm_mac}"
		#echo ""
		#echo " Terminating script here for debug"
		#exit
		deploy_node
	done

	# Create the worker nodes
	echo "Creating ${worker_node_count} worker nodes with ${worker_cpu} cpus and ${worker_memory} MB of memory"
	vm_cpu="${worker_cpu}"
	vm_memory="${worker_memory}"
	vm_disk="${worker_disk}"
	ignition_file_path="${installation_folder}/worker.ign"

	# Changed the logic here as I like my node names to start at 1
	for (( i=1; i<=${worker_node_count}; i++ )); do
		vm_name="worker-${i}.${cluster_name}"
		vm_mac="${static_mac_addresses["worker-"${i}]}"
		echo ""
		echo "-----Deploying worker node ${vm_name} with MAC ${vm_mac}"
		echo ""

		deploy_node
		
	done
}	

run_installer() {
  bin/openshift-install create cluster --dir=$(pwd) --log-level=info 
}	

destroy_cluster() {
	echo "If you really want to delete the cluster ${cluster_name}, type its name again:"
	read response
	
	if [[ "${response}" == "${cluster_name}" ]]; then
		echo "Destroying cluster: ${cluster_name}"
		# Destroy the master nodes
		# I like my nodes to start at 1
		for (( i=1; i<=${master_node_count}; i++ )); do
			vm="master-${i}.${cluster_name}"
			echo "master: $vm"
			govc vm.destroy $vm
		done

		# Destroy the worker nodes
		# I like my nodes to start at 1
		for (( i=1; i<=${worker_node_count}; i++ )); do
			vm="worker-${i}.${cluster_name}"
			govc vm.destroy $vm
		done

		# Destroy the bootstrap node
		vm="bootstrap.${cluster_name}"
		govc vm.destroy $vm
	else
		echo "OK, I'll forget you ever mentioned it."
	fi
}	

clean() {
	rm -rf master.ign worker.ign metadata.json .openshift_install* auth/ bootstrap.ign
}	

manage_cluster_power() {

	echo "Turning cluster ${power_action}..."

	vm="bootstrap.${cluster_name}"
	govc vm.power -${cluster_power_action} "${vm}"

	# Manage power for the master nodes

	for (( i=1; i<=${master_node_count}; i++ )); do
		vm="master-${i}.${cluster_name}"
		govc vm.power -${cluster_power_action} "${vm}"
	done

	# Manage power for the worker nodes

	for (( i=1; i<=${worker_node_count}; i++ )); do
		vm="worker-${i}.${cluster_name}"
		govc vm.power -${cluster_power_action} "${vm}"
	done

}

query_fcos_stream() {
	stream_data=$(curl -s https://builds.coreos.fedoraproject.org/streams/${stream_name}.json)
	file_url=$(echo ${stream_data} | jq -r '.architectures.x86_64.artifacts.vmware.formats.ova.disk.location')
	file_name=$(basename ${file_url})
	template_name="${file_name%.*}"
	echo "${file_url}"
}

check_oc
#check_govc

if [ ! -z ${install_tools} ]; then
	install_cluster_tools	
fi	

if [ ! -z ${import_template} ]; then
        import_template_from_url
fi

if [ ! -z ${install_config_template_path} ]; then
	create_install_config_from_template	
fi

if [ ! -z ${prerun} ]; then
	launch_prerun
fi

if [ ! -z ${provision_infrastructure} ]; then
	provision_cluster_infrastructure
fi

if [ ! -z ${deploy_single_node} ]; then
        deploy_node
fi

if [ ! -z ${destroy} ]; then
	destroy_cluster
fi

if [ ! -z ${cluster_power_action} ]; then
	manage_cluster_power
fi

if [ ! -z ${clean} ]; then
	clean
fi

if [ ! -z ${query_fcos} ]; then
        query_fcos_stream
fi

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Do you want to continue? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            continue
            ;;
        *)
            exit 0
            ;;
    esac
}