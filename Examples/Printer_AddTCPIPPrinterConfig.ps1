<#
    .DESCRIPTION
        Adds a printer using TCPIP for communication
#>
Configuration Example
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
        Printer NewTCPIPPrinter {
            Ensure     = 'Present'
            Name       = 'ExampleTCPIPPrinter'
            PortType   = 'TCPIP'
            PortName   = 'ExampleTCPIPPort'
            Address    = 'tcpip.local'
            DriverName = 'fake'
            Shared     = $true
        } # End Printer

    } # End Node
} # End Configuration
