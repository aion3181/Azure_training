Install-Module AzureRM
Install-Module Azure
#to manage users, groups, and other aspects of Azure AD from Windows PowerShell
Install-Module -Name AzureAD -RequiredVersion 2.0.0.30
#Azure Automation is a service that you can use to run Windows PowerShell workflows and scripts as runbooks directly in Azure, either on demand or based on a schedule
Install-Module AzureAutomationAuthoringToolkit -Scope CurrentUser 
Install-AzureAutomationIseAddOn

#Loggin
Login-AzureRmAccount
#View account
Get-AzureRmContext
Get-AzureRmSubscription

#set the current subscription by using the Set-AzureRmContext
#To save the current authentication information to reuse it in another Windows PowerShell session, use Save-AzureRmProfile. This will allow you to retrieve the authentication information later by running Select-AzureRmProfile.
