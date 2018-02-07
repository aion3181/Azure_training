Configuration TestConfig
{
    Node NotWebServer
    {
        WindowsFeature IIS
        {
            Ensure = 'Absent'
            Name = 'Web-Server'
        }
    }
}