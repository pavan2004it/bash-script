Login-AzureRmAccount
$subscriptionId = ( Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru ).SubscriptionId 
Select-AzureRmSubscription -SubscriptionId $subscriptionId 
$rgName = ( Get-AzureRmResourceGroup | Out-GridView -Title "Select an Azure Resource Group ..." -PassThru ).ResourceGroupName 
$vmName = ( Get-AzureRmVm -ResourceGroupName $rgName ).Name | Out-GridView -Title "Select a VM ..." -PassThru
$vm = Get-AzureRmVm -ResourceGroupName $rgName -Name $vmName 
$location = $vm.Location
$asName = Read-Host -Prompt "Enter a new Availability Set name"
$as = New-AzureRmAvailabilitySet -Name $asName -ResourceGroupName $rgName -Location $location
$vm | Stop-AzureRmVm -Force
$vm | Remove-AzureRmVm -Force
$asRef = New-Object Microsoft.Azure.Management.Compute.Models.SubResource
$asRef.Id = $as.Id
$vm.AvailabilitySetReference = $asRef
$vm.StorageProfile.OSDisk.Name = $vmName
$vm.StorageProfile.OSDisk.CreateOption = "Attach"
$vm.StorageProfile.DataDisks | ForEach-Object { $_.CreateOption = "Attach" } 
$vm.StorageProfile.ImageReference = $null
$vm.OSProfile = $null
$vm | New-AzureRmVm -ResourceGroupName $rgName -Location $location