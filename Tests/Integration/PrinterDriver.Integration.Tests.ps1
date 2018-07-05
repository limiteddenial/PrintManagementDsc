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
Write-Warning 'Downloading Generic / Text Only driver from Microsoft'
Invoke-WebRequest 'http://download.windowsupdate.com/msdownload/update/driver/drvs/2011/07/4745_b71b6fcc3d1b83b569cd738e6bdc2f591a205b14.cab' -OutFile "$script:moduleRoot\IntegrationDriver.cab"
New-Item -Path "$script:moduleRoot" -ItemType Directory -Name 'IntegrationDriver'
Write-Warning "Extracting CAB file to $script:moduleRoot\IntegrationDriver"
Expand.exe "$script:moduleRoot\IntegrationDriver.cab" -F:* "$script:moduleRoot\IntegrationDriver"
Start-Service -Name Spooler

# Using try/finally to always cleanup even if something awful happens.

try
{
    #region Integration Tests
    

    Describe "$($script:DSCResourceName)_Integration - Adding Driver" {
        $configData = @{
            AllNodes = @(
                @{
                    NodeName  = 'localhost'
                    Ensure = 'Present'
                    Name = 'Generic / Text Only'
                    Version = '6.1.7600.16385'
                    Source = "$script:moduleRoot\IntegrationDriver\prnge001.inf"
                    Purge = $false
                }
            )
        }
        $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
        . $ConfigFile -Verbose -ErrorAction Stop

        It 'Should compile and apply the MOF without throwing' {
            {
             & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive -ConfigurationData $configData

            Start-DscConfiguration `
                -Path $TestDrive `
                -ComputerName localhost `
                -Wait `
                -Verbose `
                -Force `
                -ErrorAction Stop
            } | Should -Not -Throw
        } # End compile and apply mof

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        } # End get-dscconfiguration

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
            }
            $current[0].Name | Should -Be $configData.AllNodes[0].Name
            $current[0].Version  | Should -Be $configData.AllNodes[0].Version
        }
    } # End Describe
    Describe "$($script:DSCResourceName)_Integration - Removing Driver" {
        $configData = @{
            AllNodes = @(
                @{
                    NodeName  = 'localhost'
                    Ensure = 'Absent'
                    Name = 'Generic / Text Only'
                    Version = '6.1.7600.16385'
                    Source = "$script:moduleRoot\IntegrationDriver\prnge001.inf"
                    Purge = $true
                }
            )
        }
        $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
        . $ConfigFile -Verbose -ErrorAction Stop

        It 'Should compile and apply the MOF without throwing' {
            {
             & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive -ConfigurationData $configData

            Start-DscConfiguration `
                -Path $TestDrive `
                -ComputerName localhost `
                -Wait `
                -Verbose `
                -Force `
                -ErrorAction Continue
            } | Should -Not -Throw
        } # End compile and apply mof

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        } # End get-dscconfiguration

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
            }
            $current[0].Ensure | Should -Be $configData.AllNodes[0].Ensure
            
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