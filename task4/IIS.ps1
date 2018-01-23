Configuration MyDscConfiguration {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WebAdministration

    param(
            [string[]]$MachineName
        )
    Node $MachineName {
        {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure       = 'Present'
            Name         = 'Web-Server'

        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure       = 'Present'
            Name         = 'Web-Asp-Net45'

        }

        WindowsFeature WebManagementConsole
        {
          Name = "Web-Mgmt-Console"
          Ensure = "Present"
        }

        WindowsFeature WebManagementService
        {
          Name = "Web-Mgmt-Service"
          Ensure = "Present"
        }

        # default website
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


    }

    }


}
