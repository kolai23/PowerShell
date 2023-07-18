$users = 'ttestovich'


Import-Module ActiveDirectory
$request = Get-ADUser $users  -Properties Enabled,SamAccountName,DisplayName,telephoneNumber

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ltex02.capital.local/powershell/ -ErrorAction SilentlyContinue
Import-PSSession $Session -ErrorAction SilentlyContinue


try {
    Import-Module Lync -ErrorAction Stop
    Write-Host "Модуль MicrosoftLync загружен"
    }
catch {
    Write-Host "Ошибка загрузки модуля MicrosoftLync. Check S4B Server components installation. Скрипт остановлен!"
    Exit 1
    }
Function resizephoto(){
    Param (
        [Parameter(Mandatory=$True)] [ValidateNotNull()] $imageSource,
        [Parameter(Mandatory=$true)][ValidateNotNull()] $canvasSize,
        [Parameter(Mandatory=$true)][ValidateNotNull()] $quality
    )

    # функция берет файлик и ужимет его

    # проверки
    if (!(Test-Path $imageSource)){
        throw( "Файл не найден")
    }
    if ($canvasSize -lt 10 -or $canvasSize -gt 1000){
        throw( " Параметр размер должен быть от 10 до 1000")
    }
    if ($quality -lt 0 -or $quality -gt 100){
        throw( " Параметр качества должен быть от 0 до 100")
    }

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $imageBytes = [byte[]](Get-Content $imageSource -Encoding byte)
    $ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
    $ms.Write($imageBytes, 0, $imageBytes.Length);

    $bmp = [System.Drawing.Image]::FromStream($ms, $true)

    # разрешение картинки после конвертации
    $canvasWidth = $canvasSize
    $canvasHeight = $canvasSize

    # Задание качества картинки
    $myEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
    #Получаем тип картинки
    $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}

    # Высчитывание кратности
    $ratioX = $canvasWidth / $bmp.Width;
    $ratioY = $canvasHeight / $bmp.Height;
    $ratio = $ratioY
    if($ratioX -le $ratioY){
        $ratio = $ratioX
    }

    # Создание пустой картинки
    $newWidth = [int] ($bmp.Width*$ratio)
    $newHeight = [int] ($bmp.Height*$ratio)
    $bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graph = [System.Drawing.Graphics]::FromImage($bmpResized)

    $graph.Clear([System.Drawing.Color]::White)
    $graph.DrawImage($bmp,0,0 , $newWidth, $newHeight)

    # Создание пустого потока
    $ms = New-Object IO.MemoryStream
    $bmpResized.Save($ms,$myImageCodecInfo, $($encoderParams))

    # уборка
    $bmpResized.Dispose()
    $bmp.Dispose()

    return $ms.ToArray()
}

