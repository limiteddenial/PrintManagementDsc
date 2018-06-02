$script:DSCModuleName = 'PrintManagementDsc'
$script:DSCResourceName = 'PrinterDriver'

#region HEADER
# Integration Test Template Version: 1.1.0
[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\PrintManagementDsc'

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Downloading Print Driver from microsoft catalog
Write-Warning 'Downloading Generic -Text Only driver from Microsoft'
Invoke-WebRequest 'http://download.windowsupdate.com/msdownload/update/driver/drvs/2011/07/4745_b71b6fcc3d1b83b569cd738e6bdc2f591a205b14.cab' -OutFile "$script:moduleRoot\PrinterDriver.cab"
New-Item -Path "$script:moduleRoot" -ItemType Directory -Name 'PrinterDriver'
Write-Warning "Extracting CAB file to $script:moduleRoot\PrinterDriver"
Expand.exe "$script:moduleRoot\PrinterDriver.cab" -F:* "$script:moduleRoot\PrinterDriver"
# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile and apply the MOF without throwing' {
        {
            & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive

            Start-DscConfiguration `
                -Path $TestDrive `
                -ComputerName localhost `
                -Wait `
                -Verbose `
                -Force `
                -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }


    } # End Describe
    #endregion
} # End Try
finally
{

    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
} # End Finally