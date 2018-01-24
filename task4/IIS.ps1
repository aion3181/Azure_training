Configuration MyDscConfiguration
{
    param ($MachineName)

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration
    Import-DSCResource -ModuleName xNetworking

    Node $MachineName
    {
        #Install the IIS Role
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }

        #Install ASP.NET 4.5
        WindowsFeature ASP
        {
            Ensure = 'Present'
            Name = 'Web-Asp-Net45'
        }

        WindowsFeature WebServerManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }

        WindowsFeature WebManagementService
        {
            Name = "Web-Mgmt-Service"
            Ensure = "Present"
        }

        xWebsite DefaultSite 
        {
            Ensure       = 'Present'
            Name         = 'Default Web Site'
            State        = 'Started'
            PhysicalPath = 'C:\inetpub\wwwroot'
            BindingInfo     = MSFT_xWebBindingInformation  
            {  
                Protocol              = "HTTP" 
                Port                  = 8080
            }
            DependsOn    = '[WindowsFeature]IIS'
        }

        xFirewall Firewall
        {
            Name = 'IISport8080'
            DisplayName = 'Firewall Rule for IIS port 8080'
            Group = 'NotePad Firewall Rule Group'
            Ensure = 'Present'
            Enabled = 'True'
            Profile = ('Domain', 'Private', 'Public')
            Direction = 'InBound'
            LocalPort = ('8080')
            Protocol = 'TCP'
            Description = 'Firewall Rule for IIS port 8080'
        }
    }
}
