enum Ensure
{
    Absent
    Present
}
[DscResource()]
class PrinterDriver
{
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Mandatory)]
    [System.String[]]$Name

    [DscProperty(Key)]
    [System.String] $Source

    [DscProperty(Mandatory)]
    [System.String] $Version

    [DscProperty()]
    [System.Boolean] $Purge = $false

    hidden $Messages = ""

    PrinterDriver()
    {
        $this.Messages = Import-LocalizedData -FileName 'PrinterDriver.strings.ps1' -BaseDirectory (Split-Path -Parent $PSCOMMANDPATH)
        Import-Module -Name Dism -Verbose:$false
    }
    [void] Set()
    {
        if ($this.Ensure -eq [Ensure]::Present)
        {
            $stagedDriver = $this.InstalledDriver()
            if ($null -eq $stagedDriver)
            {
                Write-Verbose -Message ($this.Messages.DriverDoesNotExistMessage -f $this.Name)

                $output = Invoke-Command -ScriptBlock {
                    param (
                        [Parameter()]$Source
                    )
                    & C:\Windows\System32\pnputil.exe -a "$Source"
                } -ArgumentList ($this.Source)

                [regex]$DriverAdded = '(?i)Published Name\s?:\s*(?<Driver>oem\d+\.inf)'
                $successDriverAdd = $DriverAdded.Match($output)
                if ($successDriverAdd.Success)
                {
                    $this.Source = (Get-WindowsDriver -Driver $successDriverAdd.Groups['Driver'].Value -Online).OriginalFileName[0]
                    Write-Verbose -Message  ($this.Messages.StagedDriverMessage -f $this.Source)
                } # End if DriverAdded
                else
                {
                    Write-Error -Message ($this.Messages.FailedToStageDriver -f $this.Source)
                    return
                } # End Else
            } # End Else
            else
            {
                # Need to reset the Source path to the driver store location
                $this.Source = $stagedDriver.OriginalFileName
            } # End else

            foreach ($Name in $this.Name)
            {
                $AddPrinterPortParams = @{
                    InfPath = $this.Source
                    Name    = $Name
                }
                try
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End Try
                catch
                {
                    $installedPrintDriver = $null
                    Add-PrinterDriver @AddPrinterPortParams
                } # End catch

                if ($null -ne $installedPrintDriver -and $installedPrintDriver.InfPath -ne $stagedDriver.OriginalFileName)
                {
                    Add-PrinterDriver @AddPrinterPortParams
                } # End if installedPrintDriver
            } # End foreach Name
        } # End if Ensure Present
        else
        {
            foreach ($Name in $this.Name)
            {
                try
                {
                    Write-Verbose -Message ($this.Messages.RemovingPrintDriver -f $Name)
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End Try
                catch
                {
                    $installedPrintDriver = $null
                } # End catch
                if ($null -ne $installedPrintDriver)
                {
                    Remove-PrinterDriver -Name $Name
                } # End if installedPrintDriver
            } # End foreach Name
            if ($this.Purge -eq $true)
            {
                Write-Verbose -Message $this.Messages.PurgingDriverMessage
                $stagedDriver = $this.InstalledDriver()
                if ($null -ne $stagedDriver.Driver)
                {
                    Write-Verbose -Message ($this.Messages.CheckingForRemovalConflicts -f $stagedDriver.Driver)
                    $driverConflicts = Get-PrinterDriver | Where-Object InfPath -eq $stagedDriver.OriginalFileName
                    if ([bool]$driverConflicts)
                    {
                        Write-Warning -Message ($this.Messages.FoundConflicts -f ($driverConflicts.Name -join ','), $stagedDriver.OriginalFileName)
                    } # End if driverConflicts
                    else
                    {
                        Write-Verbose -Message ($this.Messages.RemovingDriverMessage -f $stagedDriver.OriginalFileName)
                        $output = Invoke-Command -ScriptBlock {
                            param (
                                [Parameter()]$Driver
                            )
                            & "C:\Windows\System32\pnputil.exe" -f -d "$Driver"
                        } -ArgumentList ($stagedDriver.Driver)

                        if ($output -ilike "*successfully*")
                        {
                            Write-Verbose -Message ($this.Messages.DriverRemovedSuccessfullyMessage -f $stagedDriver.Driver)
                        }
                        else
                        {
                            Write-Error -Message $this.Messages.ErrorRemovingDriverMessage
                        }
                    } # End else driverConflicts
                } # End If StagedDriver
            } # End if Purge
        } # End Else Ensure
    } # End Set()
    [bool] Test()
    {
        if ($this.Ensure -eq [Ensure]::Present)
        {
            foreach ($Name in $this.Name)
            {
                try
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End Try
                catch
                {
                    $installedPrintDriver = $null
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Ensure", $Name, 'Absent', $this.Ensure)
                    return $false
                } # End catch
                $windowsDriverParam = @{
                    Driver = $installedPrintDriver.InfPath
                    Online = $true
                }
                $currentVersion = (Get-WindowsDriver @windowsDriverParam).Version | Get-Unique
                if ($currentVersion -ne $this.Version)
                {
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Version", $Name, $currentVersion, $this.Version)
                    return $false
                }
            } # End foreach Name
        } # End if Ensure Present
        else
        {
            foreach ($Name in $this.Name)
            {
                try
                {
                    $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
                } # End try
                catch
                {
                    $installedPrintDriver = $null
                } # End catch
                if ($installedPrintDriver)
                {
                    Write-Verbose -Message  ($this.Messages.NotInDesiredStateMultipleObjects -f "Ensure", $Name, 'Present', $this.Ensure)
                    return $false
                } # End if installedPrintDriver
                if ($this.Purge -eq $true)
                {
                    $stagedDriver = $this.InstalledDriver()
                    if (-not [string]::IsNullOrEmpty($stagedDriver))
                    {
                        return $false
                    } # End If StagedDriver
                } # End If Purge
            } # End foreach Name
        } # End else
        return $true
    } # End Test()

    [PrinterDriver] Get()
    {
        $ReturnObject = [PrinterDriver]::new()
        $ReturnObject.Name = @()

        foreach ($Name in $this.Name)
        {
            try
            {
                $installedPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction Stop
            } # End Try
            catch
            {
                $installedPrintDriver = $null
                # Print driver isn't installed, need to look in the driver store to see if it is there. Only checking if the $Purge is set to true
                $ReturnObject.Ensure = [Ensure]::Absent
                if ($this.Purge -eq $true)
                {
                    $stagedDriver = $this.InstalledDriver()
                    if ($null -ne $stagedDriver)
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
        } # End foreach Name

        return $ReturnObject
    } # End Get()

    hidden [System.Collections.Hashtable] InstalledDriver()
    {
        # Since we don't have an INF file to look at. We need look in the driver store.
        $InstalledDriverPacks = Get-WindowsDriver -Online -All -Verbose:$false | Where-Object { $_.ClassName -eq 'Printer' -and $_.Version -eq $this.Version }
        foreach ($InstalledDriverPack in $InstalledDriverPacks)
        {
            $DriverExists = Get-WindowsDriver -Online -Driver $InstalledDriverPack.Driver -Verbose:$false | Where-Object { $this.Name -contains $_.HardwareDescription }

            if ($DriverExists)
            {
                Write-Verbose -Message ($this.Messages.FoundStagedDriverMessage -f $InstalledDriverPack.OriginalFileName)
                $returnDriver = @{
                    OriginalFileName = $InstalledDriverPack.OriginalFileName
                    Driver           = $InstalledDriverPack.Driver
                }

                return $returnDriver
            } # End if DriverExists
        } # End foreach

        return $null
    } # End InstalledDriver()
} # End Class PrinterDriver
