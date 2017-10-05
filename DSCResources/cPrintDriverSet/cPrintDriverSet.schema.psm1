$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import ResourceSetHelper for New-ResourceSetConfigurationScriptBlock
$script:dscResourcesFolderFilePath = Split-Path -Path $PSScriptRoot -Parent
$script:resourceSetHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'ResourceSetHelper.psm1'
Import-Module -Name $script:resourceSetHelperFilePath

Configuration cPrintDriverSet
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String[]]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [parameter(Mandatory = $false)]
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version
    )

    $newResourceSetConfigurationParams = @{
        ResourceName = 'cPrintDriver'
        ModuleName = 'cPrinterManagement'
        KeyParameterName = 'Name'
        Parameters = $PSBoundParameters
    }
    
    $configurationScriptBlock = New-ResourceSetConfigurationScriptBlock @newResourceSetConfigurationParams

    # This script block must be run directly in this configuration in order to resolve variables
    . $configurationScriptBlock
}
