$TestPrinterLPR = [PSObject]@{
    Ensure = 'Present'
    Name = 'IntegrationLPR'
    PortType = 'LPR'
    PortName = 'IntegrationLPRPort'
    Address = 'Test.local'
    DriverName = ''
    LprQueueName = 'dummyQueue'
    Shared = $false
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
            Ensure = Pr
            Name = $TestPrinterLPR.Name
            PortType = $TestPrinterLPR.PortType
            PortName = $TestPrinterLPR.PortName
            Address = $TestPrinterLPR.Address
            DriverName = $TestPrinterLPR.DriverName
            LprQueueName = $TestPrinterLPR.Queue
            Shared = $TestPrinterLPR.Shared
        }
    }
}