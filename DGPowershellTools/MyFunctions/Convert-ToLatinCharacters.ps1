#
# Convert_ToLatinCharacters.ps1
#
function Convert-ToLatinCharacters {
	param(
		[string]$inputString
	)
	[Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($inputString))
}