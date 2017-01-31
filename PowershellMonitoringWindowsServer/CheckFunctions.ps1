param (
	[string]$Server

)


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\Functions.ps1
if (Test-Path "$scriptPath\temp\MonitorResult.csv"){
	rm "$scriptPath\temp\MonitorResult.csv" -Force
}

$serverObj = New-Object PSObject
$serverObj | Add-Member NoteProperty -Name "1-Server" -Value $server
$serverObj | Add-Member NoteProperty -Name "2-DNS" -Value (CheckResolveDNSName -ServerName $Server)
$serverObj | Add-Member NoteProperty -Name "3-Ping" -Value (CheckServerPing -Server $Server)
$serverObj | Add-Member NoteProperty -Name "4-DCServices" -Value (CheckDCHealth -Server $Server -DependsOn $serverObj."3-Ping" )



$serverObj | Export-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";" -NoTypeInformation -Append