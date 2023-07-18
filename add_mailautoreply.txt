Param (
[string]$users,
[string]$redirectuser
)


Import-Module ActiveDirectory
$exch = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ltex02.capital.local/powershell/ -ErrorAction SilentlyContinue
Import-PSSession $exch -ErrorAction SilentlyContinue

Get-Mailbox $userss | Format-List ForwardingSMTPAddress,DeliverToMailboxandForward

$request = Get-ADUser $users  -Properties Enabled

if ($request.Enabled -eq $true){
    $username= [string]::Format('{0}@telsglobal.com',$users)
    $starttime = (Get-Date)
    $endtime =  (Get-Date).AddDays(90)   
    $msg_internal =[string]::Format('Отсутствую в офисе {0}',$starttime)     
    $msg_external =[string]::Format('Отсутствую в офисе по {0}',$endtime)  
    Set-MailboxAutoReplyConfiguration $username –AutoReplyState Scheduled –StartTime $starttime –EndTime $endtime -InternalMessage $msg_internal -ExternalMessage $msg_external -ExternalAudience All
    Set-Mailbox $username -DeliverToMailboxAndForward $true -ForwardingSMTPAddress $redirectuser
    
}
