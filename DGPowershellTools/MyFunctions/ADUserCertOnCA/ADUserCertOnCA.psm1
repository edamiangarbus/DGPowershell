#
# Author: Damian Garbus
# Web: http://e-damiangarbus.pl
#
# ADUserCertOnCA.psm1
#
# 
#
#
#
##############################################################

<#
Author: Damian Garbus
Web: http://e-damiangarbus.pl

.SYNOPSIS
Powershell Module to get cert for specified Acitive Directory User issued from specified cert template in CA.

.DESCRIPTION
Powershell Module to get cert for specified Acitive Directory User issued from specified cert template in CA. In order to get cert for specified user
you have to use NetBios domain name with samaccountname in format "domain\samaccountname"

.EXAMPLE
$ADUserLogin = "domain\"+(get-aduser user1).samaccountname

$certs = Get-ADUserCertOnCA -TempplateString "1.3.6.1.4.1.311.21.8.12387444.5549974.4474019.236630.9193993.202.5736924.13833188" -ADUserLogin $ADUserLogin

                foreach ($serial in $certs) {
                    Revoke-ADUserCertonCA -CertSerialNumber $serial -ReasonCode "6";

                }
.NOTES
Put some notes here.

.LINK
https://github.com/edamiangarbus/DGPowershell/tree/master/DGPowershellTools/MyFunctions/ADUserCertOnCA
http://e-damiangarbus.pl

#>


function Get-ADUserCertOnCA () {

        param (
            [string]$TempplateString,
            [string]$ADUserLogin


        )


        $x = certutil -view -restrict "CertificateTemplate = $TempplateString, Request.RequesterName = $ADUserLogin, Request.Disposition = 20" -out "Request.RequesterName, SerialNumber"
        $option = [System.StringSplitOptions]::RemoveEmptyEntries
        $serial_numbers = $x | select-string "Serial Number: "
        $tmp = $serial_numbers -split ("Serial Number: ",$option)
        $tmp = $tmp -replace 'Serial Number: "',''
        $tmp = $tmp -replace '"',''

        $serial = $tmp -replace " ",""
    
        return $serial


    }

function Revoke-ADUserCertonCA () {
    param (
        [array]$CertSerialNumber,
        [string]$ReasonCode

    )

    $CertSerialNumber | % {certutil -revoke $_ $ReasonCode}




}


