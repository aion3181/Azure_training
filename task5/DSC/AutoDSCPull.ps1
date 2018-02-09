[DscLocalConfigurationManager()]
configuration MyDscConfiguration
{
    param
    (
        [Parameter(Mandatory=$True)]
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)]
        [String]$RegistrationKey,
            
        [String]$NodeConfigurationName
    )

    Node localhost
    {
        Settings
        {
            RefreshMode = "PULL"
        }

        ConfigurationRepositoryWeb AzureAutomationDSC
        {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey
            ConfigurationNames = @($NodeConfigurationName)
        }

        ResourceRepositoryWeb AzureAutomationDSC
        {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey
        }
    }
}