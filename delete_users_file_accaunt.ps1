Import-Module ActiveDirectory

$time = Get-Date
$Today = (Get-Date).AddDays(-90)

#Get-ADUser -SearchBase "OU=Отключенные,DC=capital,DC=local" -filter * -Properties dateOfDism, lastLogonDate, distinguishedName, SamAccountName, DisplayName, telephoneNumber, EmailAddress, sid | ? {$_.lastLogonDate -lt $Today} |ft


$Users= Get-ADUser -SearchBase "OU=Отключенные,DC=capital,DC=local" -filter * -Properties dateOfDism, lastLogonDate, distinguishedName, SamAccountName, DisplayName, telephoneNumber, EmailAddress, sid

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ltex02.capital.local/powershell/ -ErrorAction SilentlyContinue
Import-PSSession $Session -ErrorAction SilentlyContinue

Start-Transcript "C:\1C_Scripts\log\delete_users_file_accaunt.log" -Append
  
foreach ($user in $Users) {

    $Today = (New-TimeSpan -Start $(Get-Date) -End $user.dateOfDism).TotalDays

    if($Today -lt -90){

        Write-host $time     $user.SamAccountName
        #Moving files from disk P
        $folder_p =[string]::Format('\\ltfs01\F$\mount\P\{0}',$user.SamAccountName)
        $locked = [string]::Format('\\ltfs01\G$\locked')

        try {
        Invoke-Command -ComputerName LTFS01 -ScriptBlock {
                if(Test-Path -Path $Using:folder_p) {
                    Move-Item -Path $Using:folder_p -Destination $Using:locked -Force
                    Write-Output "Moving user files from disk P to G completed"
                }
                else{
                    Write-host "[ERROR] Папка пользователя с путем: $Using:folder_p не существует"
                }
            }
        } catch {
            Write-host "[ERROR] Папка пользователя с путем: $folder_p не существует"
        }

        #Remove user files from disk S
        $folder_s =[string]::Format('\\ltapl01\D$\Share\Scan\{0}',$User.SamAccountName)
        try {
            Invoke-Command -ComputerName LTAPL01 -ScriptBlock {
                if(Test-Path -Path $Using:folder_s) {
                    Remove-Item -Recurse -Path $Using:folder_s -Force
                    Write-Output "Remove user files from disk S"
                }
                else{
                    Write-host "[ERROR] Папка пользователя с путем: $Using:folder_s не существует"
                }
            }
        } catch {
            Write-host "[ERROR] Папка пользователя с путем: $folder_s не существует"
        }

        #Remove user files vhdx
        $user_sid =[string]::Format('*{0}.*',$User.SID)
        $path_ltfs02 = 'D:\user_profiles\'
        $path_ltfs03 = 'D:\User_profiles$\'
        try {
            Invoke-Command -ComputerName LTFS02 -ScriptBlock {
                if(Get-ChildItem -Recurse -Path $Using:path_ltfs02 -Include $Using:user_sid){
                    Get-ChildItem -Recurse -Path $Using:path_ltfs02 -Include $Using:user_sid | Remove-Item -Recurse -Force
                    Write-host "Remove $Using:path_ltfs02 $Using:user_sid"
                }
                else
                {
                    Write-host "File not found $Using:path_ltfs02"
                }
            }

            Invoke-Command -ComputerName LTFS03 -ScriptBlock {
                if(Get-ChildItem -Recurse -Path $Using:path_ltfs03 -Include $Using:user_sid){
                    Get-ChildItem -Recurse -Path $Using:path_ltfs03 -Include $Using:user_sid | Remove-Item -Recurse -Force
                    Write-host "Remove $Using:path_ltfs03 $Using:user_sid"
                }
                else
                {
                    Write-host "File not found $Using:path_ltfs03"
                }
            }
        } 
        catch {
            Write-host "[ERROR]Remove vhdx user" + $user_sid 
        }


        #Remove AD user and Mailbox
        $users_ad_name =[string]::Format('capital\{0}',$user.SamAccountName)

        $users_ad =[string]::Format('{0}',$user.distinguishedName)	

            try {
                if($user.EmailAddress){
                    $users_email =[string]::Format('{0}',$user.EmailAddress)                
                       if(Get-Mailbox -Identity $users_email){
                           Disable-Mailbox -Confirm:$false -Identity $users_email
                           Write-host "Mailbox disable $users_email"
                       }else{
                           Remove-ADObject -Confirm:$false -Identity $users_ad -Recursive
                           Write-host "Mailbox not found"
                       }
                }else{
                      Remove-ADObject -Confirm:$false -Identity $users_ad -Recursive
                      Write-host "ADUser Mailbox not found"
                }
            } catch {
                Write-host "[ERROR]Remove mailbox nocompleted"
                write-host “Caught an exception:” -ForegroundColor Red
                write-host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
                write-host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
            } 

            try {
              
                Remove-ADObject -Confirm:$false -Identity $users_ad -Recursive
                Write-host "ADUser remove "
             
            } catch {
                Write-host "[ERROR] ADUser remove"
                write-host “Caught an exception:” -ForegroundColor Red
                write-host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
                write-host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
            } 
      }
}
Remove-PSSession $Session
Stop-Transcript


