
[CmdletBinding()]
param (
	[Parameter( Mandatory=$false)]
	[string]$Server,

	[Parameter( Mandatory=$false)]
	[string]$ServerList,	
	
	[Parameter( Mandatory=$false)]
	[string]$ReportFile="USWINserverhealth.html",

	[Parameter( Mandatory=$false)]
	[switch]$ReportMode,
	
	[Parameter( Mandatory=$false)]
	[switch]$SendEmail,

	[Parameter( Mandatory=$false)]
	[switch]$AlertsOnly,	
	
	[Parameter( Mandatory=$false)]
	[switch]$Log

	)

	Function New-ServerHealthHTMLTableCell()
{
	param( $lineitem )
	
	$htmltablecell = $null
	
	switch ($($reportline."$lineitem"))
	{
		$success {$htmltablecell = "<td class=""pass"">$($reportline."$lineitem")</td>"}
        "Success" {$htmltablecell = "<td class=""pass"">$($reportline."$lineitem")</td>"}
        "Pass" {$htmltablecell = "<td class=""pass"">$($reportline."$lineitem")</td>"}
		"Warn" {$htmltablecell = "<td class=""warn"">$($reportline."$lineitem")</td>"}
		"Access Denied" {$htmltablecell = "<td class=""warn"">$($reportline."$lineitem")</td>"}
		"Fail" {$htmltablecell = "<td class=""fail"">$($reportline."$lineitem")</td>"}
        "Could not test service health. " {$htmltablecell = "<td class=""warn"">$($reportline."$lineitem")</td>"}
		"Unknown" {$htmltablecell = "<td class=""warn"">$($reportline."$lineitem")</td>"}
		default {$htmltablecell = "<td>$($reportline."$lineitem")</td>"}
	}
	
	return $htmltablecell
}

#...................................
# Variables
#...................................
$now = Get-Date
$EndDefaultGateway = "1","3";
$DefaultGateways = @();
$pass = "Green"
$warn = "Yellow"
$fail = "Red"
[array]$report = @()
$ALL_Servers = "r_MonUswin"
$DomainControlersGroup = "r_MonDC"
$FileServersGroup = "r_SerweryPlików_Regiony"
$DHCPServersGroup = "r_Serwery_DHCP_USWIN"
$PrintServersGroup = "r_SerweryPlików_Regiony"
$HyperVServerGroup = "r_HyperV_USWIN"

#Maksymalna ilość sekund oczekiwania na informacje ze wszystkich serwerów
$TimeOut = 60
#...................................
# Modify these Email Settings
#...................................
$now = Get-Date
$reportemailsubject = "Raport Serwerów USWIN"
$smtpsettings = @{
	To =  "dgarbus@3pro.pl"
	From = "arimr_powiadomienia@arimr.gov.pl"
	Subject = "$reportemailsubject - $now"
	SmtpServer = "smtpr.zszik.pl"
	}





#...................................
# Initialize
#...................................
$ServersList = (Get-ADGroupMember $ALL_Servers).Name 
#$ServersList = "jira","DC01"
<#$FileServersList = (Get-ADGroupMember $FileServersGroup).Name 
$DomainControlersList = (Get-ADGroupMember $DomainControlersGroup).Name 
$DHCPServersList = (Get-ADGroupMember $DHCPServersGroup).Name 
$PrintServersList = (Get-ADGroupMember $PrintServersGroup).Name
$HyperVServerList = (Get-ADGroupMember $HyperVServerGroup).Name
#>
#Sprawdzanie ilości serwerów do Monitorowania
$ServerCount = ($ServersList |measure).Count

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
#Remove Old Result File
if (Test-Path "$scriptPath\temp\MonitorResult.csv"){
	rm "$scriptPath\temp\MonitorResult.csv" -Force
}
#Check temp folder and if not exist create
if (!(Test-Path "$scriptPath\temp")){
	mkdir "$scriptPath\temp"
}


foreach ($server in $ServersList){
    $Server
	invoke-expression "cmd /c start powershell -WindowStyle Hidden -Command {$scriptPath\CheckFunctions.ps1 -Server $Server}"


}

### Begin report generation
if (Test-Path "$scriptPath\temp\MonitorResult.csv"){
	$ActualMonitoringResult = Import-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";"
}
 
if (Test-Path "$scriptPath\temp\FailedResult.csv"){
	$LastFailed = Import-Csv "$scriptPath\temp\FailedResult.csv" -Delimiter ";"
	rm "$scriptPath\temp\FailedResult.csv" -Force
}
$curCheck = 0
$reciveCount = 0
#Check if all servers gave feedback
if ($($ActualMonitoringResult.Count) -ne $ServerCount) {
	do {
		Write-Host "Oczekiwanie na serwery" -ForegroundColor Yellow; 
		start-sleep 2; 
		if (Test-Path "$scriptPath\temp\MonitorResult.csv"){
			$ActualMonitoringResult = Import-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";"
		}
		$curCheck += 1 ;
		$reciveCount = $ActualMonitoringResult.Count;
		Write-Host "Obecny status Feedback: $reciveCount/$ServerCount"
		} 
		while ($reciveCount -ne $ServerCount -and $curCheck -ne $TimeOut)
	$FirstColumnName = ($ActualMonitoringResult | gm -MemberType NoteProperty).Name | select -First 1
	$ResultProperties = ($ActualMonitoringResult | gm -MemberType NoteProperty).Name | ? {$_ -ne $FirstColumnName}
	
	if ($($ActualMonitoringResult.Count) -lt $ServerCount)  {
		
		Foreach ($Server in $Server_list) { 
			if ($($ActualMonitoringResult.Server) -notcontains $Server) {
				$serverObj = New-Object PSObject
				$serverObj | Add-Member NoteProperty -Name $FirstColumnName -Value $server
				foreach ($ResultProperty in $ResultProperties) {
					$serverObj | Add-Member NoteProperty -Name $ResultProperty -Value "NoResult"
				}
				
				$serverObj | Export-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";" -NoTypeInformation -Append
				

			}
		
		}

	}

}

