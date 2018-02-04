function Get-TargetResource {
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [parameter(Mandatory = $false)]
        [ValidateScript({Test-Path $_ })] 
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version

    )
    # Get the list of installed printer drivers.
    $InstalledPrintDriver = Get-PrinterDriver -Name $Name -ErrorAction SilentlyContinue

    if($InstalledPrintDriver){
        #The driver version is converted to an int64 in the PrintDriver looked so we need to query the windows driver
        $installedDriver = Get-WindowsDriver -Online -Verbose:$false -Driver $InstalledPrintDriver.InfPath
        
        return @{
            Name = $Name
            Ensure = "Present"
            Source = $InstalledPrintDriver.InfPath
            Version = $installedDriver.Version | Get-Unique
        }
    } else {
        return @{
            Name = $Name
            Ensure = "Absent"
        }
    
    }
}
function Set-TargetResource{
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [parameter(Mandatory = $false)]
        [ValidateScript({Test-Path $_ })] 
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version
    )

    $currentValues = Get-TargetResource @PSBoundParameters

    switch ($Ensure) {
        'Absent' {
            if($currentValues.Ensure -eq 'Present'){
                Remove-PrinterDriver -Name $Name
            }
        }
        'Present' {
            if($currentValues.Ensure -eq 'Absent'-or $currentValues.Version -ne $Version){
                # We are checking the drivers in the DriverStore to see if the drivers already exist.
                $driverINF = Get-DriverStoreINF -Name $Name -Version $Version
                if($DriverINF){
                    Add-PrinterDriver -InfPath $DriverINF -Name $Name
                } else {
                    # The print driver wasn't found in the existing drivers in the DriverStore. We need to install it
                    C:\Windows\system32\pnputil.exe /a "$Source"
                    $driverINF = Get-DriverStoreINF -Name $Name -Version $Version
                    if($DriverINF){
                        Add-PrinterDriver -InfPath $DriverINF -Name $Name
                    }
                    
                }
            }
        }
    }
}
function Test-TargetResource{
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present",   

        [parameter(Mandatory = $false)]
        [ValidateScript({Test-Path $_ })] 
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version
    )

    $currentValues = Get-TargetResource @PSBoundParameters

    switch ($Ensure)
    {
        'Absent'
        {
            if ( $currentValues.Ensure -eq 'Absent' ) {
                return $true 
            } else {
                Write-Verbose -Message "Ensure does not match desired state. Current value: $($currentValues.Ensure) - Desired Value: $Ensure"
                return $false 
            }
        }
        'Present' {
            if ( $currentValues.Ensure -eq 'Absent' ) {
                Write-Verbose -Message "Ensure does not match desired state. Current value: $($currentValues.Ensure) - Desired Value: $Ensure"
                return $false
            } 
            if ($Version -ne $currentValues.version) { 
                Write-Verbose -Message "Version does not match desired state. Current value: $($currentValues.version) - Desired Value: $version"
                return $false 
            }
            return $true
        }
    }
}
#helper Functions
function Get-DriverStoreINF {
    [OutputType([System.String])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Version,
        
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name
    )
        
    $InstalledDriverPacks = Get-WindowsDriver -Online -Verbose:$false | Where-Object {$_.Version -eq $Version}
    foreach ($InstalledDriverPack in $InstalledDriverPacks){
        $DriverExistingPack = Get-WindowsDriver -Online -Driver $InstalledDriverPack.OriginalFileName -Verbose:$false | Where-Object {$_.HardwareDescription -eq $Name}
        if($DriverExistingPack){
            Write-Verbose "Found existing driver package at $($InstalledDriverPack.OriginalFileName)"
            return $InstalledDriverPack.OriginalFileName
        }
    }
}

Export-ModuleMember -Function *-TargetResource
