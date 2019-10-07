<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 8ce048ce-e8ec-427d-ad91-a4b695409cac
#>

<#
    .DESCRIPTION
        Installs a print driver
#>
configuration Example {
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
