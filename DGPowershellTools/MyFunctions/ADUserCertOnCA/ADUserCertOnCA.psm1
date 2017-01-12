#
# Author: Damian Garbus
# Web: http://e-damiangarbus.pl
#
# ADUserCertOnCA.psm1
#
# Powershell Module with 2 functions to get cert for specified Acitive Directory User issued from specified cert template
#
#
#
##############################################################
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


