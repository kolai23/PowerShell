function Get-ADDirectReports
{
	<#
	.SYNOPSIS
		This function retrieve the directreports property from the IdentitySpecified.
		Optionally you can specify the Recurse parameter to find all the indirect
		users reporting to the specify account (Identity).
	
	.DESCRIPTION
		This function retrieve the directreports property from the IdentitySpecified.
		Optionally you can specify the Recurse parameter to find all the indirect
		users reporting to the specify account (Identity).
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
	
		VERSION HISTORY
		1.0 2014/10/05 Initial Version
	
	.PARAMETER Identity
		Specify the account to inspect
	
	.PARAMETER Recurse
		Specify that you want to retrieve all the indirect users under the account
	
	.EXAMPLE
		Get-ADDirectReports -Identity Test_director
	
Name                SamAccountName      Mail                Manager
----                --------------      ----                -------
test_managerB       test_managerB       test_managerB@la... test_director
test_managerA       test_managerA       test_managerA@la... test_director
		
	.EXAMPLE
		Get-ADDirectReports -Identity Test_director -Recurse
	
Name                SamAccountName      Mail                Manager
----                --------------      ----                -------
test_managerB       test_managerB       test_managerB@la... test_director
test_userB1         test_userB1         test_userB1@lazy... test_managerB
test_userB2         test_userB2         test_userB2@lazy... test_managerB
test_managerA       test_managerA       test_managerA@la... test_director
test_userA2         test_userA2         test_userA2@lazy... test_managerA
test_userA1         test_userA1         test_userA1@lazy... test_managerA
	
	#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory)]
		[String[]]$Identity,
		[Switch]$Recurse,
        [String]$Path="c:\inetpub\replace\Managers\"
	)
	BEGIN
	{
		<#TRY
		{
			IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
		}
		CATCH
		{
			Write-Verbose -Message "[BEGIN] Something wrong happened"
			Write-Verbose -Message $Error[0].Exception.Message
		}#>
	}
	PROCESS
	{
		foreach ($Account in $Identity)
		{
			TRY
			{
				IF ($PSBoundParameters['Recurse'])
				{
					#Get the DirectReports
					#Write-Verbose -Message "[PROCESS] Account: $Account (Recursive)"
					Get-Aduser -identity $Account -Properties directreports |
					ForEach-Object -Process {
						$_.directreports | ForEach-Object -Process {
							# Output the current object with the properties Name, SamAccountName, Mail and Manager
							Get-ADUser -Identity $PSItem -Properties manager | Select-Object -Property Name -ExpandProperty name #, SamAccountName, @{ Name = "Manager"; Expression = { (Get-Aduser -identity $psitem.manager).samaccountname } }
							# Gather DirectReports under the current object and so on...
							Get-ADDirectReports -Identity $PSItem -Recurse
						}
					}
				}#IF($PSBoundParameters['Recurse'])
				
			}#TRY
			CATCH
			{
				Write-Verbose -Message "[PROCESS] Something wrong happened"
				Write-Verbose -Message $Error[0].Exception.Message
			}
		}
	}
	END
	{
		#Remove-Module -Name ActiveDirectory -ErrorAction 'SilentlyContinue' -Verbose:$false | Out-Null
	}
}


function Get-DirectReportsTxt {

    [CmdletBinding()]
	PARAM (
        [String]$Path="c:\inetpub\replace\Managers\"
	)
    Get-ChildItem $path | Remove-Item
    $Managers=Get-ADUser -filter * -Properties directreports | Where-Object directreports | Select-Object samaccountname -ExpandProperty samaccountname
    $Managers | ForEach-Object {
    $samAccountName=$_
    $ini=Get-ADUser -filter * -Properties name | Where-Object {$_.samaccountname -eq $samAccountName} | Select-Object name -ExpandProperty name
        Get-ADDirectReports -Identity $_ -Recurse | Sort-Object | Out-File "c:\inetpub\replace\Managers\$_.txt" -Encoding UTF8
        Write-host $ini
        $ini | Out-File "c:\inetpub\replace\Managers\$_.txt" -Encoding UTF8 -Append
        }
      
}get-DirectReportsTxt


function Get-AllUsers {
    $OU='OU=Managing Company,OU=TELS GLOBAL,DC=capital,DC=local',
		'OU=Minsk BU,OU=TELS GLOBAL,DC=capital,DC=local',
		'OU=Moscow BU,OU=TELS GLOBAL,DC=capital,DC=local',
		'OU=Kyiv BU,OU=Region Europe,OU=TELS GLOBAL,DC=capital,DC=local',
        'OU=London BU,OU=Region Europe,OU=TELS GLOBAL,DC=capital,DC=local',
        'OU=Prague BU,OU=Region Europe,OU=TELS GLOBAL,DC=capital,DC=local',
        'OU=Warsaw BU,OU=Region Europe,OU=TELS GLOBAL,DC=capital,DC=local'
        
    $a=$null
    $a+="" | Out-File "c:\inetpub\replace\Managers\users.txt" -Encoding UTF8
    foreach ($b in $OU) {
    $a+=Get-ADUser -Filter * -Properties name -SearchBase $b | Select-Object name -ExpandProperty name | Sort-Object

    }
    $a | Sort-Object | Out-File "c:\inetpub\replace\Managers\users.txt" -Encoding UTF8 -Append


}Get-AllUsers

function ReplaseDate {

	$date = Get-Date -Format 'yyyymmdd'
	$request = Get-ADUser -Filter * -Properties DepFinish,SamAccountName| Select-Object SamAccountName,DepFinish

	foreach ($user in $request) {

        $datee = $request.DepFinish
        $datee = Get-Date -format "yyyymmdd"

		if($user.DepFinish -ne $null -and $datee -le $date)
		{
            Set-ADUser -Identity $user.SamAccountName -replace @{DepFinish=$date};
		}
	}
}
<#
# Find all direct user reporting to Test_director
Get-ADDirectReports -Identity Test_director

# Find all Indirect user reporting to Test_director
Get-ADDirectReports -Identity Test_director -Recurse
#>