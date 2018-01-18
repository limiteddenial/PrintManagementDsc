<#
    .SYNOPSIS
        Example to set a printer. 
    .DESCRIPTION
        This examples sets 3 different printers. One using LPR port, the other using the raw port, and the last one using a Papercut port. 
#>
Configuration Sample_cPrinter {

    Import-DSCResource -ModuleName cPrinterManagement

    Node $AllNodes.NodeName {
        foreach ($printer in $node.Printers){
            cPrinter $printer.PrinterName {
                Ensure = $printer.Ensure
                Name = $printer.Name
                PortType = $printer.PortType
                PortName = $printer.PortName
                Address = $printer.Address
                DriverName = $printer.DriverName
                LprQueue = $printer.Queue
                Shared = $printer.Shared
                SNMPEnabled = $printer.SNMPEnabled
                SNMPCommunityName = $printer.SNMPCommunityName
                SNMPIndex = $printer.SNMPIndex
            }
        }
    }
}
$ConfigData = @{ 
    AllNodes = @( 
        @{
            NodeName = "*"
            Printers = @(
                @{
                    Ensure = "Present"
                    Name = "lprPrint"
                    PortType = "LPR"
                    PortName = "lprPrint"
                    Address = "lprPrint.local"
                    DriverName = "Xerox Global Print Driver PCL6"
                    Queue = "xerox"
                    Shared = $true
                    SNMPEnabled = $true
                }, @{
                    Ensure = "Present"
                    Name = "tcpPrint"
                    PortType = "TCPIP"
                    PortName = "tcpPrint"
                    Address = "tcpPrint.local"
                    DriverName = "Xerox Global Print Driver PCL6"
                    Shared = $true
                    SNMPEnabled = $true
                },@{
                    Ensure = "Present"
                    Name = "PapercutPrint"
                    PortType = "Papercut"
                    PortName = "PapercutPrint"
                    Address = "PapercutPrint"
                    DriverName = "Xerox Global Print Driver PCL6"
                    Shared = $true
                }
            )
        }
    )
}
Sample_cPrinter -ConfigurationData $ConfigData
Start-DscConfiguration -Path Sample_cPrinter -Wait -Verbose -Force
