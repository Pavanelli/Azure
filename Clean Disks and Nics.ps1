Connect-AzAccount
# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$deleteUnattachedDisks = 1
$resourceGroupName = "YOUR_RESOURCE_GROUP"  # Defina o nome do seu Resource Group aqui

# Obter os discos gerenciados do Resource Group específico
$managedDisks = Get-AzDisk -ResourceGroupName $resourceGroupName

foreach ($md in $managedDisks) {
    # ManagedBy property armazena o Id da VM à qual o Managed Disk está anexado
    # Se a propriedade ManagedBy for $null, significa que o Managed Disk não está anexado a uma VM
    if ($md.ManagedBy -eq $null) {
        if ($deleteUnattachedDisks -eq 1) {
            Write-Host "Deletando Managed Disk não anexado com Id: $($md.Id)"
            $md | Remove-AzDisk -Force
            Write-Host "Deletado Managed Disk não anexado com Id: $($md.Id)"
        } else {
            $md.Id
        }
    }
}

}
$deleteUnattachedNICs=1
$AttachedNICs = Get-AzNetworkInterface -ResourceGroupName "YOUR_RESOURCE_GROUP"
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
