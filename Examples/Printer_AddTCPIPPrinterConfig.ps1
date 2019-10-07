<#PSScriptInfo
.VERSION 2.0.0.0
.GUID e63dab79-d613-4975-92d2-4d1283fa852e
#>

<#
    .DESCRIPTION
        Adds a printer using TCPIP for communication
#>
configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    node $NodeName
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
