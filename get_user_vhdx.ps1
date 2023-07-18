$usersn = 'xxxxx'
$users = Get-ADUser  -filter 'SamAccountName -eq $usersn' -Properties dateOfDism,lastLogonDate,sid,SamAccountName  
$path_ltfs02 = '\\ltfs02\D$\user_profiles\'
$path_ltfs03 = '\\ltfs03\D$\User_profiles$\'
foreach ($user in $users) {

   $user_sid1 = Get-ChildItem -Recurse -Path $path_ltfs02 -Include $user_sid
   $user_sid2 = Get-ChildItem -Recurse -Path $path_ltfs03 -Include $user_sid

   write-host ($user_sid1 +'             '+ $user_sid2)

   write-host ($user_sid)
}

