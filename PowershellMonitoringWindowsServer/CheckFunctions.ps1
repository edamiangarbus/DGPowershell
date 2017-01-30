param (
	[string]$Server

)


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\Functions.ps1
if (Test-Path "$scriptPath\temp\MonitorResult.csv"){
	rm "$scriptPath\temp\MonitorResult.csv" -Force
}

$serverObj = New-Object PSObject
$serverObj | Add-Member NoteProperty -Name "Server" -Value $server
$serverObj | Add-Member NoteProperty -Name "DNS" -Value (CheckResolveDNSName -ServerName $Server)
$serverObj | Add-Member NoteProperty -Name "Ping" -Value (CheckServerPing -Server $Server)
if ($serverObj.Ping -eq "Pass") {
	$serverObj | Add-Member NoteProperty -Name "DCServices" -Value (CheckDCHealth -Server $Server)
}
else {
	$serverObj | Add-Member NoteProperty -Name "DCServices" -Value "n/a"
}



$serverObj | Export-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";" -NoTypeInformation -Append