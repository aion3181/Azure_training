$SubscriptionId = "bf8f23dc-8f88-417d-8b3b-da7cc4c74793"


$ScriptPath = Split-Path -Parent $PSCommandPath

Login-AzureRMAccount

Set-AzureRmContext -SubscriptionId $SubscriptionId

$VMName = "TASK7-VM"
$ResourceGroupLocation = "North Europe"
$TemplateFileSA = "$ScriptPath\Templates\SA.json"
$TemplateFile = "$ScriptPath\Templates\Environment.json"
$ResourceGroupName = "azuretraining7"
#$ResourceGroupName2 = "azuretraining72"
$storageAccountName = "$ResourceGroupName" + "sa2"
#$storageAccountName2 = "$ResourceGroupName" + "sa3"


New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
#New-AzureRmResourceGroup -Name $ResourceGroupName2 -Location $ResourceGroupLocation

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName `
                                   -storageAccountLocation $ResourceGroupLocation `
                                   -Force -Verbose

<#
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName2 `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName2 `
                                   -storageAccountLocation $ResourceGroupLocation `
                                   -Force -Verbose
#>
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -resLocation $ResourceGroupLocation `
                                   -VMName $VMName -storageAccountName $storageAccountName `
                                   -Force -Verbose



#################### TASK 7 #############################
#########################################################
#ARM to create Service vault and backup policy

$TemplateFileBack = "$ScriptPath\Templates\Backup.json"
$RecoveryVault = 'RecoveryVault'
$RecoveryPolicy = 'RecoveryPolicy'

$Params = @{
    vaultName = $RecoveryVault;
    policyName = $RecoveryPolicy;
    vmName = $VMName;
    scheduleRunTimes = @('23:00');
    timeZone = 'UTC';
    dailyRetentionDurationCount = 30;
}

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                    -TemplateFile $TemplateFileBack `
                                    -TemplateParameterObject $Params `
                                    -Force -Verbose


# Back up now

Get-AzureRmRecoveryServicesVault `
    -Name $RecoveryVault | Set-AzureRmRecoveryServicesVaultContext

$backupcontainer = Get-AzureRmRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName $VMName

$item = Get-AzureRmRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

$backupjobid = (Backup-AzureRmRecoveryServicesBackupItem -Item $item).JobId


while((Get-AzureRmRecoveryservicesBackupJob -JobId $backupjobid).Status -ne 'Completed'){
Write-host 'Backup job in progress. Checking status in 10 seconds'
sleep -Seconds 10 
}
<#
$backupObj = (Get-AzureRmResource | Where-Object{$_.ResourceType -like 'Microsoft.Compute/restorePointCollections'})
$backupPoint = $backupObj.ResourceId
#>
$RP = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $item

$RestoreJob = Restore-AzureRmRecoveryServicesBackupItem -RecoveryPoint $RP[0] -StorageAccountName $storageAccountName -StorageAccountResourceGroupName $ResourceGroupName
$RestoreJobid = $RestoreJob.JobId
while((Get-AzureRmRecoveryservicesBackupJob -JobId $RestoreJobid).Status -ne 'Completed'){
Write-host 'Restore job in progress. Checking status in 10 seconds'
sleep -Seconds 10 
}