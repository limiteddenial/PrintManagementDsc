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
    [System.String] $Address

    [DscProperty()]
    [System.String] $DriverName
    
    hidden $Messages = ""

    cPrinter(){
        $this.Messages = (Import-LocalizedData  -FileName cPrinterManagement.strings.psd1 -BaseDirectory (Split-Path -Parent (Split-Path -Parent $PSCOMMANDPATH)))
    }

    [void] Set(){
        $printer = Get-Printer -Name $this.Name -Full -ErrorAction SilentlyContinue
        $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction SilentlyContinue
        if($this.Ensure -eq [Ensure]::Present){
            if($null -eq $printerPort){
                Write-Verbose -Message "Creating new Printer Port"
                $PrinterPortParamaters = @{
                    Name = $this.PortName
                    PrinterHostAddress =  "local.test"
                }
                Add-PrinterPort @PrinterPortParamaters
            }
            if($null -eq $printer){
                $PrinterParamaters = @{
                    Name = $this.Name
                    PortName = $this.PortName
                    DriverName = $this.DriverName
                }
                Add-Printer @PrinterParamaters
            }
        } else {
            if($null -ne $printer){
                $PrinterParamaters = @{
                    Name = $this.Name
                }
                if($null -ne (Get-PrintJob -PrinterName $this.Name)) {
                    Get-PrintJob -PrinterName $this.Name | Remove-PrintJob
                }
                Remove-Printer @PrinterParamaters
            }
            if($null -ne $printerPort){
                try {
                    Remove-PrinterPort -Name $this.PortName
                } catch {
                    Restart-Service -Name Spooler -Force
                    Remove-PrinterPort -Name $this.PortName
                }
            }
        }
    }
    [bool] Test() {
        $printer = Get-Printer -Name $this.Name -Full -ErrorAction SilentlyContinue
        $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction SilentlyContinue
        if($this.Ensure -eq [Ensure]::Present){
            if($null -eq $printer){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Ensure","Absent",$this.Ensure)
                return $false
            }
            if($null -eq $printerPort){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PrinterPort","Absent",$this.Ensure)
                return $false
            }
            if($this.PortName -ne $printer.PortName){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PortName",$printer.PortName,$this.PortName)
                return $false
            }
            return $true
        } else {
            if($null -ne $printer){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "Ensure","Present",$this.Ensure)
                return $false
            }
            if($null -ne $printerPort){
                Write-Verbose -Message  ($this.Messages.NotInDesiredState -f "PrinterPort","Present",$this.Ensure)
                return $false
            }
            return $true
        }
    }
    [cPrinter] Get(){
        #Need to gather the printer information 
        $printer = Get-Printer -Name $this.Name -Full -ErrorAction SilentlyContinue
        #$printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction SilentlyContinue

        if($printer){
            $this.Name = $printer.Name
            $this.Ensure = [Ensure]::Present
        } else {
            $this.Ensure = [Ensure]::Absent
        }
        return $this
    }
}
