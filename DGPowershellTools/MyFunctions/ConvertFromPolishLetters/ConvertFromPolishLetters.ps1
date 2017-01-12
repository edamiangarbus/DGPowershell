#
# ConvertFromPolishLetters.ps1
#
function ConvertFromPolishLetters() 
{ param ([string]$WordtoConvert) 
  $a = $WordtoConvert ; 
  if ($a.contains("π") -eq $True) { $a = $a -replace("π","a");}
  if ($a.contains("•") -eq $True) { $a = $a -replace("•","A");}  
  if ($a.contains("Ê") -eq $True) { $a = $a -replace("Ê","c");}  
  if ($a.contains("∆") -eq $True) { $a = $a -replace("∆","C");}  
  if ($a.contains("Í") -eq $True) { $a = $a -replace("Í","e");}  
  if ($a.contains(" ") -eq $True) { $a = $a -replace(" ","E");}  
  if ($a.contains("≥") -eq $True) { $a = $a -replace("≥","l");}  
  if ($a.contains("£") -eq $True) { $a = $a -replace("£","l");}  
  if ($a.contains("Ò") -eq $True) { $a = $a -replace("Ò","n");}  
  if ($a.contains("—") -eq $True) { $a = $a -replace("—","N");}  
  if ($a.contains("Û") -eq $True) { $a = $a -replace("Û","o");}  
  if ($a.contains("ú") -eq $True) { $a = $a -replace("ú","s");}  
  if ($a.contains("å") -eq $True) { $a = $a -replace("å","S");}  
  if ($a.contains("ü") -eq $True) { $a = $a -replace("ü","z");}  
  if ($a.contains("è") -eq $True) { $a = $a -replace("è","Z");}  
  if ($a.contains("ø") -eq $True) { $a = $a -replace("ø","z");}  
  if ($a.contains("Ø") -eq $True) { $a = $a -replace("Ø","Z");}  
  $a;
}