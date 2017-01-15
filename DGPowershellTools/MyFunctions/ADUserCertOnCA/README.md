
Author: Damian Garbus
Web: http://e-damiangarbus.pl

ADUserCertOnCA.psm1

Powershell Module with 2 functions to get cert for specified Acitive Directory User issued from specified cert template


Example:

$Userlogin = (Get-AdUser username).SamaccountName

$ADUserLogin = "Domain\"+$UserLogin

Get-ADUserCertOnCA -TempplateString "1.3.6.1.4.1.311.21.8.12387444.5549974.4474019.236630.9193993.202.5736924.13833188" -ADUserLogin $ADUserLogin 
