[DscLocalConfigurationManager()]
Configuration AutoDSCPull
{
    param
    (
        [Parameter(Mandatory=$True)]
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)]
        [String]$RegistrationKey,

        [Int]$RefreshFrequencyMins,
            
        [Int]$ConfigurationModeFrequencyMins,
            
        [String]$ConfigurationMode,
            
        [String]$NodeConfigurationName
    )

    Node localhost
    {
        Settings
        {
            RefreshFrequencyMins = $RefreshFrequencyMins
            RefreshMode = "PULL"
            ConfigurationMode = $ConfigurationMode
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
        }

        ConfigurationRepositoryWeb AzureAutomationDSC
        {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey
            ConfigurationNames = @($NodeConfigurationName)
        }
    }
}
PullClientConfigNames