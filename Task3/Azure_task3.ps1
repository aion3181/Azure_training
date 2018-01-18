Login-AzureRMAccount
Set-AzureRmContext –SubscriptionId bf8f23dc-8f88-417d-8b3b-da7cc4c74793
$ResourceGroupLocation = "West Europe"
$location = "West Europe"
$TemplateFile = ".\Environment.json"
$ResourceGroupName = "azuretraining"

New-AzureRmResourceGroup -Name $envPrefix -Location $ResourceGroupLocation
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -location $location `
                                   -Force -Verbose



