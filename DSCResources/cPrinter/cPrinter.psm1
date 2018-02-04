function Get-TargetResource {
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("TCPIP","LPR","Papercut")]
        $PortType = "TCPIP",   
        
        [Parameter(Mandatory=$false)]
        [System.String]
        $lprQueue,

		[parameter(Mandatory = $true)]
		[System.String]
		$PortName,

		[parameter(Mandatory = $true)]
		[System.String]
		$Address,

		[parameter(Mandatory = $true)]
		[System.String]
		$DriverName,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $Shared,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $SNMPEnabled = $true,

        [Parameter(Mandatory=$false)]
        [System.String]
        $SNMPCommunityName = "public",
    
        [Parameter(Mandatory=$false)]
        [System.Int16]
        $SNMPIndex = 1,

        [Parameter(Mandatory=$false)]
        [System.String]
        $PermissionSDDL
    )
    
    $printer = Get-Printer -Name $Name -Full -ErrorAction SilentlyContinue
    $printerPort = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
    if(!$printer -or !$printerPort){
        return @{
            Name = $Name
            Ensure = "Absent"
           
        }
    }
    if($printerPort.LprQueueName){
        $currentPortType = "LPR"
    } elseif([bool]($printerPort.Description -eq "PaperCut TCP/IP Port")){
        $currentPortType = "Papercut"
    }

    switch ($currentPortType) {
        LPR {
            return @{
                Name = $Name
                Ensure = "Present"
                PortName = $printer.PortName
                Address = $printerPort.PrinterHostAddress
                DriverName = $printer.DriverName
                Shared = $printer.Shared
                lprQueue = $printerPort.LprQueueName
                SNMPEnabled = $printerPort.SNMPEnabled
                SNMPCommunityName = $printerPort.SNMPCommunity
                SNMPIndex = $printerPort.SNMPIndex
                PortType = "LPR"
                PermissionSDDL = $printer.PermissionSDDL
            }
        }
        Papercut {
            $papercutPortProperties = Get-Item  "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" -ErrorAction SilentlyContinue | Get-ItemProperty -ErrorAction SilentlyContinue
            return @{
                Name = $Name
                Ensure = "Present"
                PortName = $printer.PortName
                Address = $papercutPortProperties.HostName
                DriverName = $printer.DriverName
                Shared = $printer.Shared
                SNMPEnabled = $false
                PortType = "Papercut"
                PermissionSDDL = $printer.PermissionSDDL
            }
        }
        default {
            return @{
                Name = $Name
                Ensure = "Present"
                PortName = $printer.PortName
                Address = $printerPort.PrinterHostAddress
                DriverName = $printer.DriverName
                Shared = $printer.Shared
                SNMPEnabled = $printerPort.SNMPEnabled
                SNMPCommunityName = $printerPort.SNMPCommunity
                SNMPIndex = $printerPort.SNMPIndex
                PortType = "TCPIP"
                PermissionSDDL = $printer.PermissionSDDL
            }
        }
    }
}
function Set-TargetResource {
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("TCPIP","LPR","Papercut")]
        $PortType = "TCPIP",   
        
        [Parameter(Mandatory=$false)]
        [System.String]
        $lprQueue,

		[parameter(Mandatory = $true)]
		[System.String]
		$PortName,

		[parameter(Mandatory = $true)]
		[System.String]
		$Address,

		[parameter(Mandatory = $true)]
		[System.String]
		$DriverName,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $Shared,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $SNMPEnabled = $true,

        [Parameter(Mandatory=$false)]
        [System.String]
        $SNMPCommunityName = "public",
    
        [Parameter(Mandatory=$false)]
        [System.Int16]
        $SNMPIndex = 1,

        [Parameter(Mandatory=$false)]
        [System.String]
        $PermissionSDDL
    )
   
    $currentValues = Get-TargetResource @PSBoundParameters
    
    if ($Ensure -eq "Present") {
        if($currentValues.Ensure -eq "Absent") {
            #There is no printer so we need to create a new printer
            #We need to create the port first
            Write-Verbose -Message "No pre-existing printer exists. Adding new printer"
            if(!(Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)){
                switch ($PortType) {
                    LPR {
                        if($SNMPEnabled){
                            Add-PrinterPort -Name $PortName -LprHostAddress $Address -LprQueueName $lprQueue -LprByteCounting:$true -SNMP:([System.Convert]::ToBoolean($SNMPEnabled)) -SNMPCommunity $SNMPCommunityName
                        } else {
                            Add-PrinterPort -Name $PortName -LprHostAddress $Address -LprQueueName $lprQueue -LprByteCounting:$true
                        }
                        
                    } # End LPR
                    Papercut {
                        REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v HostName /t REG_SZ /d $Address /f | Out-Null
                        REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v PortNumber /t REG_DWORD /d 0x0000238c /f | Out-Null
                        Restart-Service -Name "Spooler" -Force
                    } # END Papercut
                    default {
                        if($SNMPEnabled){
                            Add-PrinterPort -Name $PortName -PrinterHostAddress $Address -SNMP:([System.Convert]::ToBoolean($SNMPEnabled)) -SNMPCommunity $SNMPCommunityName
                        } else {
                            Add-PrinterPort -Name $PortName -PrinterHostAddress $Address
                        }
                        
                    } # END default
                } # END switch
            } # end if PrinterPort
            if(!(Get-Printer -Name $Name -ErrorAction SilentlyContinue)){
                Add-Printer -Name $Name -PortName $PortName -DriverName $DriverName -Shared:([System.Convert]::ToBoolean($Shared))
                if($PermissionSDDL){
                    Set-Printer -Name $Name -PermissionSDDL $PermissionSDDL
                }
            }
        } else {
            if ($PortType -ne $currentValues.PortType){
                Write-Verbose -Message "PortType doesn't match desired state. Current value: $($currentValues.PortType) - Desired Value: $PortType"
                $tempPort = -join (1..9 | Get-Random -Count 5)

                if($currentValues.PortType -ne "Papercut" -and $PortType -eq "Papercut"){
                    Write-Verbose -Message "Converting port from a standard Port. Creating a temp port named $tempPort"
                    Add-PrinterPort -Name "$tempPort" -PrinterHostAddress "$Address"
                    Get-PrintJob -PrinterName $Name | Remove-PrintJob
                    Set-Printer -Name "$Name" -PortName "$tempPort"
                    Remove-PrinterPort -Name "$PortName" -ErrorAction SilentlyContinue
                    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v HostName /t REG_SZ /d $Address /f | Out-Null
                    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v PortNumber /t REG_DWORD /d 0x0000238c /f | Out-Null
                    Restart-Service -Name "Spooler" -Force
                    Set-Printer -Name "$Name" -PortName $PortName
                    Remove-PrinterPort -Name "$tempPort" -ErrorAction SilentlyContinue
                } elseif ($currentValues.PortType -eq "LPR" -and $PortType -eq "TCPIP"){
                    Write-Verbose -Message "Converting LPR port to TCPIP"
                    $wmiPrinterQuery = Get-WmiObject -Query "SELECT * FROM Win32_TCPIpPrinterPort WHERE Name='$PortName'"
                    $wmiPrinterQuery.Protocol=1
                    $wmiPrinterQuery.PortNumber=9100
                    $wmiPrinterQuery.put() | Out-Null
                } elseif ($currentValues.PortType -eq "TCPIP" -and $PortType -eq "LPR") {
                    Write-Verbose -Message "Converting LPR port to TCPIP"
                    $wmiPrinterQuery = Get-WmiObject -Query "SELECT * FROM Win32_TCPIpPrinterPort WHERE Name='$PortName'"
                    $wmiPrinterQuery.Protocol=2
                    $wmiPrinterQuery.Queue="$lprQueue"
                    $wmiPrinterQuery.put() | Out-Null
                } 
                elseif($currentValues.PortType -eq "Papercut" -and $PortType -ne "Papercut"){
                    REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /f | Out-Null
                    Restart-Service -Name "Spooler" -Force
                    Write-Verbose -Message "Converting port from a Papercut Port. Creating a temp port named $tempPort"
                    Add-PrinterPort -Name "$tempPort" -PrinterHostAddress "$Address"
                    Get-PrintJob -PrinterName $Name | Remove-PrintJob
                    Set-Printer -Name $Name -PortName "$tempPort"
                    Remove-PrinterPort -Name "$PortName" -ErrorAction SilentlyContinue
                    switch ($PortType) {
                        LPR {
                            if($SNMPEnabled){
                                Add-PrinterPort -Name $PortName -LprHostAddress $Address -LprQueueName $lprQueue -LprByteCounting:$true -SNMP:([System.Convert]::ToBoolean($SNMPEnabled)) -SNMPCommunity $SNMPCommunityName
                            } else {
                                Add-PrinterPort -Name $PortName -LprHostAddress $Address -LprQueueName $lprQueue -LprByteCounting:$true
                            }                        
                        }
                        default {
                            if($SNMPEnabled){
                                Add-PrinterPort -Name $PortName -PrinterHostAddress $Address -SNMP:([System.Convert]::ToBoolean($SNMPEnabled)) -SNMPCommunity $SNMPCommunityName
                            } else {
                                Add-PrinterPort -Name $PortName -PrinterHostAddress $Address
                            }
                        }
                    }
                    Write-Verbose -Message "Switching Port back to $Portname"
                    Set-Printer -Name "$Name" -PortName "$PortName"
                    Remove-PrinterPort -Name "$tempPort" -ErrorAction SilentlyContinue
                }
            }
            if ($Shared -ne $currentValues.Shared) { 
                Write-Verbose -Message "Printer shared status doesn't match desired state. Current value: $($currentValues.Shared) - Desired Value: $Shared"
                Set-Printer -Name $Name -Shared:([System.Convert]::ToBoolean($Shared))
            }
            if ($DriverName -ne $currentValues.DriverName) { 
                Write-Verbose -Message "DriverName doesn't match desired state. Current value: $($currentValues.DriverName) - Desired Value: $DriverName"
                Set-Printer -Name $Name -DriverName $DriverName
            }
            if ($PortName -ne $currentValues.PortName) { 
                Write-Verbose -Message "PortName doesn't match desired state. Current value: $($currentValues.PortName) - Desired Value: $PortName"
                Write-Verbose -Message "Changing port names, removing existing jobs"
                Get-PrintJob -PrinterName $Name | Remove-PrintJob
                Set-Printer -Name $Name -PortName $PortName
            }
            if ($Address -ne $currentValues.Address) { 
                Write-Verbose -Message "Address doesn't match desired state. Current value: $($currentValues.Address) - Desired Value: $Address"
                    switch ($PortType) {
                        Papercut {
                            REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v HostName /t REG_SZ /d $Address /f 
                        }
                        default {
                            $wmiPrinterQuery = Get-WmiObject -Query "SELECT * FROM Win32_TCPIpPrinterPort WHERE Name='$PortName'"
                            $wmiPrinterQuery.HostAddress=$Address
                            $wmiPrinterQuery.put() | Out-Null
                        }
                    }
            }
            if($PortType -ne "Papercut"){
                if ($lprQueue -ne $currentValues.lprQueue -and $currentValues.PortType -eq "LPR") { 
                    Write-Verbose -Message "Queue doesn't match desired state. Current value: $($currentValues.lprQueue) - Desired Value: $lprQueue"
                    $wmiPrinterQuery = Get-WmiObject -Query "SELECT * FROM Win32_TCPIpPrinterPort WHERE Name='$PortName'"
                    $wmiPrinterQuery.Queue="$lprQueue"
                    $wmiPrinterQuery.put() | Out-Null
                }
                if ($SNMPEnabled -ne $currentValues.SNMPEnabled -or $SNMPCommunityName -ne $currentValues.SNMPCommunityName -or $SNMPIndex -ne $currentValues.SNMPIndex) { 
                    Write-Verbose -Message "SNMPEnabled does not match desired state. Current value: $($currentValues.SNMPEnabled) - Desired Value: $SNMPEnabled"
                    $wmiPrinterQuery = Get-WmiObject -Query "SELECT * FROM Win32_TCPIpPrinterPort WHERE Name='$PortName'"
                    $wmiPrinterQuery.SNMPDevIndex=$SNMPIndex
                    $wmiPrinterQuery.SNMPCommunity=$SNMPCommunityName
                    $wmiPrinterQuery.SNMPEnabled =$SNMPEnabled
                    $wmiPrinterQuery.put() | Out-Null 
                }
            }
            if ($PermissionSDDL -ne $currentValues.PermissionSDDL) { 
                Write-Verbose -Message "Setting desired PermissionSDDL"
                Set-Printer -Name $Name -PermissionSDDL $PermissionSDDL
            }
        }
    } elseif ($Ensure -eq "Absent") {
        #need to remove any jobs in the queue 
        Get-PrintJob -PrinterName $Name | Remove-PrintJob
        if((Get-PrintJob -PrinterName $Name).Count -eq 0){
            Get-Printer -Name $Name | Remove-Printer
            Restart-Service -Name "Spooler" -Force
            Get-PrinterPort -Name $PortName | Remove-PrinterPort
        }

    }
}
function Test-TargetResource{
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("TCPIP","LPR","Papercut")]
        $PortType = "TCPIP",  
        
        [Parameter(Mandatory=$false)]
        [System.String]
        $lprQueue,

		[parameter(Mandatory = $true)]
		[System.String]
		$PortName,

		[parameter(Mandatory = $true)]
		[System.String]
		$Address,

		[parameter(Mandatory = $true)]
		[System.String]
		$DriverName,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $Shared,

        [Parameter(Mandatory=$false)]
        [System.Boolean]
        $SNMPEnabled = $true,

        [Parameter(Mandatory=$false)]
        [System.String]
        $SNMPCommunityName = "public",
    
        [Parameter(Mandatory=$false)]
        [System.Int16]
        $SNMPIndex = 1,

        [Parameter(Mandatory=$false)]
        [System.String]
        $PermissionSDDL
    )
    $currentValues = Get-TargetResource @PSBoundParameters
    switch ($Ensure)
    {
        'Absent'
        {
            if ( $currentValues.Ensure -eq 'Absent' ) {
                return $true 
            } else {
                return $false 
            }
        }
        'Present' {
            if($currentValues.Ensure -eq 'Absent'){
                Write-Verbose -Message "Ensure does not match desired state. Current value: $($currentValues.Ensure) - Desired Value: $Ensure"
                return $false
            }
            if($PortType -ne $currentValues.PortType){
                Write-Verbose -Message "PortType does not match desired state. Current value: $($currentValues.PortType) - Desired Value: $PortType"
                return $false 
            }
            if ($Portname -ne $currentValues.Portname) { 
                Write-Verbose -Message "Portname does not match desired state. Current value: $($currentValues.Portname) - Desired Value: $Portname"
                return $false 
            }
            if ($Address -ne $currentValues.Address) { 
                Write-Verbose -Message "Address does not match desired state. Current value: $($currentValues.Address) - Desired Value: $Address"
                return $false 
            }
            if ($DriverName -ne $currentValues.DriverName) { 
                Write-Verbose -Message "DriverName does not match desired state. Current value: $($currentValues.DriverName) - Desired Value: $DriverName"
                return $false 
            }
            if ($Shared -ne $currentValues.Shared) { 
                Write-Verbose -Message "Printer shared does not match desired state. Current value: $($currentValues.Shared) - Desired Value: $Shared"
                return $false 
            }
            if ($SNMPEnabled -ne $currentValues.SNMPEnabled -and $PortType -ne "Papercut") { 
                Write-Verbose -Message "SNMPEnabled does not match desired state. Current value: $($currentValues.SNMPEnabled) - Desired Value: $SNMPEnabled"
                return $false 
            } else {
                if ($SNMPCommunityName -ne $currentValues.SNMPCommunityName -and $PortType -ne "Papercut") { 
                    Write-Verbose -Message "SNMPCommunityName does not match desired state. Current value: $($currentValues.SNMPCommunityName) - Desired Value: $SNMPCommunityName"
                    return $false 
                }
                if ($SNMPIndex -ne $currentValues.SNMPIndex -and $PortType -ne "Papercut") { 
                    Write-Verbose -Message "SNMPIndex does not match desired state. Current value: $($currentValues.SNMPIndex) - Desired Value: $SNMPIndex"
                    return $false 
                }
            }
            if ($lprQueue -ne $currentValues.lprQueue -and $PortType -eq "LPR") { 
                Write-Verbose -Message "lprQueue does not match desired state. Current value: $($currentValues.lprQueue) - Desired Value: $lprQueue"
                return $false 
            }
            if ($PermissionSDDL -ne $currentValues.PermissionSDDL) { 
                Write-Verbose -Message "Permissions does not match desired state Current value: $($currentValues.PermissionSDDL) - Desired Value: $PermissionSDDL"
                return $false 
            }

            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource