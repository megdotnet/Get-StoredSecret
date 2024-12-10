#Requires -Modules Microsoft.PowerShell.SecretManagement
#Requires -Modules Microsoft.PowerShell.SecretStore

function Send-FailMessage {
    param (
        [string]$fail_message
    )
    
    # import config
    . $PSScriptRoot\config.ps1

    $subject = "Script Credential Failure"
    $body = @"
    $fail_message 

    Script:  $script_name
      Path:  $script_path
      Host:  $hostname
"@

    Send-MailMessage `
    -From $from `
    -To $to `
    -SmtpServer $smtpserver `
    -Credential $smtpcred `
    -Usessl -Port $port `
    -Subject $subject `
    -Body $body `
}

function Test-ADCredentials {
    param (
        [pscredential]$cred
    )
    
    # extract individual values from the creds
    $domain = ($cred.UserName -split "\\")[0]
    $username = ($cred.UserName -split "\\")[1]
    $SecurePass = $cred.Password    

    # convert pass to plaintext
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass) 
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # validate credentials
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain',$domain)
    $valid = $DS.ValidateCredentials($username, $password)
    return $valid
}   

function Get-StoredSecret {
    param (
        [string]$user,
        [string]$script_name,
        [string]$script_path,
        [string]$hostname
    )

    # unlock key store 
    $passwordPath = Join-Path (Split-Path $profile) SecretStore.vault.credential
    $pass = Import-Clixml $passwordPath
    Unlock-SecretStore $pass
    
    # retrieve creds for user account 
    $cred = Get-Secret $user -ErrorAction SilentlyContinue

    # if creds not found, send failure email
    if (!$cred) {
        $fail_message = @"

        User:  $user

        Unable to retrieve credentials in the keystore. 
        This is likely caused by the user account not existing in the keystore. 

"@  
        Send-FailMessage $fail_message
    }

    # else test the credentials
    else {
        $valid = Test-ADCredentials $cred

        if (!$valid) {
            $fail_message = @"
    
            User authentication failed for this user. 
            User:  $($cred.UserName)
    
            This is likely caused by a bad username or password stored in the key store. 
"@  
            Send-FailMessage $fail_message
        }
    }

    return $cred
}