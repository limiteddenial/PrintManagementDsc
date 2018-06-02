[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\PrintManagementDsc'

$PrinterDriver = [PSObject]@{
    Ensure = 'Present'
    Name = 'Generic / Text Only'
    Version = '6.1.7600.16385'
    Source = "$script:moduleRoot\PrinterDriver\prnge001.inf"
}

Configuration PrinterDriver_Config
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    Node $NodeName
    {
        PrinterDriver Integration_Test {
            Ensure = $PrinterDriver.Ensure
            Name = $PrinterDriver.Name
            Version = $PrinterDriver.Version
            Source = $PrinterDriver.Source
        } # End PrinterDriver
    } # End Node
} # End Configuration