$ActualMonitoringResult = Import-Csv "$scriptPath\temp\MonitorResult.csv" -Delimiter ";"
$ResultProperties = ($ActualMonitoringResult | gm -MemberType NoteProperty).Name | ? {$_ -ne $FirstColumnName}

foreach ($Property in $ResultProperties) {
	
	$ActualFailed = $ActualMonitoringResult |? {$_.$Property -ne "Pass" -and $_.$Property -ne "n/a"}
	If ($ActualFailed -ne $null){
		foreach ($ActualFailedLine in $ActualFailed) {
		
			$serverObj = New-Object PSObject
			$serverObj | Add-Member NoteProperty -Name Server -Value $($ActualFailedLine.$FirstColumnName)
			$serverObj | Add-Member NoteProperty -Name Failed -Value $Property
			$serverObj | Export-Csv "$scriptPath\temp\FailedResult.csv" -Delimiter ";" -NoTypeInformation -Append
		}
	}


}

#Create Alert Summarry
if (Test-Path "$scriptPath\temp\FailedResult.csv"){
	$ActualFailed = Import-Csv "$scriptPath\temp\FailedResult.csv" -Delimiter ";"


	[array]$AlertSummary = @()
	foreach ($FailedServer in $ActualFailed) {
		Write-Host "FailedServer: $($FailedServer.Server)" -ForegroundColor Green
		$check = $LastFailed | ? {$_.Server -eq $($FailedServer.Server) -and $_.Failed -eq $($FailedServer.Failed)}
	
		if($check -ne $null){
			$AlertServerSummary = New-Object PSObject
			$AlertServerSummary | Add-Member NoteProperty -Name Server -Value $($FailedServer.Server)
			$AlertServerSummary | Add-Member NoteProperty -Name Failed -Value $($FailedServer.Failed)

			$AlertSummary = $AlertSummary + $AlertServerSummary

		 }

	}
}
$AlertSummary 

$ActualMonitoringResult = $ActualMonitoringResult | Sort-Object -Property $ResultProperties


if ($ReportMode -or $SendEmail)
{
	#Get report generation timestamp
	$reportime = Get-Date

	#Create HTML Report
	#Common HTML head and styles
	$htmlhead="<html>
				<style>
				BODY{font-family: Arial; font-size: 8pt;}
				H1{font-size: 16px;}
				H2{font-size: 14px;}
				H3{font-size: 12px;}
				TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
				TH{border: 1px solid black; background: #dddddd; padding: 5px; color: #000000;}
				TD{border: 1px solid black; padding: 5px; }
				td.pass{background: #7FFF00;}
				td.warn{background: #FFE600;}
				td.fail{background: #FF0000; color: #ffffff;}
				td.info{background: #85D4FF;}
				</style>
				<body>
				<h1 align=""center"">Raport Serwerów USWIN</h1>
				<h3 align=""center"">Generated: $reportime</h3>"

	#Check if the server summary has 1 or more entries
	
	if ($($AlertSummary.count) -gt 0)
	{
		#Set alert flag to true
		$alerts = $true
	
		#Generate the HTML
		$serversummaryhtml = "<h3>Servers Errors</h3>
						<p>The following server errors and warnings were detected.</p>
						<p>
						<ul>"
		foreach ($reportline in $AlertSummary)
		{
			$l = $reportline.Server + " - " + $reportline.Failed + " - Fail"
			$serversummaryhtml +="<li>$l</li>"
		}
		$serversummaryhtml += "</ul></p>"
		
	}
	else
	{
		#Generate the HTML to show no alerts
		$serversummaryhtml = "<h3>Servers Errors</h3>
						<p>No Server health errors or warnings.</p>"
	}
	
	
	$htmltableheader = "<h3>Server Health</h3>
						<p>
						<table>
						<tr>
						<th>$FirstColumnName</th>"
	foreach ($ResultProperty in $ResultProperties){
		$htmltableheader += "<th>" + $ResultProperty + "</th>"
	}
	$htmltableheader += "</tr>"

	#Server Health Report Table
	$serverhealthhtmltable = $serverhealthhtmltable + $htmltableheader					
    foreach ($reportline in $ActualMonitoringResult){
		$htmltablerow = "<tr>"
		$htmltablerow += "<td>$($reportline.$FirstColumnName)</td>"
		foreach ($Property in $ResultProperties) {
			$htmltablerow += (New-ServerHealthHTMLTableCell $Property)
		}
		$htmltablerow += "</tr>"
		$serverhealthhtmltable = $serverhealthhtmltable + $htmltablerow
	}
	$serverhealthhtmltable = $serverhealthhtmltable + "</table></p>"

	$htmltail = "</body>
				</html>"
	$htmlreport = $htmlhead + $serversummaryhtml + $serverhealthhtmltable + $htmltail						
	
	
	if ($ReportMode -or $ReportFile)
	{
		$htmlreport | Out-File $ReportFile -Encoding UTF8
	}

	if ($SendEmail)
	{
		if ($alerts -ne $true -and $AlertsOnly -eq $true)
		{
			#Do not send email message
			Write-Host "Alerts Only"
			if ($Log) {Write-Logfile $string19}
		}
		else
		{
			#Send email message
			Write-Host $string14
			Send-MailMessage @smtpsettings -Body $htmlreport -BodyAsHtml -Encoding ([System.Text.Encoding]::UTF8)
		}
	}
}