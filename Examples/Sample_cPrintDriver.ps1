<#
    .SYNOPSIS
        Example to set a printer driver. 
    .DESCRIPTION
        This examples adds and installs a print driver. 
#>
Configuration Sample_cPrintDriver {

    Import-DSCResource -ModuleName cPrinterManagement

    Node $AllNodes.NodeName {
        
        cPrintDriver XeroxGlobal {
            Ensure = "Present"
            Name = "Xerox Global Print Driver PCL6"
            Version = "5496.700.0.0"
            Source = "C:\Drivers\Xerox\x2UNiVX.inf"
        }
    }
}
$ConfigData = @{ 
    AllNodes = @( 
        @{
            NodeName = "*"
        }
    )
}
Sample_cPrintDriver -ConfigurationData $ConfigData
Start-DscConfiguration -Path Sample_PrintDriver -Wait -Verbose -Force
