Workflow Stop-AzureVM
{
    Param 
    (    
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureSubscriptionId, 
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureVM="VM-IIS",
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureCredential
    )

    $credential = Get-AutomationPSCredential -Name $AzureCredential 
    Login-AzureRmAccount -Credential $credential 
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId

    if(!(Get-AzureRmVM | Where-Object {$_.Name -eq $AzureVM})) 
    { 
        throw " AzureVM : [$AzureVM] - Does not exist! - Check your inputs " 
    } 
    else 
    {
        Get-AzureRmVM | Where-Object {$_.Name -eq $AzureVM} | Stop-AzureRmVM -Force
    }
}