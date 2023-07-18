$usersn = 'Borodich'
$users = Get-ADUser  -filter 'SamAccountName -eq $usersn' -Properties dateOfDism,lastLogonDate,sid,SamAccountName  
$path_ltfs02 = '\\ltfs02\D$\user_profiles\'
$path_ltfs03 = '\\ltfs03\D$\User_profiles$\'
foreach ($user in $users) {

   $user_sid =[string]::Format('UVHD-{0}.vhdx',$user.SID)

   write-host ($user_sid)
}

