Workflow Stop-AzureVM
{
    Param 
    (    
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureSubscriptionId, 
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureVMList="All"
    )

    Node WebServer
    {

        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name = 'Web-Server'
            IncludeAllSubFeature = $true

        }
    }

    Node NotWebServer
    {
        WindowsFeature IIS
        {
            Ensure = 'Absent'
            Name = 'Web-Server'

        }
    }
}