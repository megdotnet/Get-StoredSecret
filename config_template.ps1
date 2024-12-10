# This is a template.
# Please supply your own values.
# Save as config.ps1

#variables for mail message
$from = "sender@domain[.]com"
$to = @("recipient@domain[.]com")
$smtpserver = "smtp.domain[.]com"
$port = 587
$smtpcred = Get-Secret "smtp_secret"