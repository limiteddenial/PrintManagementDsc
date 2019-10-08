<#PSScriptInfo
.VERSION 2.0.0.0
.GUID e63dab79-d613-4975-92d2-4d1283fa852e
.AUTHOR Eric Boersma
.TAGS DSCConfiguration
.LICENSEURI https://github.com/limiteddenial/PrintManagementDsc/blob/master/LICENSE
.PROJECTURI https://github.com/limiteddenial/PrintManagementDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-DataCenter,2016-DataCenter-Server-Core
#>

#Requires -Module PrintManagementDsc

<#
    .DESCRIPTION
    Adds a printer using TCPIP for communication
#>
configuration Printer_AddTCPIPPrinter_Config
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
