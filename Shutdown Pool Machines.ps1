# Input bindings are passed in via param block.
param($Timer)

######## Variables ##########
# Adicione o nome do pool de hosts pessoais e do grupo de recursos.
$personalHp = ''
$personalHpRg = ''

# Adicione o grupo de recursos para os hosts de sessão.
# Atualize se for diferente do grupo de recursos do Pool de Hosts
$sessionHostVmRg = $personalHpRg

########## Script Execution ##########

# Obtenha os hosts de sessão ativos
$activeShs = (Get-AzWvdUserSession -HostPoolName $personalHp -ResourceGroupName $personalHpRg).name
$allActive = @()
foreach ($activeSh in $activeShs) {
    $activeSh = ($activeSh -split { $_ -eq '.' -or $_ -eq '/' })[1]
    $allActive += $activeSh
}

# Obtenha os hosts de sessão
# Exclua servidores no modo de drenagem e não permita novas conexões
$sessionHosts = (Get-AzWvdSessionHost -HostPoolName $personalHp -ResourceGroupName $personalHpRg | Where-Object { $_.AllowNewSession -eq $true } )
$runningSessionHosts = $sessionHosts | Where-Object { $_.Status -eq "Available" }
# Avalie a lista de hosts de sessão em execução
foreach ($sessionHost in $runningSessionHosts) {
    $sessionHost = (($sessionHost).name -split { $_ -eq '.' -or $_ -eq '/' })[1]
    if ($sessionHost -notin $allActive) {
        Write-Host "Server $sessionHost is not active, shut down"
        try {
            # Pare a VM
            Stop-AzVM -ErrorAction Stop -ResourceGroupName $sessionHostVmRg -Name $sessionHost -Force -NoWait
        }
        catch {
            $ErrorMessage = $_.Exception.message
            Write-Error ("Error stopping the VM: " + $ErrorMessage)
            Break
        }
    }
    else {
        Write-Host "Server $sessionHost has an active session, won't shut down"
    }
}