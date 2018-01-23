$ScriptPath = Split-Path -Parent $PSCommandPath

Login-AzureRMAccount
Set-AzureRmContext –SubscriptionId bf8f23dc-8f88-417d-8b3b-da7cc4c74793
$ResourceGroupLocation = "West Europe"
$resLocation = "West Europe"
$TemplateFileSA = "$ScriptPath\Templates\SA.json"
$TemplateFile = "$ScriptPath\Environment.json"
$ResourceGroupName = "azuretraining"
$storageAccountName = "$ResourceGroupName" + "sa2"
$ContainerName = "Task4"
$ConfigurationPath = "$ScriptPath\IIS.ps1"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation


New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName `
                                   -storageAccountLocation $resLocation `
                                   -Force -Verbose


$moduleURL = Publish-AzureRmVMDscConfiguration -ConfigurationPath $ConfigurationPath `
                                    -ResourceGroupName $ResourceGroupName `
                                    -StorageAccountName $storageAccountName `
                                    -Force
                                    #–ContainerName $ContainerName
$moduleURL

$StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName `
                                    -Name $storageAccountName)[0].Value


$storageContext = New-AzureStorageContext –StorageAccountName $storageAccountName `
                                    -StorageAccountKey $StorageAccountKey

$sasToken = New-AzureStorageContainerSASToken –Name $ContainerName `
                                    –Context $storageContext –Permission r




New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -resLocation $resLocation `
                                   -modulesUrl $moduleURL `
                                   -sasToken $sasToken `
                                   -Force -Verbose



<#
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
  -TemplateFile $TemplateFile -Debug
#>
