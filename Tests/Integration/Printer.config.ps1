$TestPrinterLPR = [PSObject]@{
    Ensure       = 'Present'
    Name         = 'IntegrationLPR'
    PortType     = 'LPR'
    PortName     = 'IntegrationLPRPort'
    Address      = 'Test.local'
    DriverName   = 'Microsoft XPS Document Writer v4'
    LprQueueName = 'dummyQueue'
    Shared       = $false
}

$TestPrinterTCPIP = [PSObject]@{
    Ensure         = 'Present'
    Name           = 'IntegrationTCPIP'
    PortType       = 'TCPIP'
    PortName       = 'IntegrationTCPIPPort'
    Address        = 'Test.local'
    DriverName     = 'Microsoft XPS Document Writer v4'
    Shared         = $true
    SNMPIndex      = 1
    SNMPCommunity  = 'public'
    PermissionSDDL = 'G:SYD:(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)'
}

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
    }
}