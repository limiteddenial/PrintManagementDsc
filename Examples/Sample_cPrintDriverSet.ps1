<#
    .SYNOPSIS
        Example to set a printer driver set. 
    .DESCRIPTION
        This examples adds and installs a print driver set. 
#>
Configuration Sample_cPrintDriverSet {

    Import-DSCResource -ModuleName cPrinterManagement

    Node $AllNodes.NodeName {
        
        cPrintDriverSet Kyocera {
            Ensure = "Present"
            Name = @(
                'Kyocera KM-3050 KX',
                'Kyocera KM-4050 KX'
            )
            Version = "7.1.330.0"
            Source = "C:\Drivers\Kyocera\oemsetup.inf"
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
Sample_cPrintDriverSet -ConfigurationData $ConfigData
Start-DscConfiguration -Path Sample_PrintDriverSet -Wait -Verbose -Force
