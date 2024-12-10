# Get-StoredSecret

## Description
This script is intended to work with other automated scripts that use credentials.  
The goal is to catch instances of failed credentials and inform sysadmins of the failure.

## Requirements
 * the PowerShell SecretStore module [PowerShell Gallery](https://www.powershellgallery.com/packages/Microsoft.PowerShell.SecretStore/)
 * the PowerShell SecretManagement module [PowerShell Gallery](https://www.powershellgallery.com/packages/Microsoft.PowerShell.SecretManagement/)
 * these modules need to be set up with an existing secret store. 
 * valid credentials for the SMTP server must also be stored in the secret store.
   this script cannot test those.  how would it send the mail if they failed??  lol
 * Only use this script on a computer that's on the same domain as the user account to be tested.  

## Instructions
 * Modify the file `config_template.ps1` and save it as `config.ps1`.
 * Clone the repository and insert the following code in the script that will be calling on this one:  

```powershell
# import the script
. $PSScriptRoot\creds.ps1

# collect telemetry data
$telemetry = @{
     script_name = $MyInvocation.MyCommand.Name
     script_path = $MyInvocation.MyCommand.Path
     hostname = $env:COMPUTERNAME
}

# retrieve creds from the secret store and test 
# stored secrets must be in the domain.tld\user format
$cred = Get-StoredSecret domain.tld\user @telemetry
```

## Notes
 * This script intentionally does not exit if tests fail.  This is in case the issue is with the actual validation, or in case the calling script is otherwise still able to run. 


## To-Do
 - [ ] test against foreign domains
 - [ ] something, something....  improperly formatted domains...
 - [ ] error handling if unable to contact a domain controller
 - [ ] don't go overboard on the error handling scenarios...  this is supposed to run unattended.
 - [ ] maybe handle secret names that don't include the domain 