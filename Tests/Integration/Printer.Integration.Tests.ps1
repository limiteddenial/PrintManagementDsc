$script:DSCModuleName = 'PrintManagementDsc'
$script:DSCResourceName = 'Printer'

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

Start-Service -Name Spooler
Write-Warning -Message "Listing all drivers installed"
foreach ($driver in (Get-PrinterDriver).Name) {
    Write-Warning -Message "Found driver: $driver"
}


# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Integration" {
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
        } # End compile and apply mof

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        } # End get-dscconfiguration

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
            }

            $current[0].Name | Should -Be 'IntegrationLPR'
            $current[0].PortType  | Should -Be 'LPR'
            $current[0].PortName  | Should -Be 'IntegrationLPRPort'
            $current[0].Address  | Should -Be 'Test.local'
            $current[0].DriverName  | Should -Be 'Microsoft XPS Document Writer v4'
            $current[0].LprQueueName  | Should -Be 'dummyQueue'
            $current[0].Shared   | Should -Be $false
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