$SubscriptionId = "bf8f23dc-8f88-417d-8b3b-da7cc4c74793"


$ScriptPath = Split-Path -Parent $PSCommandPath

Login-AzureRMAccount

Set-AzureRmContext -SubscriptionId $SubscriptionId

$VMName = "TASK7-VM"
$ResourceGroupLocation = "North Europe"
$TemplateFileSA = "$ScriptPath\Templates\SA.json"
$TemplateFile = "$ScriptPath\Templates\Environment.json"
$ResourceGroupName = "azuretraining7"
$storageAccountName = "$ResourceGroupName" + "sa2"
$storageAccountName2 = "$ResourceGroupName" + "sa3"

#A0 Basic
#A0 Standard
#Windows 10 Pro, Version 1709
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation


New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName `
                                   -storageAccountLocation $ResourceGroupLocation `
                                   -Force -Verbose

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName2 `
                                   -storageAccountLocation $ResourceGroupLocation `
                                   -Force -Verbose

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -resLocation $ResourceGroupLocation `
                                   -VMName $VMName -storageAccountName $storageAccountName `
                                   -Force -Verbose