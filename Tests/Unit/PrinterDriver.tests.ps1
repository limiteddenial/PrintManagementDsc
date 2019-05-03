#region HEADER
$script:dscModuleName = 'PrintManagementDsc'
$script:dscResourceName = 'PrinterDriver'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) ) {
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$testEnvironmentParam = @{
    DSCModuleName   = $script:dscModuleName
    DSCResourceName = $script:dscResourceName
    TestType        = 'Unit'
    ResourceType    = 'Class'
}
$TestEnvironment = Initialize-TestEnvironment @testEnvironmentParam

#endregion HEADER

function Invoke-TestSetup {
}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
#endregion HEADER

# Begin Testing
try {
    #region HEADER

    InModuleScope -ModuleName $script:dscResourceName {
        # Region PrinterDriver
        $testPresentParams = @{
            Ensure  = [Ensure]::Present
            Name    = 'myName'
            Source  = 'C:\test.inf'
            Version = '1.2.3.4'
            Purge   = $false
        }
        $testMultiplePresentParams = @{
            Ensure  = [Ensure]::Present
            Name    = @(
                'myName1',
                'myName2'
            )
            Source  = 'C:\test.inf'
            Version = '1.2.3.4'
            Purge   = $false
        }
        $testAbsentParams = $testPresentParams.clone()
        $testAbsentParams.Ensure = [Ensure]::Absent
        $testAbsentPurgeParams = $testAbsentParams.clone()
        $testAbsentPurgeParams.Purge = $true
        $testMultipleAbsentParams = $testMultiplePresentParams.clone()
        $testMultipleAbsentParams.Ensure = [Ensure]::Absent
        $testMultipleAbsentPurgeParams = $testMultipleAbsentParams.clone()
        $testMultipleAbsentPurgeParams.Purge = $true
        # End Region
        # Region Get-PrintDriver
        $fakemyName = @{
            Name               = "myName"
            PrinterEnvironment = "Windows x64"
            MajorVersion       = 3
            Manufacturer       = "Mock"
            InfPath            = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        $fakeMynameWrongInf = $fakemyName.Clone()
        $fakeMynameWrongInf.InfPath = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myBadName.inf'
        $fakemyName1 = @{
            Name               = "myName1"
            PrinterEnvironment = "Windows x64"
            MajorVersion       = 3
            Manufacturer       = "Mock"
            InfPath            = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        $fakemyName2 = @{
            Name               = "myName2"
            PrinterEnvironment = "Windows x64"
            MajorVersion       = 3
            Manufacturer       = "Mock"
            InfPath            = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
        }
        $fakemyName2WrongInf = $fakemyName2.clone()
        $fakemyName2WrongInf.InfPath = 'C:\WINDOWS\System32\DriverStore\FileRepository\myNameWrong\myNameWrong.inf'
        $fakePrintDriversWithSameINF = @(
            [PSCustomObject]@{
                Name               = "myName1"
                PrinterEnvironment = "Windows x64"
                MajorVersion       = 3
                Manufacturer       = "Mock"
                InfPath            = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
            }
            [PSCustomObject]@{
                Name               = "myName2"
                PrinterEnvironment = "Windows x64"
                MajorVersion       = 3
                Manufacturer       = "Mock"
                InfPath            = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
            }
        )
        # End Region Get-PrintDriver
        # Region Get-WindowsDriver
        $fakeWindowsDriversWithoutPrinters = @(
            [PSCustomObject]@{
                Driver           = 'oem8.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake1\fake1.inf'
                Inbox            = 'False'
                ClassName        = 'Display'
                BootCritical     = 'False'
                ProviderName     = 'myDisplay'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '23.21.13.8813'
            }
            [PSCustomObject]@{
                Driver           = 'oem9.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake2\fake2.inf'
                Inbox            = 'False'
                ClassName        = 'Net'
                BootCritical     = 'False'
                ProviderName     = 'myNet'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '2.1.3.13'
            }
        )
        $fakeWindowsDriversWithPrinters = @(
            [PSCustomObject]@{
                Driver           = 'oem8.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake1\fake1.inf'
                Inbox            = 'False'
                ClassName        = 'Display'
                BootCritical     = 'False'
                ProviderName     = 'myDisplay'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '23.21.13.8813'
            }
            [PSCustomObject]@{
                Driver           = 'oem9.inf'
                OriginalFileName = 'C:\Windows\System32\DriverStore\FileRepository\fake2\fake2.inf'
                Inbox            = 'False'
                ClassName        = 'Net'
                BootCritical     = 'False'
                ProviderName     = 'myNet'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '2.1.3.13'
            }
            [PSCustomObject]@{
                Driver           = 'oem10.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox            = 'False'
                ClassName        = 'Printer'
                BootCritical     = 'False'
                ProviderName     = 'Mock'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '1.2.3.4'
            }
            [PSCustomObject]@{
                Driver           = 'oem11.inf'
                OriginalFileName = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName2\myName2.inf'
                Inbox            = 'False'
                ClassName        = 'Printer'
                BootCritical     = 'False'
                ProviderName     = 'Mock'
                Date             = '10/27/2017 12:00:00 AM'
                Version          = '2.1.3.13'
            }
        )
        $windowsPrintDrivermyName = @{
            Driver              = 'oem10.inf'
            OriginalFileName    = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
            Inbox               = $False
            ClassName           = 'Printer'
            ClassDescription    = 'Printers'
            ClassGuid           = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
            BootCritical        = $False
            ProviderName        = 'Mock'
            Date                = '10/27/2017 12:00:00 AM'
            Version             = '1.2.3.4'
            ManufacturerName    = '"Mock'
            HardwareDescription = 'myName'
            Architecture        = 'x64'
            HardwareId          = 'wsdprint\myName'
            ServiceName         = ''
            CompatibleIds       = 'myName'
            ExcludeIds          = ''
        }
        $windowsPrintDrivermyNameWrong = @{
            Driver              = 'oem11.inf'
            OriginalFileName    = 'C:\WINDOWS\System32\DriverStore\FileRepository\myNameWrong\myNameWrong.inf'
            Inbox               = $False
            ClassName           = 'Printer'
            ClassDescription    = 'Printers'
            ClassGuid           = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
            BootCritical        = $False
            ProviderName        = 'Mock'
            Date                = '10/27/2017 12:00:00 AM'
            Version             = '2.3.4.5'
            ManufacturerName    = '"Mock'
            HardwareDescription = 'myName2'
            Architecture        = 'x64'
            HardwareId          = 'wsdprint\myName2'
            ServiceName         = ''
            CompatibleIds       = 'myName2'
            ExcludeIds          = ''
        }
        $windowsPrintDrivermyNameMultiple = @(
            [PSCustomObject]@{
                Driver              = 'oem10.inf'
                OriginalFileName    = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox               = $False
                ClassName           = 'Printer'
                ClassDescription    = 'Printers'
                ClassGuid           = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical        = $False
                ProviderName        = 'Mock'
                Date                = '10/27/2017 12:00:00 AM'
                Version             = '1.2.3.4'
                ManufacturerName    = '"Mock'
                HardwareDescription = 'myName'
                Architecture        = 'x64'
                HardwareId          = 'wsdprint\myName'
                ServiceName         = ''
                CompatibleIds       = 'myName'
                ExcludeIds          = ''
            }
            [PSCustomObject]@{
                Driver              = 'oem10.inf'
                OriginalFileName    = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox               = $False
                ClassName           = 'Printer'
                ClassDescription    = 'Printers'
                ClassGuid           = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical        = $False
                ProviderName        = 'Mock'
                Date                = '10/27/2017 12:00:00 AM'
                Version             = '1.2.3.4'
                ManufacturerName    = '"Mock'
                HardwareDescription = 'myName1'
                Architecture        = 'x64'
                HardwareId          = 'wsdprint\myName1'
                ServiceName         = ''
                CompatibleIds       = 'myName1'
                ExcludeIds          = ''
            }
            [PSCustomObject]@{
                Driver              = 'oem10.inf'
                OriginalFileName    = 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                Inbox               = $False
                ClassName           = 'Printer'
                ClassDescription    = 'Printers'
                ClassGuid           = '{4D36E979-E325-11CE-BFC1-08002BE10318}'
                BootCritical        = $False
                ProviderName        = 'Mock'
                Date                = '10/27/2017 12:00:00 AM'
                Version             = '1.2.3.4'
                ManufacturerName    = '"Mock'
                HardwareDescription = 'myName2'
                Architecture        = 'x64'
                HardwareId          = 'wsdprint\myName2'
                ServiceName         = ''
                CompatibleIds       = 'myName2'
                ExcludeIds          = ''
            }
        )
        # End Region Get-WindowsDriver
        $successDriverAdd = "Microsoft PnP Utility

        Adding driver package:  myName.inf
        Driver package added successfully.
        Published Name:         oem10.inf

        Total driver packages:  1
        Added driver packages:  1
        "
        $failureDriverAdd = "Microsoft PnP Utility

        Failed to delete driver package: The parameter is incorrect."

        $successDriverRemoval = "Microsoft PnP Utility

        Driver package deleted successfully."

        Describe 'Get Method' {
            BeforeEach {
                Mock -CommandName Get-PrinterDriver
                Mock -CommandName Get-WindowsDriver
            } # End BeforeEach

            context "Get Type" {
                it 'Get should return PrinterDriver object' {
                    $absentParms = [PrinterDriver]$testAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw }

                    $absentParms.Get().GetType().Name | Should Be 'PrinterDriver'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                }
            } # End context Get Type

            context "Get Ensure Absent" {
                it 'Should return Absent if the print driver does not exist' {
                    $absentParms = [PrinterDriver]$testAbsentParams
                    Mock -CommandName Get-PrinterDriver -MockWith { throw }
                    $absentParms.Get().Ensure | Should be 'Absent'
                } # End it driver Absent

                it 'Should return Absent if any driver from in Name[] does not exist' {
                    $absentParms = [PrinterDriver]$testMultipleAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq "myName1" }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq "myName2" }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }

                    $absentParms.Get().Ensure | Should be 'Absent'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it driver Absent

                it 'Should return Absent if driver is not in print driver and the driver store' {
                    $absentParms = [PrinterDriver]$testAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq "myName" }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithoutPrinters }

                    $absentParms.Get().Ensure | Should be 'Absent'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                } # End it driver Absent

                it 'Should return Present if driver is not in print driver and exits the driver store when the purge is set to true' {
                    $absentParms = [PrinterDriver]$testAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq "myName" }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }

                    $absentParms.Get().Ensure | Should -be 'Present'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                } # End it purge driver still exists
            } # End Context Get Ensure Absent
            context 'Get Ensure Present' {
                it 'Should return Present if print driver exists' {
                    $presentParams = [PrinterDriver]$testPresentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }

                    $returnedObject = $presentParams.Get()
                    $returnedObject.Version | Should -BeExactly '1.2.3.4'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Present if print driver exists

                it 'Should return Present if all print driver exists' {
                    $presentParams = [PrinterDriver]$testMultiplePresentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }

                    $returnedObject = $presentParams.Get()
                    $returnedObject.Ensure | Should be 'Present'
                    $returnedObject.Name | Should -Be @('myName1', 'myName2')
                    $returnedObject.Source | Should -BeExactly 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                    $returnedObject.Version | Should -BeExactly '1.2.3.4'

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 2 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Present if print driver exists
            } # End Context Get Ensure Present
        } # End Describe Get Method
        Describe 'Test Method' {
            BeforeEach {
                Mock -CommandName Get-PrinterDriver
                Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter { $name -eq 'myName' }
                Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }

                Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
            } # End BeforeEach

            Context 'Type Test' {
                it 'Test should return bool object' {
                    $testParms = [PrinterDriver]$testPresentParams

                    $testParms.test() | Should -BeOfType bool

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it test should return bool object
            } # End Context Type Test

            Context 'Test Ensure Present' {

                Context 'Configuring Single Driver' {
                    it 'Test should return true with single driver' {
                        $testParms = [PrinterDriver]$testPresentParams

                        $testParms.test() | Should -BeExactly $true

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                    } # End it test should return true for single driver

                    it 'Test should return false with single driver that does not exist' {
                        $testParms = [PrinterDriver]$testPresentParams

                        Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }

                        $testParms.test() | Should -BeExactly $false

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 0 -Exactly -Scope It
                    } # End it Test should return false with single driver that does not exist

                    it 'Test should return false when single driver version does not match' {
                        $testParms = [PrinterDriver]$testPresentParams
                        $testParms.Version = '2.3.4.5'

                        $testParms.test() | Should -BeExactly $false

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                    } # End it Test should return false when single driver version does not match
                } # end context single driver

                Context 'Configuring Multiple Drivers' {
                    BeforeEach {
                        Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                        Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameWrong } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myNameWrong\myNameWrong.inf' -and $Online }
                    }

                    it 'Test should return true with multiple drivers' {
                        $testParms = [PrinterDriver]$testMultiplePresentParams

                        $testParms.test() | Should -BeExactly $true

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 2 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                    } # End it test should return true for multiple drivers

                    it 'Test should return false when one of the multiple drivers does not exist' {
                        $testParms = [PrinterDriver]$testMultiplePresentParams

                        Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName2' }

                        $testParms.test() | Should -BeExactly $false

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                    } # End it Test should return false when one of the multiple drivers does not exist

                    it 'Test should return false when one of the multiple driver version does not match' {
                        $testParms = [PrinterDriver]$testMultiplePresentParams

                        Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2WrongInf } -ParameterFilter { $name -eq 'myName2' }

                        $testParms.test() | Should -BeExactly $false

                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                        Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                        Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myNameWrong\myNameWrong.inf' -and $Online }
                    } # End it Test should return false when one of the multiple drivers does not exist
                } # end context multiple drivers
            } # End Context Type Test

            Context 'Test Ensure Absent' {
                it 'Test should return true when driver does not exist' {
                    $testParms = [PrinterDriver]$testAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }

                    $testParms.test() | Should -BeExactly $true

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 0 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Test should return true with single driver does not exist

                it 'Test should return true when all drivers do not exist' {
                    $testParms = [PrinterDriver]$testMultipleAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName2' }

                    $testParms.test() | Should -BeExactly $true

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 0 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Test should return true with single driver does not exist

                it 'Test should return true when all drivers do not exist with the purge option set' {
                    $testParms = [PrinterDriver]$testAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithoutPrinters }

                    $testParms.test() | Should -BeExactly $true

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                } # End it Test should return true when all drivers do not exist with the purge option set

                it 'Test should return false when the driver does not exist but still is in the driver store' {
                    $testParms = [PrinterDriver]$testAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }

                    $testParms.test() | Should -BeExactly $false

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                } # End it Test should return false when the driver does not exist but still is in the driver store

                it 'Test should return false when driver exists' {
                    $testParms = [PrinterDriver]$testAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter { $name -eq 'myName' }

                    $testParms.test() | Should -BeExactly $false

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 0 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Test should return true with single driver does not exist

                it 'Test should return false when one of the drivers exists' {
                    $testParms = [PrinterDriver]$testMultipleAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }

                    $testParms.test() | Should -BeExactly $false

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 0 -Exactly -Scope It -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                } # End it Test should return false when one of the drivers exists
            } # End Test Ensure Absent
        } # End Describe Test Method

        Describe 'Set Method' {
            BeforeEach {
                Mock -CommandName Get-PrinterDriver
                Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }
                Mock -CommandName Remove-PrinterDriver -ParameterFilter { $name -eq 'myName' }
                Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName1' }
                Mock -CommandName Remove-PrinterDriver  -ParameterFilter { $name -eq 'myName1' }
                Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName2' }
                Mock -CommandName Remove-PrinterDriver -ParameterFilter { $name -eq 'myName2' }
                Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $driver -eq 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf' -and $Online }
                Mock -CommandName Invoke-Command
                Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                Mock -CommandName Write-Warning
                Mock -CommandName Write-Error
                Mock -CommandName Add-PrinterDriver
            } # End BeforeEach

            Context 'Set Ensure Absent' {
                it 'Set should not find print driver' {
                    $setParms = [PrinterDriver]$testAbsentParams

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                } # End it Set should not find print driver

                it 'Set should not find print driver or a staged driver' {
                    $setParms = [PrinterDriver]$testAbsentPurgeParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithOutPrinters } -ParameterFilter { $Online -and $All }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                } # End it Set should not find print driver

                it 'Set should not find print drivers' {
                    $setParms = [PrinterDriver]$testMultipleAbsentParams

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                } # End it Set should not find print driver

                it 'Set should not find print drivers or a staged driver' {
                    $setParms = [PrinterDriver]$testMultipleAbsentPurgeParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithOutPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                } # End it Set should not find print driver

                it 'Set should find print driver and remove it' {
                    $setParms = [PrinterDriver]$testAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter { $name -eq 'myName' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                } # End it Set should not find print driver

                it 'Set should find print driver and staged driver then remove them' {
                    $setParms = [PrinterDriver]$testAbsentPurgeParams
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { return $successDriverRemoval }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                } # End it Set should not find print driver

                it 'Set should find print drivers and remove them' {
                    $setParms = [PrinterDriver]$testMultipleAbsentParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                } # End it Set should not find print driver

                it 'Set should find print drivers and staged driver then remove them' {
                    $setParms = [PrinterDriver]$testMultipleAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Mock -CommandName Invoke-Command -MockWith { return $successDriverRemoval }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                } # End it Set should not find print driver

                it 'Set should remove drivers but fail to remove driver from the driver store' {
                    $setParms = [PrinterDriver]$testMultipleAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Mock -CommandName Invoke-Command -MockWith { return '' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope it
                } # End it Set should not find print driver

                it 'Set should find print drivers and staged driver but not removed staged driver due to driver conflicts' {
                    $setParms = [PrinterDriver]$testMultipleAbsentPurgeParams

                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakePrintDriversWithSameINF }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName1 } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Remove-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 0 -Exactly -Scope It
                } # End it Set should find print drivers and staged driver but not removed staged driver due to driver conflicts
            } # End Set Ensure Absent

            Context 'Set Ensure Present' {
                AfterEach {
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
                }
                it 'Set should stage and add driver' {
                    $setParms = [PrinterDriver]$testPresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithOutPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Invoke-Command -MockWith { return $successDriverAdd }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                } # End it Set should not find print driver

                it 'Set should stage and replace print driver' {
                    $setParms = [PrinterDriver]$testPresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithOutPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakeMynameWrongInf } -ParameterFilter { $name -eq 'myName' }
                    Mock -CommandName Invoke-Command -MockWith { return $successDriverAdd }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                } # End it Set should stage and replace print driver

                it 'Set should only add the print driver' {
                    $setParms = [PrinterDriver]$testPresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 1 -Exactly -Scope It
                } # End it Set should only add the print driver

                it 'Set should add one of multiple print drivers' {
                    $setParms = [PrinterDriver]$testMultiplePresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $fakemyName2 } -ParameterFilter { $name -eq 'myName2' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 1 -Exactly -Scope It
                } # End it Set should add one of multiple print drivers

                it 'Set should add multiple print drivers' {
                    $setParms = [PrinterDriver]$testMultiplePresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyNameMultiple } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName1' }
                    Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $name -eq 'myName2' }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName1" }
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $name -eq "myName2" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 2 -Exactly -Scope It
                } # End it Set should add multiple print drivers

                it 'Set should fail to stage driver' {
                    $setParms = [PrinterDriver]$testPresentParams

                    Mock -CommandName Get-WindowsDriver -MockWith { return  $fakeWindowsDriversWithOutPrinters } -ParameterFilter { $Online -and $All }
                    Mock -CommandName Invoke-Command -MockWith { return $failureDriverAdd }
                    Mock -CommandName Write-Error -MockWith { }

                    { $setParms.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $name -eq "myName" }
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterDriver -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
                } # End it Set should not find print driver
            } # End Set Ensure Present
        } # End Describe Set Method

        Describe 'InstalledDriver Method' {
            it 'Should return null' {
                $absentParms = [PrinterDriver]$testPresentParams

                Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithoutPrinters }

                $absentParms.InstalledDriver() | Should be $null

                Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It
            }

            it 'Should return INF path' {
                $absentParms = [PrinterDriver]$testPresentParams

                Mock -CommandName Get-WindowsDriver -MockWith { return $windowsPrintDrivermyName } -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                Mock -CommandName Get-WindowsDriver -MockWith { return $fakeWindowsDriversWithPrinters }  -ParameterFilter { $Online -and $All }

                $installedDriver = $absentParms.InstalledDriver()
                $installedDriver.OriginalFileName | Should -BeExactly 'C:\WINDOWS\System32\DriverStore\FileRepository\myName\myName.inf'
                $installedDriver.Driver | Should -BeExactly 'oem10.inf'

                Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $Driver -eq 'oem10.inf' }
                Assert-MockCalled -CommandName Get-WindowsDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Online -and $All }
            }
        } # End Describe for InstalledDriver Method
    } # End InModuleScope
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
