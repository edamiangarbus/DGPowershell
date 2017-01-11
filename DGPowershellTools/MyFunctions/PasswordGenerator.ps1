#
# PasswordGenerator.ps1
#
$alphanumeric = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,@#$!'.ToCharArray();
function RandomString([int] $len, [Array] $charSet = $alphanumeric)
{
	[String]::Join('', (1..$len | % { $charSet | Get-Random }));
}