
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
		
	if ($($ImportDataFromCSV.Count) -ne $ServerCount)  {
		
		$Server_list | % { 
			if ($($ActualMonitoringResult.Server) -notcontains $_) {
				$serverObj = New-Object PSObject
	            $serverObj | Add-Member NoteProperty -Name "Server" -Value $server
                $serverObj | Add-Member NoteProperty -Name "DNS" -Value "NoResult"
	            $serverObj | Add-Member NoteProperty -Name "Ping" -Value "NoResult"
				$serverObj | Add-Member NoteProperty -Name "DCServices" -Value "NoResult"
			
			}
		
		}

	}

}


$ResultProperties = ($ActualMonitoringResult | gm -MemberType NoteProperty).Name | ? {$_ -ne "Server"}

foreach ($Property in $ResultProperties) {
	
	$ActualFailed = $ActualMonitoringResult |? {$_.$Property -ne "Pass" -and $_.$Property -ne "n/a"}
	If ($ActualFailed -ne $null){
		foreach ($ActualFailedLine in $ActualFailed) {
		
			$serverObj = New-Object PSObject
			$serverObj | Add-Member NoteProperty -Name Server -Value $($ActualFailedLine.Server)
			$serverObj | Add-Member NoteProperty -Name Failed -Value $Property
			$serverObj | Export-Csv "$scriptPath\temp\FailedResult.csv" -Delimiter ";" -NoTypeInformation -Append
		}
	}


}

#Create Alert Summarry
$ActualFailed = Import-Csv "$scriptPath\temp\FailedResult.csv" -Delimiter ";"
[array]$AlertSummary = @()
foreach ($FailedServer in $ActualFailed) {
	Write-Host "FailedServer: $($FailedServer.Server)" -ForegroundColor Green
	$check = $LastFailed | ? {$_.Server -eq $($FailedServer.Server) -and $_.Failed -eq $($FailedServer.Failed)}
	
	if($check -ne $null){
		$Alert = $true
		$AlertServerSummary = New-Object PSObject
		$AlertServerSummary | Add-Member NoteProperty -Name Server -Value $($FailedServer.Server)
		$AlertServerSummary | Add-Member NoteProperty -Name Failed -Value $($FailedServer.Failed)

		$AlertSummary = $AlertSummary + $AlertServerSummary

	 }

}

$AlertSummary


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
	if ($($serversummary.count) -gt 0)
	{
		#Set alert flag to true
		$alerts = $true
	
		#Generate the HTML
		$serversummaryhtml = "<h3>Servers Errors</h3>
						<p>The following server errors and warnings were detected.</p>
						<p>
						<ul>"
		foreach ($reportline in $serversummary)
		{
			$serversummaryhtml +="<li>$reportline</li>"
		}
		$serversummaryhtml += "</ul></p>"
		$alerts = $true
	}
	else
	{
		#Generate the HTML to show no alerts
		$serversummaryhtml = "<h3>Servers Errors</h3>
						<p>No Exchange server health errors or warnings.</p>"
	}
	
	


	#Exchange Server Health Report Table Header
	$htmltableheader = "<h3>Exchange Server Health</h3>
						<p>
						<table>
						<tr>
						<th>Server</th>
						<th>DNS</th>
						<th>Ping</th>
						<th>Uptime (hrs)</th>
						<th>DC Services</th>
						<th>FileServer Services</th>
						<th>Hyper-V Services</th>
						<th>DHCP Services</th>
						<th>Print Services</th>
						</tr>"

	#Exchange Server Health Report Table
	$serverhealthhtmltable = $serverhealthhtmltable + $htmltableheader					
						
	foreach ($reportline in $report)
	{
		$htmltablerow = "<tr>"
		$htmltablerow += "<td>$($reportline.server)</td>"
        $htmltablerow += (New-ServerHealthHTMLTableCell "dns")
		$htmltablerow += (New-ServerHealthHTMLTableCell "ping")
		
		if ($($reportline."uptime (hrs)") -eq "Access Denied")
		{
			$htmltablerow += "<td class=""warn"">Access Denied</td>"		
		}
        elseif ($($reportline."uptime (hrs)") -eq $string17)
        {
            $htmltablerow += "<td class=""warn"">$string17</td>"
        }
		else
		{
			$hours = [int]$($reportline."uptime (hrs)")
			if ($hours -le 1)
			{
				$htmltablerow += "<td class=""warn"">$hours</td>"
			}
			else
			{
				$htmltablerow += "<td class=""pass"">$hours</td>"
			}
		}

		$htmltablerow += (New-ServerHealthHTMLTableCell "DC Services")
		$htmltablerow += (New-ServerHealthHTMLTableCell "FileServer Services")
		$htmltablerow += (New-ServerHealthHTMLTableCell "Hyper-V Services")
		$htmltablerow += (New-ServerHealthHTMLTableCell "DHCP Services")
		$htmltablerow += (New-ServerHealthHTMLTableCell "Print Services")
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
		if ($alerts -eq $false -and $AlertsOnly -eq $true)
		{
			#Do not send email message
			Write-Host $string19
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