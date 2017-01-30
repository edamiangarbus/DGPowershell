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


function Write-Feedback()
{
  param
  (
    
    [string]$msg,
    [string]$ErrorFeedback = "0",
    [string]$OutFile
  )
 if ($ErrorFeedback -eq "0"){
    $VerbosePreference = "Continue";
    Write-Verbose $msg -Verbose 4>&1 ;
    Write-Verbose $msg;
    
    if ($OutFile){
        $msg | Out-File "$OutFile" -Append;
    }
 }
 elseif ($ErrorFeedback -eq "1"){
   Write-Error $msg;
     
    if ($OutFile){
        $msg | Out-File "$OutFile" -Append;
    }
 }
 
}

#Check if Server DNS Name can be resolved
function CheckResolveDNSName {
	param (
		[string]$ServerName

	)

	Write-Host "DNS Check: " -NoNewline;
	$DNS_check = "Fail"
    try 
	{
		$ip = @([System.Net.Dns]::GetHostByName($ServerName).AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
	}
	catch
	{
			Write-Host -ForegroundColor "Yellow" $_.Exception.Message
			$ip = $null
	}

	if ( $ip -ne $null ){
        Write-Host -ForegroundColor "Green" "Pass"
        $DNS_check = "Pass"
    }
	return $DNS_check
}
Function Test-ComputerConnection 
{
    <#  
        .SYNOPSIS
            Test-ComputerConnection sends a ping to the specified computer or IP Address specified in the ComputerName parameter.

        .DESCRIPTION
            Test-ComputerConnection sends a ping to the specified computer or IP Address specified in the ComputerName parameter. Leverages the System.Net object for ping
            and measures out multiple seconds faster than Test-Connection -Count 1 -Quiet.

        .PARAMETER ComputerName
            The name or IP Address of the computer to ping.

        .EXAMPLE
            Test-ComputerConnection -ComputerName "THATPC"

            Tests if THATPC is online and returns a custom object to the pipeline.

        .EXAMPLE
            $MachineState = Import-CSV .\computers.csv | Test-ComputerConnection -Verbose

            Test each computer listed under a header of ComputerName, MachineName, CN, or Device Name in computers.csv and
            and stores the results in the $MachineState variable.

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
        [alias("CN","MachineName","Device Name")]
        [string]$ComputerName   
    )
    Begin
    {
        [int]$timeout = 20
        [switch]$resolve = $true
        [int]$TTL = 128
        [switch]$DontFragment = $false
        [int]$buffersize = 32
        $options = new-object system.net.networkinformation.pingoptions
        $options.TTL = $TTL
        $options.DontFragment = $DontFragment
        $buffer=([system.text.encoding]::ASCII).getbytes("a"*$buffersize)   
    }
    Process
    {
        $ping = new-object system.net.networkinformation.ping
        try
        {
            $reply = $ping.Send($ComputerName,$timeout,$buffer,$options)
            if ($reply.status -ne "Success") { 
				Start-Sleep 2
                $reply = $ping.Send($ComputerName,$timeout,$buffer,$options)
                if ( $reply.status -ne "Success") { 
					 Start-Sleep 2
                     $reply = $ping.Send($ComputerName,$timeout,$buffer,$options)  
                     if ( $reply.status -ne "Success") {
						Start-Sleep 2 
                        $reply = $ping.Send($ComputerName,$timeout,$buffer,$options)  

                     }

                }
                
                
                
            }
              
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
        }
        if ($reply.status -eq "Success")
        {
            $props = @{ComputerName=$ComputerName
                        Online=$True
            }
        }
        else
        {
            $props = @{ComputerName=$ComputerName
                        Online=$False           
            }
        }
        New-Object -TypeName PSObject -Property $props
    }
    End{}
}

function TestDGConnection(){
    param( $Server )
	Write-Host "Server $server"
	$EndDefaultGateway = "1","3";
	$DefaultGateways = @();
    $IPAddress = (Resolve-DnsName $server).IPAddress
	do {if ($IPAddress[($IPAddress.Length)-1] -ne "."){$IPAddress = $IPAddress.TrimEnd($IPAddress[($IPAddress.Length)-1])}}while ($IPAddress[($IPAddress.Length)-1] -ne ".");
    $EndDefaultGateway | % {$DefaultGateways += ($IPAddress+$_)};
    $GWStatus = "Fail"
	
    Foreach ($GW in $DefaultGateways){
        
        $check = Test-ComputerConnection $GW ;
		
        if ($check.Online -eq $true) {
		
		$GWStatus="Pass"
		
		}
            
        

    }
    return $GWStatus
}

function CheckServerPing {
	param (
		[string]$Server
	)
	
	Write-Host "Ping Check: " -NoNewline; 
    $checkGW = TestDGConnection -Server $server	
    if ($checkGW -eq "Pass"){
        $ping = $null
			try
			{
				$checkPing = Test-ComputerConnection $server
                if ($checkPing.Online -eq $true) {$ping = $true}
                else {$ping = $false}
			}
			catch
			{
                Write-Feedback -ErrorFeedback "1" -msg "Brak Ping serwera $server"

			}

			switch ($ping)
			{
				$true {
					Write-Host -ForegroundColor "Green" "Pass"
					$Check_ping  = "Pass"
					
					}
				default {
					Write-Host -ForegroundColor "Yellow" "Fail"
					$Check_ping  = "Fail"
					

					}
			}


    }

    else {
        $Check_ping  = "GWFail"
        $ping = $false
    }

	return $Check_ping

}

function CheckDCHealth {
    param ( 
		[string]$Server
	)
    $DCHealth = $null
    $servicesrunning = @()
	$servicesnotrunning = @()
	$dcservices = @(
        "ntds",
        "adws",
        "dncache",
        "kdc",
        "w32time",
        "netlogon"
		)
	try {
        
		$servicestates =@(Get-WmiObject -ComputerName $server -Class Win32_Service -ErrorAction STOP | where {$dcservices -icontains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$DCServiceHealth = "WMIFail"
	}

    if (!($DCServiceHealth)) {
        
        $servicesrunning = @($servicestates | Where {$_.StartMode -eq "Auto" -and $_.State -eq "Running"})
		$servicesnotrunning = @($servicestates | Where {$_.Startmode -eq "Auto" -and $_.State -ne "Running"})
		if ($($servicesnotrunning.Count) -gt 0){

			Write-Verbose "Service health check failed"
		    Write-Verbose "Services not running:"
		    foreach ($service in $servicesnotrunning)
		    {
		        Write-Verbose "- $($service.Name)"	
		    }
			$DCServiceHealth = "Fail"	
		}
         else {
        
            Write-Verbose "Service health check passed"
            
            $DCServiceHealth = "Pass"
            

        }            
    }

    
   return $DCServiceHealth

}


