Configuration MyDscConfiguration {
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration

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

        # Stop the default website
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