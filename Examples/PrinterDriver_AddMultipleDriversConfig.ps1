<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 313aaa79-c93b-4241-af95-61d1eb899aa4
#>

<#
    .DESCRIPTION
        Installs multiple print drivers from the same source inf file
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
            Name    = @(
                "Xerox Global Print Driver PCL6"
                "Xerox Global Print Driver PS"
            )
            Version = "1.2.3.4"
            Source  = "C:\Drivers\Xerox\x2UNiVX.inf"
        } # End PrinterDriver
    } # End Node
} # End Configuration
