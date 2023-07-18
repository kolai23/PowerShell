Import-Module ActiveDirectory
$exch = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ltex02.capital.local/powershell/ -ErrorAction SilentlyContinue
Import-PSSession $exch -ErrorAction SilentlyContinue

Start-Transcript -Path "C:\Inetpub\replace\Requests\Forwarding.log" -Append

function get-mail {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)]
    [string]$user
    )
    Get-ADUser -Filter * -Properties name,mail | ? {($_.name -eq $user) -or ($_.samaccountname -eq $user)} | Select-Object mail -ExpandProperty mail
}


function send-message {
    [CmdletBinding()]
	    param(
            [Parameter(Mandatory)]
		    [int]$typeMessage,
            [string]$MessageBody=$null,
            [string]$ToSet=$null
        )
    if($typeMessage -eq 1) {
        $MessageBody = "<h3><b><font color=green>Установка замещения выполнена!</b></font></h3> <br>"
        $MessageBody += "<p><b>Инициатор заявки:</b> $script:nameInitiator<br>"
        $MessageBody += "<p><b>По вашему запросу установлено замещение сотрудника </b> $script:nameSender <b> сотрудником </b> $script:nameRecipient <br>"
        $MessageBody += "<p><b>на период с $script:date_start по $script:date_end <br>"
        $MessageBody += "<br>"
        $MessageBody += "<br>"
    } else {
        $MessageBody = "<h3><b><font color=green>Снятие замещения выполнено!</b></font></h3> <br>"
        $MessageBody += "<p><b>Замещение сотрудника снято:</b> $script:nameSender<br>"
        $MessageBody += "<br>"
        $MessageBody += "<br>"
    }
    $EmFrom = "Report@telsglobal.com"    
    $username = "report"    
    $pwd = "@#1jnghfdrfgjxns"
    $EmTo = $script:TO
    $Server = "mail.capital.local"  
    $port = 25    
    $Subject = "Уведомление о замещении сотрудника"    
    $securepwd = ConvertTo-SecureString $pwd -AsPlainText -Force    
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securepwd    
    Send-MailMessage -To $EmTo -From $EmFrom -Body $MessageBody -BodyAsHtml -Subject $Subject -SmtpServer $Server -port $port -Credential $cred -Encoding UTF8 
}  
function Set-Forwarding {
    [CmdletBinding()]
        param (
            [string]$pathFiles="c:\inetpub\replace\Requests",
            [string]$ProcessedRequests="c:\inetpub\replace\Processed"
        )
		TRY {
			IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
		}
        CATCH {
			Write-Verbose -Message "[BEGIN] Something wrong happened"
			Write-Verbose -Message $Error[0].Exception.Message
		}

    if ($null -ne ($txtFiles=Get-ChildItem $pathFiles\*.* -Include *.txt | Sort-Object LastWriteTime)) { 
    
        $txtFiles | ForEach-Object {
 
            $items=Get-Content $_ -Encoding UTF8
            $initiator=$items[0]
            $script:sender=$items[1]
            $script:recipient=$items[2]
            $type=$items[3]
            $script:start_date=$items[4]
            $script:end_date=$items[5]

            $script:date_start = ([datetime]::parseexact($start_date, ‘yyyyMMdd’, $null)).ToString("dd-MM-yyyy")
            $script:date_end = ([datetime]::parseexact($end_date, ‘yyyyMMdd’, $null)).ToString("dd-MM-yyyy")
            
            $script:getNameInitiator = Get-ADUser $initiator  -Properties extensionAttribute1,extensionAttribute2,extensionAttribute3
            $script:nameInitiator =[string]::Format('{0} {1} {2}', $getNameInitiator.extensionAttribute1 ,$getNameInitiator.extensionAttribute2, $getNameInitiator.extensionAttribute3)
            
            $script:getNameSender = Get-ADUser $sender  -Properties extensionAttribute1,extensionAttribute2,extensionAttribute3
            $script:nameSender=[string]::Format('{0} {1} {2}', $getNameSender.extensionAttribute1 ,$getNameSender.extensionAttribute2, $getNameSender.extensionAttribute3)
            
            $script:getSamAccountNameRecipient=Get-ADUser -Filter {cn -eq $recipient} | Select-Object SamAccountName -ExpandProperty SamAccountName
            $script:getNameRecipient= Get-ADUser $getSamAccountNameRecipient  -Properties extensionAttribute1,extensionAttribute2,extensionAttribute3
            $script:nameRecipient=[string]::Format('{0} {1} {2}', $getNameRecipient.extensionAttribute1 ,$getNameRecipient.extensionAttribute2, $getNameRecipient.extensionAttribute3)
            

            [string]$initiator=$initiator -split ".*\\"
            $initiatorMail=get-mail $initiator
            $senderMail=get-mail $sender
            $recipientMail=get-mail $recipient
            $script:To=($initiatorMail,$senderMail,$recipientMail)

            $script:To= $script:To | Sort-Object -Unique
            if($type -eq 'set') {
                Set-Mailbox $sender -DeliverToMailboxAndForward $true -ForwardingAddress $recipient
                Set-ADUser -Identity $sender -replace @{DepUser=$getSamAccountNameRecipient;DepStart=$start_date;DepFinish=$end_date;}
                send-message -typeMessage 1
                $_ | Move-Item -Destination $ProcessedRequests  
            }
            if(($type -eq 'clear')) {
                Set-Mailbox $sender -ForwardingAddress $null
                Set-ADUser -Identity $sender -Clear "DepFinish"
                send-message -typeMessage 0
                $_ | Move-Item -Destination $ProcessedRequests  
            }
        }
    }
}
Set-Forwarding
Remove-PSSession $exch
Stop-Transcript