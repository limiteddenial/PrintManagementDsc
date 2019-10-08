<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 29a5af75-b176-4b70-8872-7d557f5fc1ee
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

<#
    .DESCRIPTION
    Adds a printer using LPR for communication
#>
configuration Printer_AddLPRPrinter_Config
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
        Printer NewLPRPrinter {
            Ensure       = 'Present'
            Name         = 'ExampleLPRPrinter'
            PortType     = 'LPR'
            PortName     = 'ExamplePort'
            Address      = 'Example.local'
            DriverName   = 'fake'
            LprQueueName = 'testQueue'
            Shared       = $false
        } # End Printer
    } # End Node
} # End Configuration
