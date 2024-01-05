Connect-AzAccount
# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$deleteUnattachedDisks=1
$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
# ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($md.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Host "Deleting unattached Managed Disk with Id: $($md.Id)"
       $md | Remove-AzDisk -Force
       Write-Host "Deleted unattached Managed Disk with Id: $($md.Id) "
        }else{
       $md.Id
        }
       }
}
$deleteUnattachedNICs=1
$AttachedNICs = Get-AzNetworkInterface -ResourceGroupName "TEMPOASSIST-USEAST2"
foreach ($NIC in $AttachedNICs) {
       if($NIC.VirtualMachine -eq $null){
        if($deleteUnattachedNICs -eq 1){
       Write-Host "Deleting unattached NICs with Id: $($NIC.Id)"
       $NIC | Remove-AzNetworkInterface -Force
       Write-Host "Deleted unattached NICs with Id: $($NIC.Id) "
        }else{
       $NIC.Id
        }
       }
}

teste