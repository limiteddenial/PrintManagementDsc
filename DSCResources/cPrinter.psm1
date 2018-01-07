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
class cPrinter {
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
    [System.Int16] $SNMPIndex = 1

    [DscProperty()]
    [System.String] $lprQueueName

    hidden $Messages = ""

    cPrinter(){
        $this.Messages = (Import-LocalizedData  -FileName 'cPrinterManagement.strings.psd1' -BaseDirectory (Split-Path -Parent (Split-Path -Parent $PSCOMMANDPATH)))
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
            [bool]$newPrinter, [bool]$newPrinterPort = $false
            # We need to create the port before we can create the printer
            if($null -eq $printerPort){
                Write-Verbose -Message ($this.Messages.NewPrinterPort -f $this.PortType,$this.PortNamee)
                switch ($this.PortType) {
                    'PaperCut' {
                        #TODO
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
                }
                if($null -ne $this.PermissionSDDL -and $printer.PermissionSDDL -ne $this.PermissionSDDL){
                    $UpdatePrinterParamaters.PermissionSDDL = $this.PermissionSDDL
                    Write-Verbose -Message ($this.Messages.UpdatedDesiredState -f 'PermissionSDDL',$this.PermissionSDDL,$printer.PermissionSDDL)
                }
                if($UpdatePrinterParamaters.count -gt 1){
                    Set-Printer @UpdatePrinterParamaters
                }
            } # End If NewPrinter

            # If the printerPort already existed the settings need to be checked. Otherwise the printer was just created with specified settings
            if ($newPrinterPort -eq $false) {

            } #End If NewPrinterPort
        } else {
            if($null -ne $printer){
                $PrinterParamaters = @{
                    Name = $this.Name
                }
                if($null -ne (Get-PrintJob -PrinterName $this.Name)) {
                    Get-PrintJob -PrinterName $this.Name | Remove-PrintJob
                }
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
        try {
            $printer = Get-Printer -Name $this.Name -Full
        } catch {
            $printer = $null
        }
        try {
            $printerPort = Get-PrinterPort -Name $this.PortName
        } catch {
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
                    if($this.SNMPEnabled -ne $printerPort.SNMPEnabled){
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
            if ($null -ne $this.DriverName -and $this.DriverName -ne $printer.DriverName) {
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "DriverName",$printer.DriverName,$this.DriverName)
                return $false
            } # End DriverName
            if ($null -ne $this.PermissionSDDL -and $this.PermissionSDDL -ne $printer.PermissionSDDL) {
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PermissionSDDL",$printer.PermissionSDDL,$this.PermissionSDDL)
                return $false
            } # End PermissionSDDL
            if($this.Shared.GetType().Name -eq 'Boolean' -and $this.Shared -ne $printer.Shared){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Shared",$printer.Shared,$this.Shared)
                return $false
            } # End Shared
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
    [cPrinter] Get(){ 
        $ReturnObject = [cPrinter]::new()
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
} # End Class
