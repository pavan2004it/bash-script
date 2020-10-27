#!/bin/bash
# Title:  	Oms Install on all VMs in subscription
# variables
omsid=a760b768-3e6a-4d6c-8a08-bd90f1964892
omskey=/ze2M98zfXKPT2KNM9OhSYYiz/YubPD4hDMe/b3xySHfnBWCb5bPMS6TE6FaxJLSWycAdLt4SUHXx9NkkfJ7yQ==
sID=ed9b14b3-aade-477a-b8c3-f63850eb2bf5

# Set subscriptionID:
az account set --subscription $sID

# List all resource groups
declare -a rgarray="$(az group list  --query '[].name' -o tsv)"

#check if array is empty
if [ -z "$rgarray" ]; then
    echo "No resource group in this subscription: $sID"
	exit
else
	for  i in ${rgarray[@]};  do
	rgName=$i;
	
	# List all VMs for RG $rgName
	declare -a vmarray="$(az vm list -g $rgName --query '[].name' -o tsv)"

	#check if array is empty
	if [ -z "$vmarray" ]; then
			echo "No VM in $rgName" 				
	else							
		for j in ${vmarray[@]}; do
		vmName=$j;	
		
		# Make sure the VM running
		vm_state="$(az vm show -g $rgName -n $vmName -d --query powerState -o tsv)"

		if [[ "$vm_state" != "VM running" ]] ; then
			echo "Starting VM: $vmName "
			az vm start -g $rgName -n $vmName
		else
			echo "VM $vmName is already in running state."	
		fi
				
		# Get the Operating System
		vm_os="$(az vm get-instance-view -g $rgName -n $vmName | grep -i osType| awk -F '"' '{printf $4 "\n"}')"
		
		if [[ "$vm_os" == "Linux" ]] ; then			
			extName=OmsAgentForLinux		
			# Currently, the available versions are: 1.0, 1.2, 1.3, 1.4
			extVersion=1.4
		else			
			extName=MicrosoftMonitoringAgent		
			# Currently, the available versions are: 1.0
			extVersion=1.0
		fi
		
		# Create an array of installed extensions in the VM
		# declare -a installedExt="$(az vm extension list  -g $rgName --vm-name $vmName --query "[].name" -o tsv)"		
		# if [[ ! " ${installedExt[@]} " =~ " $extName " ]]; then
		
		# Install and configure the OMS agent on each VM $vmName
		az vm extension set \
			--resource-group $rgName \
			--vm-name $vmName \
			--name $extName \
			--publisher Microsoft.EnterpriseCloud.Monitoring \
			--version $extVersion --protected-settings '{"workspaceKey": "'"$omskey"'"}' \
			--settings '{"workspaceId": "'"$omsid"'"}'  
			
		echo "$extName installed on VM $vmName in RG $rgName."
		# else
			# echo "The extension $extName is already installed on the VM $vmName"
		# fi 
		done
	fi
	done  
fi
