


function TestServices() {
    param ( $server )
    $FileServerServicehealth = $null

	$MonitoredServices = @(
        "datascrn",
        "SrmSvc",
        "LanmanServer",
        "quota",
        "ntds",
        "adws",
        "dncache",
        "kdc",
        "w32time",
        "netlogon",
        "dhcpserver",
        "Spooler",
        "vmms"
		)

	try {
        
		$AllServices = @(Get-WmiObject -ComputerName $server -Class Win32_Service -ErrorAction STOP | where {$MonitoredServices -icontains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$Servicehealth = "Fail"
	}

        

    
   return $AllServices

}

function TestFileServerHealth() {
    param ( $allServicesList )
    $FileServerServicehealth = $null
    $servicesrunning = @()
	$servicesnotrunning = @()
	$fileServerServices = @(
        "datascrn",
        "SrmSvc",
        "LanmanServer",
        "quota"
		)

	try {
        
		$servicestates = @($allServicesList | where {$fileServerServices -icontains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$FileServerServicehealth = "Fail"
	}

    if (!($FileServerServicehealth)) {
        
        $servicesrunning = @($servicestates | Where {$_.StartMode -eq "Auto" -and $_.State -eq "Running"})
		$servicesnotrunning = @($servicestates | Where {$_.Startmode -eq "Auto" -and $_.State -ne "Running"})
		if ($($servicesnotrunning.Count) -gt 0){

			Write-Verbose "Service health check failed"
		    Write-Verbose "Services not running:"
		    foreach ($service in $servicesnotrunning)
		    {
		        Write-Verbose "- $($service.Name)"	
		    }
			$FileServerServicehealth = "Fail"
            
		}
         else {
        
            Write-Verbose "Service health check passed"
            
            $FileServerServicehealth = "Pass"
            

        }            
    }



    

    
   return $FileServerServicehealth

}



function TestDHCPHealth() {
    param ( $allServicesList )
    $DHCPServerHealth = $null
    $servicesrunning = @()
	$servicesnotrunning = @()
	$dhcpservices = @(
        "dhcpserver"
		)
	try {
        
		$servicestates = @($allServicesList |  where {$dhcpservices -icontains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$DHCPServerHealth = "Fail"
	}

    if (!($DHCPServerHealth)) {
        
        $servicesrunning = @($servicestates | Where {$_.StartMode -eq "Auto" -and $_.State -eq "Running"})
		$servicesnotrunning = @($servicestates | Where {$_.Startmode -eq "Auto" -and $_.State -ne "Running"})
		if ($($servicesnotrunning.Count) -gt 0){

			Write-Verbose "Service health check failed"
		    Write-Verbose "Services not running:"
		    foreach ($service in $servicesnotrunning)
		    {
		        Write-Verbose "- $($service.Name)"	
		    }
			$DHCPServerHealth = "Fail"	
		}
         else {
        
            Write-Verbose "Service health check passed"
            
            $DHCPServerHealth = "Pass"
            

        }            
    }



    

    
   return $DHCPServerHealth

}

function TestPrintServerHealth() {
    param ( $allServicesList )
    $PrintServerHealth = $null
    $servicesrunning = @()
	$servicesnotrunning = @()
	$Printservices = @(
        "Spooler"
		)
	try {
        
		$servicestates = @($allServicesList |   where {$Printservices -icontains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$PrintServerHealth = "Fail"
	}

    if (!($PrintServerHealth)) {
        
        $servicesrunning = @($servicestates | Where {$_.StartMode -eq "Auto" -and $_.State -eq "Running"})
		$servicesnotrunning = @($servicestates | Where {$_.Startmode -eq "Auto" -and $_.State -ne "Running"})
		if ($($servicesnotrunning.Count) -gt 0){

			Write-Verbose "Service health check failed"
		    Write-Verbose "Services not running:"
		    foreach ($service in $servicesnotrunning)
		    {
		        Write-Verbose "- $($service.Name)"	
		    }
			$PrintServerHealth = "Fail"	
		}
         else {
        
            Write-Verbose "Service health check passed"
            
            $PrintServerHealth = "Pass"
            

        }            
    }



    

    
   return $PrintServerHealth

}

function TestHyperVServerHealth() {
    param ( $allServicesList )
    $HVServerHealth = $null
    $servicesrunning = @()
	$servicesnotrunning = @()
	$HVservices = @(
        "vmms"
		)
	try {
        
		$servicestates = @($allServicesList |   where {$HVservices -contains $_.Name} | select name,state,startmode)

	}
	catch
	{
		
		$HVServerHealth = "Fail"
	}

    if (!($HVServerHealth)) {
        
        $servicesrunning = @($servicestates | Where {$_.StartMode -eq "Auto" -and $_.State -eq "Running"})
		$servicesnotrunning = @($servicestates | Where {$_.Startmode -eq "Auto" -and $_.State -ne "Running"})
		if ($($servicesnotrunning.Count) -gt 0){

			Write-Verbose "Service health check failed"
		    Write-Verbose "Services not running:"
		    foreach ($service in $servicesnotrunning)
		    {
		        Write-Verbose "- $($service.Name)"	
		    }
			$HVServerHealth = "Fail"	
		}
         else {
        
            Write-Verbose "Service health check passed"
            
            $HVServerHealth = "Pass"
            

        }            
    }



    

    
   return $HVServerHealth

}

