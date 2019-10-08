<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 8ce048ce-e8ec-427d-ad91-a4b695409cac
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
    Installs a print driver
#>
configuration PrinterDriver_AddDriver_Config
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
            Name    = "Xerox Global Print Driver PCL6"
            Version = "1.2.3.4"
            Source  = "C:\Drivers\Xerox\x2UNiVX.inf"
        } # End PrinterDriver
    } # End Node
} # End Configuration
