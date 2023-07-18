$Today = (Get-Date).AddDays(-14)
$get_ltrdsh = Get-ADComputer -SearchBase "OU=RDSH,OU=Servers,DC=capital,DC=local" -Filter * -Properties * | select -ExpandProperty name
$get_ltrdp = Get-ADComputer -SearchBase "OU=LTRDP,OU=Servers,DC=capital,DC=local" -Filter * -Properties * | select -ExpandProperty name

$filter=@{
     logname='System'
     ID=6006
}

function Get-PCDateReboot {
    param (
        [string[]]$get_pc
    )

    foreach ($Computer in $get_pc) {
        $event = Get-WinEvent -ComputerName $Computer  -FilterHashtable $filter -MaxEvents 1 | Select-Object TimeCreated,Id,Message

        if($event.TimeCreated -lt $Today) {
        write-host ($Computer +'             '+ $event.TimeCreated)

        }
    }
}

Get-PCDateReboot -get_pc $get_ltrdsh
Get-PCDateReboot -get_pc $get_ltrdp