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
        if($this.Ensure -eq [Ensure]::Present)
        {
            
        }
        else 
        {
            Foreach ($Name in $this.Name)
            {
                try
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End Try
                catch 
                {
                    $installedPrintDriver = $null
                } # End catch
                if($null -ne $installedPrintDriver)
                {
                    Remove-PrinterDriver -Name $Name
                } # End if installedPrintDriver
            } # End foreach Name
            if($this.Purge -eq $true)
            {
                $stagedDriver = $this.InstalledDriver()
                if(-not [string]::IsNullOrEmpty($stagedDriver))
                {
                    Write-Verbose -Message ($this.Messages.CheckingForRemovalConflicts -f $stagedDriver)
                    $driverConflicts = Get-PrinterDriver | Where-Object InfPath -eq $stagedDriver
                    if([bool]$driverConflicts)
                    {
                        Write-Warning -Message ($this.Messages.FoundConflicts -f ($driverConflicts.Name -join ','),$stagedDriver)
                    } # End if driverConflicts
                    else {
                        $addDriverScriptBlock = {
                            param(
                                [Parameter()]$Driver
                            )
                            $System32Path = (Join-Path -Path (Get-Item ENV:\windir).value -ChildPath 'System32') 
                            & "$system32Path\pnputil.exe" /delete-driver "$Driver" | Out-Null
                        } # End addDriverScriptBlock
                        Invoke-Command -ScriptBlock $addDriverScriptBlock -ArgumentList ($stagedDriver)
                    } # End else driverConflicts
                } # End If StagedDriver
            } # End if Purge
        } # End Else Ensure
    } # End Set()
    [bool] Test()
    {
        if($this.Ensure -eq [Ensure]::Present)
        {
            Foreach ($Name in $this.Name)
            {
                try
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End Try
                catch 
                {
                    $installedPrintDriver = $null
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Ensure",$Name,'Absent',$this.Ensure)
                    return $false
                } # End catch
                $windowsDriverParam = @{
                    Driver = $installedPrintDriver.InfPath
                    Online = $true
                }
                $currentVersion = (Get-WindowsDriver @windowsDriverParam).Version | Get-Unique
                if($currentVersion -ne $this.Version)
                {
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Version",$Name,$currentVersion,$this.Version)
                    return $false
                }
            } # End Foreach Name
        } # End if Ensure Present
        else 
        {
            Foreach ($Name in $this.Name)
            {
                try 
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End try
                catch 
                {
                    $installedPrintDriver = $null
                } # End catch
                if($installedPrintDriver)
                {
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Ensure",$Name,'Present',$this.Ensure)
                    return $false
                } # End if installedPrintDriver
                if($this.Purge -eq $true)
                {
                    $stagedDriver = $this.InstalledDriver()
                    if(-not [string]::IsNullOrEmpty($stagedDriver))
                    {
                        return $false
                    } # End If StagedDriver
                } # End If Purge
            } # End foreach Name
        } # End else
        return $true
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
            $DriverExists = Get-WindowsDriver -Online -Driver $InstalledDriverPack.Driver | Where-Object {$this.Name -contains $_.HardwareDescription}
            if($DriverExists)
            {
                Write-Verbose "Found existing driver package at $($InstalledDriverPack.OriginalFileName)"
                return $InstalledDriverPack.OriginalFileName
            } # End if DriverExists
        } # End Foreach
        return $null
    } # End InstalledDriver()
} # End Class cPrintDriver
