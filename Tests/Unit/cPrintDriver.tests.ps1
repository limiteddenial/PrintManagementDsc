$Global:ModuleName = 'cPrinterManagement'
$Global:DscResourceName = 'cPrintDriver'

#region HEADER

# Unit Test Template Version: 1.2.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
-DSCModuleName $Global:ModuleName `
-DSCResourceName $Global:DscResourceName `
-TestType Unit
#endregion HEADER

# Begin Testing
try {
#region HEADER

    InModuleScope -ModuleName $Global:DscResourceName {
        # Region cPrintDriver
        $testPresentParams = @{
            Ensure = [Ensure]::Present
            Name = 'myName'
            Source = 'C:\test.inf'
            Version = '1.2.3.4'
            Purge = $false
        }
        $testMultiplePresentParams = @{
            Ensure = [Ensure]::Present
            Name = @(
                'myName1',
                'myName2'
            )
            Source = 'C:\test.inf'
            Version = '1.2.3.4'
            Purge = $false
        }
        $testAbsentParams = $testPresentParams.clone()
        $testAbsentParams.Ensure = [Ensure]::Absent
        $testAbsentPurgeParams = $testAbsentParams.clone()
        $testAbsentPurgeParams.Purge = $true
        $testMultipleAbsentParams = $testMultiplePresentParams.clone()
        $testMultipleAbsentParams.Ensure = [Ensure]::Absent
        # End Region
        # Region Get-PrintDriver
        $fakemyName = @{
            Name = "myName"
            PrinterEnvironment = "Windows x64"
            MajorVersion = 3
            Manufacturer = "Mock"
            InfPath = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        $fakemyName1 = @{
            Name = "myName1"
            PrinterEnvironment = "Windows x64"
            MajorVersion = 3
            Manufacturer = "Mock"
            InfPath = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        $fakemyName2 = @{
            Name = "myName2"
            PrinterEnvironment = "Windows x64"
            MajorVersion = 3
            Manufacturer = "Mock"
            InfPath = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        # End Region Get-PrintDriver
        # Region Get-WindowsDriver
        $fakeWindowsDriversWithoutPrinters =  @(
            [PSCustomObject]@{
                Driver = 'oem8.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake1\fake1.inf'
                Inbox = 'False'
                ClassName = 'Display'
                BootCritical = 'False'
                ProviderName = 'myDisplay'
                Date = '10/27/2017 12:00:00 AM'
                Version = '23.21.13.8813'
            }
            [PSCustomObject]@{
                Driver = 'oem9.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake2\fake2.inf'
                Inbox = 'False'
                ClassName = 'Net'
                BootCritical = 'False'
                ProviderName = 'myNet'
                Date = '10/27/2017 12:00:00 AM'
                Version = '2.1.3.13'
            }
        )
        $fakeWindowsDriversWithPrinters =  @(
            [PSCustomObject]@{
                Driver = 'oem8.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake1\fake1.inf'
                Inbox = 'False'
                ClassName = 'Display'
                BootCritical = 'False'
                ProviderName = 'myDisplay'
                Date = '10/27/2017 12:00:00 AM'
                Version = '23.21.13.8813'
            }
            [PSCustomObject]@{
                Driver = 'oem9.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake2\fake2.inf'
                Inbox = 'False'
                ClassName = 'Net'
                BootCritical = 'False'
                ProviderName = 'myNet'
                Date = '10/27/2017 12:00:00 AM'
                Version = '2.1.3.13'
            }
            [PSCustomObject]@{
                Driver = 'oem10.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox = 'False'
                ClassName = 'Printer'
                BootCritical = 'False'
                ProviderName = 'Mock'
                Date = '10/27/2017 12:00:00 AM'
                Version = '1.2.3.4'
            }
            [PSCustomObject]@{
                Driver = 'oem11.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName2\myName2.inf'
                Inbox = 'False'
                ClassName = 'Printer'
                BootCritical = 'False'
                ProviderName = 'Mock'
                Date = '10/27/2017 12:00:00 AM'
                Version = '2.1.3.13'
            }
        )
        $windowsPrintDrivermyName = @{
            Driver = 'oem10.inf'
            OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
            Inbox = $False
            ClassName = 'Printer'
            ClassDescription = 'Printers'
            ClassGuid = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
            BootCritical = $False
            ProviderName = 'Mock'
            Date = '10/27/2017 12:00:00 AM'
            Version = '1.2.3.4'
            ManufacturerName = '"Mock'
            HardwareDescription = 'myName'
            Architecture = 'x64'
            HardwareId = 'wsdprint\myName'
            ServiceName = ''
            CompatibleIds = 'myName'
            ExcludeIds = ''
        }
        $windowsPrintDrivermyNameMultiple = @(
            [PSCustomObject]@{
                Driver = 'oem10.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox = $False
                ClassName = 'Printer'
                ClassDescription = 'Printers'
                ClassGuid = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical = $False
                ProviderName = 'Mock'
                Date = '10/27/2017 12:00:00 AM'
                Version = '1.2.3.4'
                ManufacturerName = '"Mock'
                HardwareDescription = 'myName'
                Architecture = 'x64'
                HardwareId = 'wsdprint\myName'
                ServiceName = ''
                CompatibleIds = 'myName'
                ExcludeIds = ''
            }
            [PSCustomObject]@{
                Driver = 'oem10.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox = $False
                ClassName = 'Printer'
                ClassDescription = 'Printers'
                ClassGuid = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical = $False
                ProviderName = 'Mock'
                Date = '10/27/2017 12:00:00 AM'
                Version = '1.2.3.4'
                ManufacturerName = '"Mock'
                HardwareDescription = 'myName1'
                Architecture = 'x64'
                HardwareId = 'wsdprint\myName1'
                ServiceName = ''
                CompatibleIds = 'myName1'
                ExcludeIds = ''
            }
            [PSCustomObject]@{
                Driver = 'oem10.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox = $False
                ClassName = 'Printer'
                ClassDescription = 'Printers'
                ClassGuid = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical = $False
                ProviderName = 'Mock'
                Date = '10/27/2017 12:00:00 AM'
                Version = '1.2.3.4'
                ManufacturerName = '"Mock'
                HardwareDescription = 'myName2'
                Architecture = 'x64'
                HardwareId = 'wsdprint\myName2'
                ServiceName = ''
                CompatibleIds = 'myName2'
                ExcludeIds = ''
            }
        )

        # End Region Get-WindowsDriver
        Describe 'Get Method'{
            BeforeEach {
                Mock -CommandName Get-PrinterDriver
                Mock -CommandName Get-WindowsDriver
            } # End BeforeEach
            context "Get Type" {
                it 'Get should return cPrintDriver object' {
                    $absentParms = [cPrintDriver]$testAbsentParams
                    Mock -CommandName Get-PrinterDriver -MockWith { throw }
                    $absentParms.Get().GetType().Name | Should Be 'cPrintDriver'
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                }
            } # End context Get Type
            context "Get Ensure Absent" {
                it 'Should return Absent if the print driver does not exist' {
                    $absentParms = [cPrintDriver]$testAbsentParams
                    Mock -CommandName Get-PrinterDriver -MockWith { throw }
                    $absentParms.Get().Ensure | Should be 'Absent'
                } # End it driver Absent
                it 'Should return Absent if any driver from in Name[] does not exist' {
                    $absentParms = [cPrintDriver]$testMultipleAbsentParams
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter {$name -eq "myName1"}
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter {$name -eq "myName2"}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}

                    $absentParms.Get().Ensure | Should be 'Absent'
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName1"}
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName2"}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}

                } # End it driver Absent
                it 'Should return Absent if driver is not in print driver and the driver store' {
                    $absentParms = [cPrintDriver]$testAbsentPurgeParams
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter {$name -eq "myName"}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithoutPrinters }  
                    $absentParms.Get().Ensure | Should be 'Absent'
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName"}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                } # End it driver Absent
                it 'Should return Present if driver is not in print driver and exits the driver store when the purge is set to true' {
                    $absentParms = [cPrintDriver]$testAbsentPurgeParams
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter {$name -eq "myName"}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter {$Online -and $Driver -eq 'oem10.inf'}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters } -ParameterFilter {$Online -and $All }
                    $absentParms.Get().Ensure | Should -be 'Present'
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName"}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$Online -and $Driver -eq 'oem10.inf'}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$Online -and $All}
                } # End it purge driver still exists
            } # End Context Get Ensure Absent
            context 'Get Ensure Present' {
                it 'Should return Present if print driver exists' {
                    $presentParams = [cPrintDriver]$testPresentParams
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter {$name -eq 'myName'}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}
                    $returnedObject = $presentParams.Get()
                    $returnedObject.Version | Should -BeExactly '1.2.3.4'
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName"}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}
                } # End it Present if print driver exists
                
                it 'Should return Present if all print driver exists' {
                    $presentParams = [cPrintDriver]$testMultiplePresentParams 
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter {$name -eq 'myName1'}
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter {$name -eq 'myName2'}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}
                    
                    $returnedObject = $presentParams.Get()
                    $returnedObject.Ensure | Should be 'Present'
                    $returnedObject.Name | Should -Be @('myName1','myName2')
                    $returnedObject.Source | Should -BeExactly 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                    $returnedObject.Version | Should -BeExactly '1.2.3.4'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName1"}
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter {$name -eq "myName2"}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 2 -Exactly -Scope It -ParameterFilter {$driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online}
                } # End it Present if print driver exists
            } # End Context Get Ensure Present
            context 'InstalledDriver function' {
                it 'Should return null' {
                    $absentParms = [cPrintDriver]$testPresentParams
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithoutPrinters }
                    $absentParms.InstalledDriver() | Should be ''
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                }
                it 'Should return oem10.inf' {
                    $absentParms = [cPrintDriver]$testPresentParams
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter {$Online -and $Driver -eq 'oem10.inf'}
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters }  -ParameterFilter {$Online -and $All }
    
                    $absentParms.InstalledDriver() | Should be 'oem10.inf'
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$Online -and $Driver -eq 'oem10.inf'}
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter {$Online -and $All}
                    
                }
            }
        } # End Describe Get Method
    } # End InModuleScope
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}