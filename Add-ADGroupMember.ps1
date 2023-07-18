Import-Module ActiveDirectory


$request = Get-ADUser -Filter {isHead -like $True} -Properties SamAccountName, isHead


foreach($user in $request)
{
    Add-ADGroupMember 'RM-Head' -Members $user.SamAccountName
}