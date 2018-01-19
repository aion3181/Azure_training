$ScriptPath = Split-Path -Parent $PSCommandPath

Login-AzureRMAccount
Set-AzureRmContext –SubscriptionId bf8f23dc-8f88-417d-8b3b-da7cc4c74793
$ResourceGroupLocation = "West Europe"
$resLocation = "West Europe"
$TemplateFile = "$ScriptPath\Environment.json"
$ResourceGroupName = "azuretraining"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -resLocation $resLocation `
                                   -Force -Verbose






