#
# ConvertFromPolishLetters.ps1
#
function ConvertFromPolishLetters() 
{ param ([string]$WordtoConvert) 
  $a = $WordtoConvert ; 
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","a");}
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","A");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","c");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","C");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","e");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","E");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","l");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","l");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","n");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","N");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","o");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","s");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","S");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","z");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","Z");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","z");}  
  if ($a.contains("�") -eq $True) { $a = $a -replace("�","Z");}  
  $a;
}