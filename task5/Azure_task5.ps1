$SubscriptionId = "bf8f23dc-8f88-417d-8b3b-da7cc4c74793"
$AAuser = "mySUPPAuser"
$AApass = "mySUPPApass"



$ScriptPath = Split-Path -Parent $PSCommandPath

Login-AzureRMAccount

Set-AzureRmContext -SubscriptionId $SubscriptionId

######################################### TASK 4 ####################################
###################################################################################
$ResourceGroupLocation = "West Europe"
$resLocation = "West Europe"
$TemplateFileSA = "$ScriptPath\Templates\SA.json"
$TemplateFile = "$ScriptPath\Templates\Environment.json"
$ResourceGroupName = "azuretraining"
$storageAccountName = "$ResourceGroupName" + "sa2"
$ContainerName = "windows-powershell-dsc"
$Config = "IIS\IIS.ps1"
$ConfigurationPath = "$ScriptPath\$Config"
$Blob = "IIS.ps1.zip"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation


New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName `
                                   -storageAccountLocation $resLocation `
                                   -Force -Verbose


$moduleURL = Publish-AzureRmVMDscConfiguration -ConfigurationPath $ConfigurationPath `
                                    -ResourceGroupName $ResourceGroupName `
                                    -StorageAccountName $storageAccountName `
                                    -Force -Verbose


$moduleURL

$StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $storageAccountName)[0].Value

$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey

$sasToken = New-AzureStorageBlobSASToken -Container $ContainerName -Blob $Blob -Context $storageContext -Permission r

$sasToken


New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -resLocation $resLocation `
                                   -modulesUrl $moduleURL `
                                   -sasToken $sasToken `
                                   -Force -Verbose

#Check
$PubIP = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName
$PubIP = $PubIP.IpAddress
$check = 'http://' + "$PubIP" + ':8080'
start $check



######################################### TASK 5.1 ####################################
###################################################################################
#Loggong to Azure


$storageAccountName2 = "$ResourceGroupName" + "sa3"
$RunbookPath = "$ScriptPath" + "\Runbooks\StopVM.ps1"
$containerName2 = "stopvmrunbook"
$blob = "StopVM.ps1"

#Creating SA for runbook
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFileSA `
                                   -storageAccountName $storageAccountName2 `
                                   -storageAccountLocation $resLocation `
                                   -Force -Verbose

#Uploading runbook to SA

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName `
                                            -Name $storageAccountName2


$ctx = $storageAccount.Context
$ctx
New-AzureStorageContainer -Name $containerName2 -Context $ctx -Permission blob


Set-AzureStorageBlobContent -File $RunbookPath `
                            -Container $containerName2 `
                            -Blob $blob `
                            -Context $ctx


$moduleURL2 = "https://" + "$storageAccountName2" + ".blob.core.windows.net/" + "$containerName2" + "/" + "$blob"
$moduleURL2

#Creating SAS token for our runbook
$StorageAccountKey2 = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName `
                                    -Name $storageAccountName2)[0].Value


$storageContext2 = New-AzureStorageContext -StorageAccountName $storageAccountName2 `
                                    -StorageAccountKey $StorageAccountKey2


$sasToken2 = New-AzureStorageBlobSASToken -Container $containerName2 `
                                        -Blob $blob `
                                        -Context $storageContext2 -Permission r

$sasToken2


#Final link to our runbook in storage account
$runbookURL = "$moduleURL2" + "$sasToken2"

#Automation Account ARM

$JobGUID = [System.Guid]::NewGuid().toString()
$accountName = "autoazure"
$runbookName = "Stop-AzureVM"
$VMName = "VM-IIS"

$Params = @{
    accountName = $accountName;
    jobId = $JobGUID;
    credentialName = "DefaultAzureCredential";
    userName = $AAuser;
    password = $AApass;
    runbookName = "$runbookName";
    scriptUri = $runbookURL;
    AzureVM = $VMName;
    SubscriptionId = $SubscriptionId;
}

$TemplateFileaa = "$ScriptPath" + "\Templates\aa.json"

New-AzureRmResourceGroupDeployment -TemplateParameterObject $Params -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileaa -Force -Verbose


#Check

$status = (Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status).Statuses[1].DisplayStatus
Write-host "##################################"
Write-host "TASK 5.1 result: $status"
Write-host "##################################"


#####################################################################################
######################################################################################

############################### TASK 5.2 ###########################################
####################################################################################

#Power on our VM
Write-host "Starting VM back"
Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

#Uploading and compiling DSC to automation account



$DSCSourcePath = "$ScriptPath" + "\DSC\TestConfig.ps1"
$ConfigurationName = "TestConfig"

Import-AzureRmAutomationDscConfiguration -ResourceGroupName $ResourceGroupName -AutomationAccountName $accountName -SourcePath $DSCSourcePath -Published -Verbose -Force

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $accountName -ConfigurationName $ConfigurationName -Verbose
Start-Sleep -s 60
$NodeConfig = (Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $ResourceGroupName -AutomationAccountName $accountName).Name
$NodeConfig


#Removing old DSC extension from Vm

$extensionName = (Get-AzureRMVm -ResourceGroupName $ResourceGroupName -VMName $VMName -Status).Extensions[0].Name
Remove-AzureRmVMDscExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name $extensionName -Verbose


Register-AzureRmAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $accountName -AzureVMName $VMName -NodeConfigurationName $NodeConfig -Verbose
Get-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $VMName | Update-AzureRMVM



<#



#ARM to add VM to DSC automation Pull server
$TemplateFileaa2 = "$ScriptPath" + "\Templates\aa2.json"
$DSCconfigLink = "https://github.com/aion3181/Azure_training/raw/master/task5/DSC/AutoDSCPull.zip"
[string]$configurationFunction = "AutoDSCPull.ps1\\MyDscConfiguration"
$AAREgInfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $accountName
$AAregistrationKey = $AAREgInfo.PrimaryKey
$AAregistrationUrl = $AAREgInfo.Endpoint

$AAregistrationKey
$AAregistrationUrl
[string]$nodeConfigurationName = $NodeConfig



$Params2 = @{
    vmName = $VMName;
    modulesUrl = $DSCconfigLink;
    configurationFunction = $configurationFunction;
    registrationKey = $AAregistrationKey;
    registrationUrl = $AAregistrationUrl;
    nodeConfigurationName = $nodeConfigurationName;
}

New-AzureRmResourceGroupDeployment -TemplateParameterObject $Params2 -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileaa2 -Force -Verbose

#>