foreach ($user in $request){
    $users_ad_name =[string]::Format('capital\{0}',$user.SamAccountName)
    try {
        $mailbox = [string]::Format('{0}@telsglobal.com',$User.SamAccountName)
        Enable-Mailbox -Identity $users_ad_name -PrimarySmtpAddress $mailbox
        Start-Sleep -s 40
        Set-CASMailbox -Identity $users_ad_name -OWAEnabled $false -ActiveSyncEnabled $false
        Add-MailboxPermission -Identity $users_ad_name -User "capital\dlg-mailboxadmin" -AccessRights FullAccess
        $proxySIP = [string]::Format('SIP:{0}@capital.local', $User.SamAccountName)
        Set-Mailbox $user.SamAccountName -EmailAddresses @{add = $proxySIP}
        $proxySMTP = [string]::Format('smtp:{0}@capital.local', $User.SamAccountName)
        Set-Mailbox $user.SamAccountName -EmailAddresses @{add = $proxySMTP}
        if($User.telephoneNumber){
            $proxySMTP_lync = [string]::Format('smtp:{0}@capital.local', $User.telephoneNumber)
            Set-Mailbox $user.SamAccountName -EmailAddresses @{add = $proxySMTP_lync}
        }
        Write-Output ("Пользователь успешно заведен в Exchange")
        
    }
    catch {

        write-host “Caught an exception:” -ForegroundColor Red
        write-host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
        write-host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
    } 

    try {
        Enable-CsUser -Identity $User.UserPrincipalName -RegistrarPool "ltsfb.capital.local" -SipAddressType SamAccountName  -SipDomain capital.local
        Set-CsUser -Identity $User.UserPrincipalName -EnterpriseVoiceEnabled $true
        Add-Content -Path "\\capital.local\NETLOGON\Special\Lync\SIP.txt" -Value "$User.UserPrincipalName"
        Write-host "Пользователь успешно заведен в Microsoft Lync"
    }
    catch {
        write-host “Ошибка в заведении Microsoft Lync:” -ForegroundColor Red
        write-host “Caught an exception:” -ForegroundColor Red
        write-host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
        write-host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
    }
     

    $folder_s =[string]::Format('\\ltapl01\D$\Share\Scan\',$user.SamAccountName)
    $test_folder_s =[string]::Format('\\ltapl01\D$\Share\Scan\{0}',$user.SamAccountName)

    $folder_p =[string]::Format('\\ltfs01\F$\mount\P\',$user.SamAccountName)
    $test_folder_p =[string]::Format('\\ltfs01\F$\mount\P\{0}',$user.SamAccountName)

    if(!(Test-Path -Path $test_folder_s)) {
        New-Item -Path $folder_s -name $user.SamAccountName -ItemType Directory -ErrorAction SilentlyContinue
        # Получение списка разрешений с корневой папки
        $acl = Get-Acl -Path $folder_s
        # Добавление прав пользователю
        $permission = $users_ad_name,"Read,Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
        $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission
        $acl.SetAccessRule($rule)
        # Настройки наследования
        $acl.SetAccessRuleProtection($false, $true)
        # Установка прав пользователю
        $acl | Set-Acl -Path $test_folder_s
        Write-host "Папка создана. Путь $test_folder_s"
    } 
    else {
        Write-host "[ERROR] Папка пользователя с путем: $folder_s уже существует"
    }

    if(!(Test-Path -Path $test_folder_p)) {
        New-Item -Path $folder_p -name $user.SamAccountName -ItemType Directory -ErrorAction SilentlyContinue
        # Получение списка разрешений с корневой папки
        $acl = Get-Acl -Path $folder_p
        # Добавление прав пользователю
        $permission = $users_ad_name,"Read,Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
        $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permission
        $acl.SetAccessRule($rule)
        # Настройки наследования
        $acl.SetAccessRuleProtection($false, $true)
        # Установка прав пользователю
        $acl | Set-Acl -Path $test_folder_p
        Write-host "Папка создана. Путь $test_folder_p"
    } 
    else {
        Write-host "[ERROR] Папка пользователя с путем: $folder_s уже существует"
    }

    $path = "c:\Users\vabischevich\Pictures\"
    $pathMove = "c:\Users\vabischevich\"
    $date = Get-date
    $extensions = @(".jpg",".jpeg")
    $ChildItems = Get-ChildItem $path

    foreach ($f in $ChildItems){
        if ($extensions -like $f.Extension){
            try {
                if ($f.Basename -eq $user.SamAccountName){
                    $photo = [byte[]]( $(resizephoto "$path\$f" 300 100))
                    Set-ADUser $user.SamAccountName -Replace @{thumbnailPhoto=$photo} -ErrorAction Continue
                    Move-Item -Path "$path\$f" -Destination $pathMove -Force
                    Add-Content -Path "$pathMove\log.txt" -Value "$user.SamAccountName Added $date" 
                    Write-Host "Photo installed"
                }
            }
            catch{
                Write-Host "file name is not correct"
                Add-Content -Path $path\Errors.txt -Value "$($_.Exception.Message)"  
                Write-Host "$($_.Exception.Message)"
            }
        }
    }
}