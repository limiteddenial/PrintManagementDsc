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
    

    [void] Set(){
        $printer = Get-Printer -Name $this.Name -Full -ErrorAction SilentlyContinue
        $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction SilentlyContinue
        if($this.Ensure -eq [Ensure]::Present){
            if($null -eq $printerPort){
                Write-Verbose -Message "Creating new Printer Port"
                $PrinterPortParamaters = @{
                    Name = $this.PortName
                }
                Add-PrinterPort @PrinterPortParamaters
            }
            if($null -eq $printer){
                $PrinterParamaters = @{
                    Name = $this.Name
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
                $PrinterPortParamaters = @{
                    Name = $this.PortName
                }
            }
        }
    }
    [bool] Test() {
        $printer = Get-Printer -Name $this.Name -Full -ErrorAction SilentlyContinue
        $printerPort = Get-PrinterPort -Name $this.PortName -ErrorAction SilentlyContinue
        if($this.Ensure -eq [Ensure]::Present){
            if($null -eq $printer){
                Write-Verbose -Message  "Ensure does not match desired state. Current value: Absent - Desired Value: $($this.Ensure)"
                return $false
            }
            if($null -eq $printerPort){
                Write-Verbose -Message "PrinterPort does not match desired state. Current value: Absent - Desired Value: $($this.Ensure)"
                return $false
            }
            if($this.PortName -ne $printer.PortName){
                Write-Verbose -Message "Ensure does not match desired state. Current value: $($printer.PortName) - Desired Value: $($this.PortName)"
                return $false
            }
            return $true
        } else {
            if($null -ne $printer){
                Write-Verbose -Message "Ensure does not match desired state. Current value: Present - Desired Value: $this.Ensure"
                return $false
            }
            if($null -ne $printerPort){
                Write-Verbose -Message "PrinterPort does not match desired state. Current value: Present - Desired Value: $($this.Ensure)"
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
