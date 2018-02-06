enum Ensure 
{
    Absent
    Present
}
[DscResource()]
class cPrintDriver {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure
    
    [DscProperty(Mandatory)] 
    [System.String[]]$Name

    [DscProperty(Key)]
    [System.String] $Source

    [DscProperty(Mandatory)]
    [System.Version] $Version

    [DscProperty()]
    [System.Boolean] $Purge = $false
    
    hidden $Messages = ""
    
    cPrintDriver()
    {
        $this.Messages = (Import-LocalizedData  -FileName 'cPrinterManagement.strings.psd1' -BaseDirectory (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCOMMANDPATH))))
    }
    [void] Set()
    {

    } # End Set()
    [bool] Test()
    {
        return $false
    } # End Test()
    [cPrintDriver] Get()
    {
        $ReturnObject = [cPrintDriver]::new()
        $ReturnObject.Name = @()
        Foreach ($Name in $this.Name)
        {
            try
            {
                $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
            } # End Try
            catch
            {
                $installedPrintDriver = $null
                # Print driver isn't installed, need to look in the driver store to see if it is there. Only checking if the $Pruge is set to true
                $ReturnObject.Ensure = [Ensure]::Absent
                if($this.Purge -eq $true)
                {
                    $stagedDriver = $this.InstalledDriver()
                    if(-not [string]::IsNullOrEmpty($stagedDriver))
                    {
                        $ReturnObject.Ensure = [Ensure]::Present
                    } # End If StagedDriver
                } # End If this.Purge
                return $ReturnObject
            } # End catch
            $ReturnObject.Ensure = [Ensure]::Present
            $windowsDriverParam = @{
                Driver = $installedPrintDriver.InfPath
                Online = $true
            }
            $ReturnObject.Source = $installedPrintDriver.InfPath
            $ReturnObject.Version = (Get-WindowsDriver @windowsDriverParam).Version | Get-Unique
            [System.Collections.ArrayList]$tmpArrayList = $ReturnObject.Name
            $tmpArrayList.Add($Name)
            $ReturnObject.Name = $tmpArrayList | Sort-Object
            Remove-Variable -Name tmpArrayList
        } # End Foreach Name
        return $ReturnObject
    } # End Get()
    hidden [string] InstalledDriver() 
    {
        # Since we don't have an INF file to look at. We need 
        $InstalledDriverPacks = Get-WindowsDriver -Online -All | Where-Object {$_.ClassName -eq 'Printer' -and $_.Version -eq $this.Version}
        foreach ($InstalledDriverPack in $InstalledDriverPacks) 
        {   
            $DriverExists = Get-WindowsDriver -Online -Driver $InstalledDriverPack.Driver | Where-Object {$_.HardwareDescription -eq $this.Name}
            if($DriverExists)
            {
                Write-Verbose "Found existing driver package at $($InstalledDriverPack.OriginalFileName)"
                return $InstalledDriverPack.Driver
            } # End if DriverExists
        } # End Foreach
        return $null
    } # End InstalledDriver()
} # End Class cPrintDriver
