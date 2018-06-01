enum Ensure {
    Absent
    Present
}
enum PortType {
    TCPIP
    LPR
    PaperCut
}
[DscResource()]
class Printer {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure
    
    [DscProperty(Key)] 
    [System.String]$Name

    [DscProperty(Mandatory)]
    [System.String] $PortName

    [DscProperty()]
    [PortType] $PortType = [PortType]::TCPIP

    [DscProperty(Mandatory)]
    [System.String] $Address

    [DscProperty(Mandatory)]
    [System.String] $DriverName

    [DscProperty()]
    [System.Boolean] $Shared = $true

    [DscProperty()]
    [System.String] $PermissionSDDL
    
    [DscProperty()]
    [System.Boolean] $SNMPEnabled = $true

    [DscProperty()]
    [System.String] $SNMPCommunity = 'public'

    [DscProperty()]
    [System.UInt32] $SNMPIndex = 1

    [DscProperty()]
    [System.String] $lprQueueName

    hidden $Messages = ""

    Printer(){
        $this.Messages = Get-LocalizedData `
            -ResourceName 'Printer' `
            -ResourcePath (Split-Path -Parent $PSCOMMANDPATH)
    }

    [void] Set(){
        try {
            $printer = Get-Printer -Name $this.Name -Full -ErrorAction Stop
        } catch {
            Write-Verbose -Message ($this.Messages.PrinterDoesNotExist -f $this.Name)
            $printer = $null
        } 
        try {
            $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction Stop
        } catch {
            Write-Verbose -Message ($this.Messages.PrinterPortDoesNotExist -f $this.PortName)
            $printerPort = $null
        }
        if($this.Ensure -eq [Ensure]::Present){
            # Creating variables to determine if new a new printer or printerPort was just created. 
            # Doing this to bypass excess setting checks as the settings would already set correctly
            [bool]$newPrinter = $false
            [bool]$newPrinterPort = $false
            # We need to create the port before we can create the printer
            if($null -eq $printerPort){
                Write-Verbose -Message ($this.Messages.NewPrinterPort -f $this.PortType,$this.PortNamee)
                switch ($this.PortType) {
                    'PaperCut' {
                        $this.CreatePaperCutPort()
                    } # End PaperCut
                    'LPR' {
                        $PrinterPortParamaters = @{
                            Name = $this.PortName
                            LprHostAddress =  $this.Address
                            LprQueueName = $this.lprQueueName
                            LprByteCounting = $true
                        }
                        if($this.SNMPEnabled -eq $true) {
                            $PrinterPortParamaters.SNMP = $this.SNMPEnabled
                            $PrinterPortParamaters.SNMPCommunity = $this.SNMPCommunity
                            $PrinterPortParamaters.SNMPIndex = $this.SNMPIndex
                        }
                        Add-PrinterPort @PrinterPortParamaters
                    } # End LPR
                    Default {
                        # Default is as Standard TCPIP Port
                        $PrinterPortParamaters = @{
                            Name = $this.PortName
                            PrinterHostAddress =  $this.Address 
                        }
                        if($this.SNMPEnabled -eq $true) {
                            $PrinterPortParamaters.SNMP = $this.SNMPEnabled
                            $PrinterPortParamaters.SNMPCommunity = $this.SNMPCommunity
                            $PrinterPortParamaters.SNMPIndex = $this.SNMPIndex
                        }
                        Add-PrinterPort @PrinterPortParamaters
                    } # End Default
                } # End Switch PortType
                $newPrinterPort = $true
            } # End If PrinterPort
            if($null -eq $printer){
                if($false -eq [bool](Get-PrinterDriver -Name $this.DriverName -ErrorAction SilentlyContinue )){
                    Write-Error -Message ($this.Messages.PrinterNoDriver -f $this.DriverName,$this.Name) -Exception 'ObjectNotFound' -Category "ObjectNotFound"
                    return
                }
                $PrinterParamaters = @{
                    Name = $this.Name
                    PortName = $this.PortName
                    DriverName = $this.DriverName
                }
                if($null -ne $this.PermissionSDDL){
                    $PrinterParamaters.PermissionSDDL = $this.PermissionSDDL
                } # End If PermissionSDDL
                if($null -ne $this.Shared){
                    $PrinterParamaters.Shared = $this.Shared
                }
                Add-Printer @PrinterParamaters
                $newPrinter = $true
            } # End If Printer

            # If the printer already existed the settings need to be checked. Otherwise the printer was just created with specified settings
            if($newPrinter -eq $false) {
                $UpdatePrinterParamaters = @{
                    Name = $this.Name
                    # This will get populated if any settings are not correct
                }
                if($printer.DriverName -ne $this.DriverName) {
                    # Need to check if the driver exists before attempting to set the printer to use it
                    if($false -eq [bool](Get-PrinterDriver -Name $this.DriverName -ErrorAction SilentlyContinue )){
                        Write-Error -Message ($this.Messages.PrinterNoDriver -f $this.DriverName,$this.Name) -Exception 'ObjectNotFound' -Category "ObjectNotFound"
                        return
                    } # End If Print Driver
                    # Updating variable to notify that the driver needs to be updated
                    $UpdatePrinterParamaters.DriverName = $this.DriverName
                    Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f 'DriverName',$this.DriverName,$printer.DriverName)
                } # End If DriverName
                if($printer.Shared -ne $this.Shared) {
                    $UpdatePrinterParamaters.Shared = $this.Shared
                    Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f 'Shared',$this.Shared,$printer.Shared)
                } # End If Shared
                if($null -ne $this.PermissionSDDL -and $printer.PermissionSDDL -ne $this.PermissionSDDL){
                    $UpdatePrinterParamaters.PermissionSDDL = $this.PermissionSDDL
                    Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f 'PermissionSDDL',$this.PermissionSDDL,$printer.PermissionSDDL)
                } # End If PermissionSDDL
                if($printer.PortName -ne $this.PortName){
                    $UpdatePrinterParamaters.PortName = $this.PortName
                    Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f 'PortName',$this.PortName,$printer.PortName)
                    # To make changes we need to make sure there are no jobs queued up on the printer
                    Get-PrintJob -PrinterName $this.Name | Remove-PrintJob
                } # End If PrinterPort
                if($UpdatePrinterParamaters.count -gt 1){
                    Set-Printer @UpdatePrinterParamaters
                } # End If UpdatePrinterParamaters
            } # End If NewPrinter

            # If the printerPort already existed the settings need to be checked. Otherwise the printer was just created with specified settings
            if ($newPrinterPort -eq $false) {
                $currentPortType = [PortType]$this.FindPortType()
                if($currentPortType -ne $this.PortType){
                    Write-Verbose -Message ($this.Messages.NotInDesiredState -f "PortType",$currentPortType,$this.PortType)
                    # If there are any printjobs queued on the printer it will cause issues changing the porttype so we will remove the print jobs
                    Get-PrintJob -PrinterName $this.Name | Remove-PrintJob
                    switch ($currentPortType){
                        'PaperCut' {
                            $tempPort = $this.UseTempPort()
                            # Lets remove the Papercut Port
                            Remove-Item ("HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP$([char]0x002f)IP Port\Ports\{0}" -f $this.PortName)
                            # To take effect the spooler needs to be rebooted
                            Restart-Service -Name "Spooler" -Force
                            $newPrinterPortParamaters = @{
                                Name = $this.PortName
                            }
                            if($this.SNMPEnabled -eq $true) {
                                $newPrinterPortParamaters.SNMP = $this.SNMPEnabled
                                $newPrinterPortParamaters.SNMPCommunity = $this.SNMPCommunity
                                $newPrinterPortParamaters.SNMPIndex = $this.SNMPIndex
                            }
                            switch ($this.PortType) {
                                'LPR' {
                                    $newPrinterPortParamaters.LprHostAddress =  $this.Address
                                    $newPrinterPortParamaters.LprQueueName = $this.lprQueueName
                                    $newPrinterPortParamaters.LprByteCounting = $true
                                } # End LPR
                                'TCPIP' {
                                    $newPrinterPortParamaters.PrinterHostAddress =  $this.Address 
                                } # End TCPIP
                            } # End Switch this.PortType
                            Add-PrinterPort @newPrinterPortParamaters
                            $updatePrinterParamaters = @{
                                Name = $this.Name
                                PortName = $this.PortName
                            }
                            # Changing the printer to use the new port
                            Set-Printer @updatePrinterParamaters
                            # To clean up we will remove the temp printer port
                            Remove-PrinterPort -Name $tempPort
                        } # End Papercut
                        'LPR' {
                            switch ($this.PortType) {
                                'TCPIP' {
                                    $UpdatePortParamaters = @{
                                        Protocol = 1
                                        PortNumber = 9100
                                    }
                                    # Need to Use WMI as CIM has the objects as read only
                                    Get-WmiObject -Query ("Select * FROM Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $this.PortName ) | Set-WmiInstance -Arguments $UpdatePortParamaters -PutType UpdateOnly | Out-Null
                                } # End TCPIP
                                'PaperCut' {
                                    $tempPort = $this.UseTempPort()
                                    Remove-PrinterPort -Name $this.PortName
                                    $this.CreatePaperCutPort()
                                    $updatePrinterParamaters = @{
                                        Name = $this.Name
                                        PortName = $this.PortName
                                    }  
                                    Set-Printer @updatePrinterParamaters
                                    # To clean up we will remove the temp printer port
                                    Remove-PrinterPort -Name $tempPort
                                } # End PaperCut
                            } # End Switch this.PortType
                        } # End LPR
                        'TCPIP' {
                            switch ($this.PortType) {
                                'LPR' {
                                    $UpdatePortParamaters = @{
                                        Protocol = 2
                                        Queue = $this.lprQueueName
                                    }
                                    # Need to Use WMI as CIM has the objects as read only
                                    Get-WmiObject -Query ("Select * FROM Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $this.PortName ) | Set-WmiInstance -Arguments $UpdatePortParamaters -PutType UpdateOnly | Out-Null
                                } # End LPR
                                'PaperCut' {
                                    $tempPort = $this.UseTempPort()
                                    Remove-PrinterPort -Name $this.PortName
                                    $this.CreatePaperCutPort()
                                    $updatePrinterParamaters = @{
                                        Name = $this.Name
                                        PortName = $this.PortName
                                    }  
                                    Set-Printer @updatePrinterParamaters
                                    # To clean up we will remove the temp printer port
                                    Remove-PrinterPort -Name $tempPort
                                } # End PaperCut
                            } # End Switch this.PortType
                        } # End TCPIP
                    } # End Switch currentPortType
                    # The ports were converted the setting will be in the desired state.
                    return
                } # End If not CurrentPortType 
                switch ($currentPortType){
                    'PaperCut' {
                        try {
                            #To get Papercut address you need to look at the registry key
                            $currentAddress = (Get-Item ("HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\{0}" -f $this.PortName) | Get-ItemProperty).HostName                    
                        } catch {
                            $currentAddress = $null
                        } # End try/catch CurrentAddress
                        if($this.Address -ne $currentAddress) {
                            Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f "Address",$this.Address,$currentAddress)
                            $this.CreatePaperCutPort() #This will just update the registry keys
                        } # End Address
                    } # End PaperCut
                    Default {
                        $newPrinterPortParamaters =@{
                            Name = $this.PortName
                        } # End newPrinterPortParamaters
                        if($currentPortType -eq 'LPR' -and $printerPort.lprQueueName -ne $this.lprQueueName){
                            Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f "lprQueueName",$this.lprQueueName,$printerPort.lprQueueName)
                            $newPrinterPortParamaters.lprQueueName = $this.lprQueueName
                        } # End If LprQueuename
                        if($this.Address -ne $printerPort.PrinterHostAddress) {
                            Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f "Address",$this.Address,$printerPort.PrinterHostAddress)
                            $newPrinterPortParamaters.PrinterHostAddress = $this.Address
                        } # End If Address
                        if($this.SNMPEnabled -ne $printerPort.SNMPEnabled){
                            Write-Verbose -Message  ($this.Messages.UpdatedDesiredState -f "SNMPEnabled",$this.SNMPEnabled,$printerPort.SNMPEnabled)
                            $newPrinterPortParamaters.SNMPEnabled = $this.SNMPEnabled
                        } # End If SNMPEnabled
                        if($this.SNMPEnabled -eq $true){ 
                            if($this.SNMPCommunity -ne $printerPort.SNMPCommunity){
                                Write-Verbose -Message  ($this.Messages.UpdatedDesiredState -f "SNMPCommunity",$this.SNMPCommunity,$printerPort.SNMPCommunity)
                                $newPrinterPortParamaters.SNMPCommunity = $this.SNMPCommunity
                            } # End If SNMPCommunity
                            if($this.SNMPIndex -ne $printerPort.SNMPIndex){
                                Write-Verbose -Message  ($this.Messages.UpdatedDesiredState -f "SNMPIndex",$this.SNMPIndex,$printerPort.SNMPIndex)
                                $newPrinterPortParamaters.SNMPDevIndex = $this.SNMPIndex
                            } # End If SNMPIndex
                        } # End If SNMPEnabled True
                        # If newPrinterPortParamaters has more items than just Name the port needs to be updated with new settings
                        if($newPrinterPortParamaters.count -gt 1){
                            Get-WmiObject -Query ("Select * FROM Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $this.PortName ) | Set-WmiInstance -Arguments $newPrinterPortParamaters -PutType UpdateOnly | Out-Null
                        } # End If newPrinterPortParamaters.Count
                    } # End Default
                } # End Switch $currentPortType
            } # End If not NewPrinterPort
        } else {
            if($null -ne $printer){
                $PrinterParamaters = @{
                    Name = $this.Name
                }
                Get-PrintJob -PrinterName $this.Name | Remove-PrintJob
                Remove-Printer @PrinterParamaters
            } # End If Printer
            if($null -ne $printerPort){
                try {
                    Remove-PrinterPort -Name $this.PortName
                } catch {
                    Restart-Service -Name Spooler -Force
                    Remove-PrinterPort -Name $this.PortName
                }
            } # End If PrinterPort
        } # End Else absent
    } # End Set()
    [bool] Test() {
        try 
        {
            $printer = Get-Printer -Name $this.Name -Full -ErrorAction Stop
        } 
        catch 
        {
            Write-Verbose -Message ($this.Messages.PrinterDoesNotExist -f $this.Name)
            $printer = $null
        } 
        try 
        {
            $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction Stop
        } 
        catch 
        {
            Write-Verbose -Message ($this.Messages.PrinterPortDoesNotExist -f $this.PortName)
            $printerPort = $null
        }
        if($this.Ensure -eq [Ensure]::Present){
            # region test current printer settings
            if($null -eq $printer){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Ensure","Absent",$this.Ensure)
                return $false
            } # End Printer
            if($null -eq $printerPort){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PrinterPort","Absent",$this.Ensure)
                return $false
            } # End PrinterPort
            if ($this.DriverName -ne $printer.DriverName) {
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "DriverName",$printer.DriverName,$this.DriverName)
                return $false
            } # End DriverName
            if ($null -ne $this.PermissionSDDL -and $this.PermissionSDDL -ne $printer.PermissionSDDL) {
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PermissionSDDL",$printer.PermissionSDDL,$this.PermissionSDDL)
                return $false
            } # End PermissionSDDL
            if($this.Shared -ne [System.Convert]::ToBoolean($printer.Shared)){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Shared",$printer.Shared,$this.Shared)
                return $false
            } # End Shared
            if($this.PortName -ne $printer.PortName){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PortName",$printer.PortName,$this.PortName)
                return $false
            } # End PortName
            
            switch ($printerPort.Description) {
                "PaperCut TCP/IP Port" {  
                    try {
                        #To get Papercut address you need to look at the registry key
                        $currentAddress = (Get-Item ("HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\{0}" -f $this.PortName) | Get-ItemProperty).HostName                    
                    } catch {
                        $currentAddress = $null
                    }
                    if($this.Address -ne $currentAddress) {
                        Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Address",$currentAddress,$this.Address)
                        return $false
                    } # End Address
                } # End PaperCut TCP/IP Port
                Default {
                    if($this.Address -ne $printerPort.PrinterHostAddress){
                        Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Address",$printerPort.PrinterHostAddress,$this.Address)
                        return $false
                    } # End Address
                    if($this.SNMPEnabled -ne [System.Convert]::ToBoolean($printerPort.SNMPEnabled)){
                        Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "SNMPEnabled",$printer.SNMPEnabled,$this.SNMPEnabled)
                        return $false
                    } # End SNMPEnabled
                    if($this.SNMPEnabled -eq $true){ 
                        if($this.SNMPCommunity -ne $printerPort.SNMPCommunity){
                            Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "SNMPCommunity",$printer.SNMPCommunity,$this.SNMPCommunity)
                            return $false
                        } # End SNMPCommunity
                        if($this.SNMPIndex -ne $printerPort.SNMPIndex){
                            Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "SNMPIndex",$printer.SNMPIndex,$this.SNMPIndex)
                            return $false
                        } # End SNMPIndex
                    } # End SNMPEnabled True
                    if($this.lprQueueName -ne $printerPort.lprQueueName){
                        Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "lprQueueName",$printer.lprQueueName,$this.lprQueueName)
                        return $false
                    } # End lprQueueName
                } # End Default
            } # End Switch
            # All the conditions have been met so we will return true so the set() method doesn't get called as everyting is in a desired state. 
            return $true
        } else {
            if($null -ne $printer){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Ensure","Present",$this.Ensure)
                return $false
            } # End Printer
            if($null -ne $printerPort){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PrinterPort","Present",$this.Ensure)
                return $false
            } # End PrinterPort
            return $true
        } # End Ensure
    } # End Test()
    [Printer] Get(){ 
        $ReturnObject = [Printer]::new()
        # Gathering the printer properties
        try {
            $printer = Get-Printer -Name $this.Name -Full -ErrorAction Stop
        } catch {
            $ReturnObject.Ensure = [Ensure]::Absent
            return $ReturnObject
        } 
        try {
            $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction Stop
        } catch {
            $ReturnObject.Ensure = [Ensure]::Absent
            return $ReturnObject
        } 
        # Both the printer and the printer port were found so we are going to set Ensure to Present
        $ReturnObject.Ensure = [Ensure]::Present
        if($null -ne $printer){ 
            $ReturnObject.Name = $printer.Name
            $ReturnObject.DriverName = $printer.DriverName
            $ReturnObject.Shared = $printer.Shared
            $ReturnObject.PermissionSDDL = $printer.PermissionSDDL
        } # End Printer
        if($null -ne $printerPort){
            $ReturnObject.PortName = $printerPort.Name
            switch ($printerPort.Description) {
                "PaperCut TCP/IP Port" {  
                    try {
                        #To get Papercut address you need to look at the registry key
                        $ReturnObject.Address = (Get-Item ("HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\{0}" -f $this.PortName) | Get-ItemProperty).HostName                    
                    } catch {
                        $ReturnObject.Address = $null
                    }
                    #SNMP is disabled on papercut ports
                    $ReturnObject.SNMPEnabled = $false
                    $ReturnObject.SNMPCommunity = $null
                    $ReturnObject.SNMPIndex = $null
                    $ReturnObject.PortType = [PortType]::PaperCut
                } # End PaperCut TCP/IP Port
                Default {
                    $ReturnObject.Address = $printerPort.PrinterHostAddress
                    $ReturnObject.SNMPEnabled = $printerPort.SNMPEnabled
                    $ReturnObject.SNMPCommunity = $printerPort.SNMPCommunity
                    $ReturnObject.SNMPIndex = $printerPort.SNMPIndex
                    $ReturnObject.PortType = [PortType]::TCPIP
                    if($printerPort.lprQueueName){
                        $ReturnObject.lprQueueName = $printerPort.lprQueueName
                        $ReturnObject.PortType = [PortType]::LPR
                    } 
                } # End Default
            } # End Switch
        } # End PrinterPort
        return $ReturnObject
    } # End GET()
    hidden [void] CreatePaperCutPort() {
        # To create the PaperCut port we need to create a registry key however we can't use new-item due to 'PaperCut TCP/IP Port' the cmdlet switches / to a \. 
        # Using the 'PaperCut TCP$([char]0x002f)IP Port' does not work. So we are just using reg.exe to add the key
        # Wrapping the Reg.exe commands in invoke-command to be able to create tests
        Invoke-Command -ScriptBlock { 
            param(
                [Parameter()]$PortName,
                [Parameter()]$Address
            )
            $System32Path = (Join-Path -Path (Get-Item ENV:\windir).value -ChildPath 'System32') 
            & "$system32Path\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v HostName /t REG_SZ /d $Address /f | Out-Null
            # Sets the port number to 9100
            & "$system32Path\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\$PortName" /v PortNumber /t REG_DWORD /d 0x0000238c /f | Out-Null          
        } -ArgumentList ($this.PortName,$this.Address)
        # Need to restart the spooler service before the port is usable
        Restart-Service -Name 'Spooler' -Force
    } # End CreatePaperCutPort()
    hidden [System.String] FindPortType() {
        # Gathering the port information
        $getPortInformation = Get-CimInstance -Query ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $this.PortName) 

        switch ($getPortInformation.Protocol) {
            1 { # TCPIP  
                return [PortType]::TCPIP
            } # End 1
            2 { # LPR
                return [PortType]::LPR
            } # End 2
        } # End Switch
        if($getPortInformation.Description -eq "PaperCut TCP/IP Port"){
            return [PortType]::PaperCut
        } # End If Description
        return $null
    } # End FindPortType()
    hidden [System.String] UseTempPort() {
        # We required removing the exising port so a temp port needs to be created
        # We do a while loop to make sure the port name doesn't already exist
        $tempPortName = -join (1..9 | Get-Random -Count 5)
        while($null -ne (Get-CimInstance -Query ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $tempPortName)) ){
            # We need to generate a new portname and then restart the 
            $tempPortName = -join (1..9 | Get-Random -Count 5)
        }
        $tempPrinterPortParamaters = @{
            Name = $tempPortName
            PrinterHostAddress =  $this.Address 
        } # End PrinterPortParamaters
        Add-PrinterPort @tempPrinterPortParamaters
        # We are updating the printer to use the new port while we convert the port to the desired type
        $tempPrinterParamaters = @{
            Name = $this.Name
            PortName = $tempPortName
        }
        Set-Printer @tempPrinterParamaters
        return $tempPortName
    } # End UseTempPort()
} # End Class
