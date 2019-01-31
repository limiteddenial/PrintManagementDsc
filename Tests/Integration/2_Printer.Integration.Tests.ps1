[Microsoft.DscResourceKit.IntegrationTest(OrderNumber = 2)]
$script:DSCModuleName = 'PrintManagementDsc'
$script:DSCResourceName = 'Printer'

#region HEADER
# Integration Test Template Version: 1.1.0
[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\PrintManagementDsc'

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) ) {
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endRegion

Start-Service -Name Spooler
Write-Warning -Message "Listing all drivers installed"
foreach ($driver in (Get-PrinterDriver).Name) {
    Write-Warning -Message "Found driver: $driver"
}


# Using try/finally to always cleanup even if something awful happens.
try {
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
        } # End Get-DscConfiguration

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq "$($script:DSCResourceName)_Config"
            }
            # $current[0] is the driver resource, it is tested in another test.

            $current[1].Name | Should -Be 'IntegrationTCPIP'
            $current[1].PortType  | Should -Be 'TCPIP'
            $current[1].PortName  | Should -Be 'IntegrationTCPIPPort'
            $current[1].Address  | Should -Be 'Test.local'
            $current[1].DriverName  | Should -Be 'Generic / Text Only'
            $current[1].LprQueueName  | Should -Be $null
            $current[1].Shared   | Should -Be $true
            $current[1].SNMPCommunity | Should -Be 'public'
            $current[1].SNMPIndex | Should -Be 1

            $current[2].Name | Should -Be 'IntegrationLPR'
            $current[2].PortType  | Should -Be 'LPR'
            $current[2].PortName  | Should -Be 'IntegrationLPRPort'
            $current[2].Address  | Should -Be 'Test.local'
            $current[2].DriverName  | Should -Be 'Generic / Text Only'
            $current[2].LprQueueName  | Should -Be 'dummyQueue'
            $current[2].Shared   | Should -Be $false
        }
    } # End Describe
    #endRegion
} # End Try
finally {

    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endRegion
} # End Finally