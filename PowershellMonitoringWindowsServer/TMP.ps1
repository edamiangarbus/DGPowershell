	            foreach($col in $colname)
	            {   
                    if ($DaneWniosku.$col -and $col -ne "Manager" -and $col -ne "IsGrant" -and $col -ne "RecipientUser" -and $col -ne "RecipientType"){
                        $attr = $col+": "+$DaneWniosku.$col;
                        Write-Feedback -msg $attr -OutFile "$Log_Path\$LogName";
                        $otherAttributes.Add($col,$DaneWniosku.$col);           
                    }

        
	            }