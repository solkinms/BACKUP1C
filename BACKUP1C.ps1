#All out in file start
Start-Transcript -Path D:\BACKUP1c.txt
#Restart service 1C
restart-service -name '1C:Enterprise 8.3 Server Agent (x86-64)'
Start-Sleep -Seconds 30
#List of IB
$listIb = @('IB1','IB2','IB3')
#Start of the backup cycle
foreach ($Base in $listIb) {
	#Create folder for backups
	New-Item -Path "\\share\backups\DT\$Base" -ItemType Directory -Force
	#Variables
	$countCheck = 0
	$DateTime = Get-Date -UFormat "%d_%m_%Y_%H-%M"
	$PatchBackup = "\\share\backups\DT\$Base" + "\" + $Base + "_" + $DateTime + ".dt"
	$1cexe = '"C:\Program Files\1cv8\common\1cestart.exe"'
	$BaseServer = "/Ssrvdb\" + $Base
	$AdminLogin = '"/Nuseruser"'
	$Pswd = "/Ppasspass"
	$ExitUsers = " /CЗавершитьРаботуПользователей"
	$EnterUsers = " /CРазрешитьРаботуПользователей /UCКодРазрешения"
	$Argument = "ENTERPRISE $BaseServer $AdminLogin $Pswd /DisableStartupMessages"
	$ArgumentBackup = "DESIGNER $BaseServer $AdminLogin $Pswd /DumpIB" + $PatchBackup
 
#Blocking entrance in 1C
Start-Process $1cexe "$Argument $ExitUsers"
Start-Sleep -Seconds 30
#We complete the 1C process
if (Get-Process -name 1cv8c -ErrorAction SilentlyContinue) {
		Stop-Process -Name 1cv8c
	} else {
		Stop-Process -Name 1cv8
}
Start-Sleep -Seconds 5
#Unblocking entrance in 1C
Start-Process $1cexe "$Argument $EnterUsers"
Start-Sleep -Seconds 30
#We complete the 1C process
if (Get-Process -name 1cv8c -ErrorAction SilentlyContinue) {
		Stop-Process -Name 1cv8c
	} else {
		Stop-Process -Name 1cv8
}
Start-Sleep -Seconds 5
#Start uploading to DT
Start-Process $1cexe $ArgumentBackup
#Check DT file
While($true) {
	if ($countCheck -le 10) {
		$countCheck++
		if (Test-Path $PatchBackup) {
			Write-Host ("Backup OK $Base")
			break
		}
		Start-Sleep -Seconds 60
	} else {
		break
	}
}
}
#Stop service 1C
Stop-service -name '1C:Enterprise 8.3 Server Agent (x86-64)'
#Restart service MSSQL
restart-service -name 'MSSQLSERVER'
Start-Sleep -Seconds 30
#Start service 1C
Start-service -name '1C:Enterprise 8.3 Server Agent (x86-64)'
Start-Sleep -Seconds 30
Stop-Transcript
exit
