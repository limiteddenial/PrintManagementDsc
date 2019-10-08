<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 313aaa79-c93b-4241-af95-61d1eb899aa4
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
    Installs multiple print drivers from the same source inf file
#>
configuration PrinterDriver_AddMultipleDrivers_Config
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
        PrinterDriver XeroxGlobal
        {
            Ensure  = "Present"
            Name    = @(
                "Xerox Global Print Driver PCL6"
                "Xerox Global Print Driver PS"
            )
            Version = "1.2.3.4"
            Source  = "C:\Drivers\Xerox\x2UNiVX.inf"
        } # End PrinterDriver
    } # End Node
} # End Configuration
