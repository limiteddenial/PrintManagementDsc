$TestPrinterLPR = [PSObject]@{
    Ensure       = 'Present'
    Name         = 'IntegrationLPR'
    PortType     = 'LPR'
    PortName     = 'IntegrationLPRPort'
    Address      = 'Test.local'
    DriverName   = 'Generic / Text Only'
    LprQueueName = 'dummyQueue'
    Shared       = $false
}

$TestPrinterTCPIP = [PSObject]@{
    Ensure         = 'Present'
    Name           = 'IntegrationTCPIP'
    PortType       = 'TCPIP'
    PortName       = 'IntegrationTCPIPPort'
    Address        = 'Test.local'
    DriverName     = 'Generic / Text Only'
    Shared         = $true
    SNMPIndex      = 1
    SNMPCommunity  = 'public'
    PermissionSDDL = 'G:SYD:(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)'
}
[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\PrintManagementDsc'

Configuration Printer_Config
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    Node $NodeName
    {
        PrinterDriver Integration_Driver {
            Ensure  = 'Present'
            Name    = 'Generic / Text Only'
            Version = '6.1.7600.16385'
            Source  = "$script:moduleRoot\IntegrationDriver\prnge001.inf"
        } # End PrinterDriver

        Printer TCPIP-Printer {
            Ensure         = $TestPrinterTCPIP.Ensure
            Name           = $TestPrinterTCPIP.Name
            PortType       = $TestPrinterTCPIP.PortType
            PortName       = $TestPrinterTCPIP.PortName
            Address        = $TestPrinterTCPIP.Address
            DriverName     = $TestPrinterTCPIP.DriverName
            Shared         = $TestPrinterTCPIP.Shared
            SNMPCommunity  = $TestPrinterTCPIP.SNMPCommunity
            SNMPIndex      = $TestPrinterTCPIP.SNMPIndex
            PermissionSDDL = $TestPrinterTCPIP.PermissionSDDL
        }

        Printer LPRPrinter {
            Ensure       = $TestPrinterLPR.Ensure
            Name         = $TestPrinterLPR.Name
            PortType     = $TestPrinterLPR.PortType
            PortName     = $TestPrinterLPR.PortName
            Address      = $TestPrinterLPR.Address
            DriverName   = $TestPrinterLPR.DriverName
            LprQueueName = $TestPrinterLPR.LprQueueName
            Shared       = $TestPrinterLPR.Shared
        }
    }
}