[cmdletbinding()]
param ()

$Global:ModuleName = 'PrintManagementDsc'
$Global:DscResourceName = 'Printer'
# $VerbosePreference = 'Continue'
#region HEADER
# Unit Test Template Version: 1.1.0
[string] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:ModuleName `
    -DSCResourceName $Global:DscResourceName `
    -TestType Unit `
    -ResourceType Class
#end region HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope -ModuleName $Global:DscResourceName {
        $testPresentParams = @{
            Ensure         = [Ensure]::Present
            Name           = 'myPrinter'
            PortName       = 'myPrinterPort'
            DriverName     = 'myDriver'
            PortType       = 'TCPIP'
            Address        = 'printer.local'
            Shared         = $true
            PermissionSDDL = 'G:SYD:(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)'
        }
        $testPresentSNMPParams = $testPresentParams.clone()
        $testPresentSNMPParams.SNMPCommunity = 'public'
        $testPresentSNMPParams.SNMPIndex = 1
        $testPresentSNMPParams.Name = 'myPrinterSNMP'
        $testPresentSNMPParams.PortName = 'myPrinterPortSNMP'

        $testPresentLPRSNMPParams = $testPresentSNMPParams.clone()
        $testPresentLPRSNMPParams.PortType = 'LPR'
        $testPresentLPRSNMPParams.lprQueueName = 'fake'
        $testPresentLPRSNMPParams.Name = 'myLPRPrinterSNMP'
        $testPresentLPRSNMPParams.PortName = 'myLPRPrinterPortSNMP'

        $testPresentLPRParams = $testPresentParams.clone()
        $testPresentLPRParams.PortType = 'LPR'
        $testPresentLPRParams.lprQueueName = 'fake'
        $testPresentLPRParams.Name = 'myLPRPrinter'
        $testPresentLPRParams.PortName = 'myLPRPrinterPort'

        $testPresentPaperCutParams = $testPresentParams.clone()
        $testPresentPaperCutParams.Name = 'myPaperCutPrinter'
        $testPresentPaperCutParams.PortName = 'myPaperCutPrinterPort'
        $testPresentPaperCutParams.PortType = 'PaperCut'
        $testPresentPaperCutParams.Address = 'papercut.local'

        $testAbsentParams = $testPresentParams.clone()
        $testAbsentParams.Ensure = [Ensure]::Absent
        $testAbsentParams.Name = 'myAbsentPrinter'
        $testAbsentParams.PortName = 'myAbsentPrinterPort'

        # Region Mock Returns
        $myPrinter = @{
            Name           = 'myPrinter'
            PortName       = 'myPrinterPort'
            DriverName     = 'myDriver'
            Shared         = 'True'
            PermissionSDDL = 'G:SYD:(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)'
        }

        $myLPRPrinter = $myPrinter.clone()
        $myLPRPrinter.Name = 'myLPRPrinter'
        $myLPRPrinter.PortName = 'myLPRPrinterPort'

        $myPaperCutPrinter = $myPrinter.clone()
        $myPaperCutPrinter.Name = 'myPaperCutPrinter'
        $myPaperCutPrinter.PortName = 'myPaperCutPrinterPort'

        $myPrinterSNMP = $myPrinter.clone()
        $myPrinterSNMP.Name = 'myPrinterSNMP'
        $myPrinterSNMP.PortName = 'myPrinterPortSNMP'

        $myPrinterPort = @{
            Name               = 'myPrinterPort'
            Description        = 'Standard TCP/IP Port'
            PrinterHostAddress = 'printer.local'
            SNMPEnabled        = $false
            SNMPIndex          = 0
            SNMPCommunity      = ''
        }
        $myNewPrinterPort = $myPrinterPort.clone()
        $myNewPrinterPort.Name = 'newPrinterPort'

        $myPrinterPortCIM = @{
            Protocol = 1 # Port Check for TCPIP
        }
        $myLPRPrinterPortCIM = @{
            Protocol = 2 # Port Check for LPR
        }

        $myLPRPrinterPort = $myPrinterPort.clone()
        $myLPRPrinterPort.Name = 'myLPRPrinterPort'
        $myLPRPrinterPort.lprQueueName = 'fake'

        $myPaperCutPrinterPort = $myPrinterPort.clone()
        $myPaperCutPrinterPort.Name = 'myPaperCutPrinterPort'
        $myPaperCutPrinterPort.Description = 'PaperCut TCP/IP Port'
        $myPaperCutPrinterPort.PrinterHostAddress = ''

        $myPrinterPortSNMP = $myPrinterPort.clone()
        $myPrinterPortSNMP.Name = 'myPrinterPortSNMP'
        $myPrinterPortSNMP.SNMPCommunity = 'public'
        $myPrinterPortSNMP.SNMPIndex = 1

        $myBadPortName = $myPrinterPort.clone()
        $myBadPortName.Name = 'myBadPortName'

        $testPaperCutRegistryItem = @{
            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort'
        }
        $testPaperCutRegistryItemProperty = @{
            HostName = 'papercut.local'
        }

        $myDriver = @{
            Name               = 'myDriver'
            PrinterEnvironment = 'Windows x64'
            MajorVersion       = '3'
        }
        $newDriver = @{
            Name               = 'newDriver'
            PrinterEnvironment = 'Windows x64'
            MajorVersion       = '3'
        }

        $myPrintJobs = @(
            [System.Collections.Hashtable]@{
                ID           = '1'
                PrinterName  = 'myPrinter'
                DocumentName = 'job1'
            },
            [System.Collections.Hashtable]@{
                ID           = '2'
                PrinterName  = 'myPrinter'
                DocumentName = 'job2'
            }
        ) # end myPrintJobs

        # End Region
        function Get-ItemProperty
        {
            [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path )
        }
        function Remove-PrintJob
        {
            [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $InputObject )
        }
        function Remove-PrinterPort
        {
            [Cmdletbinding()] param ( [Parameter] $name )
        }
        function Add-PrinterPort
        {
        }
        function Remove-PrinterPort
        {
        }
        function Set-WmiInstance
        {
            [CmdletBinding()] param (
                [Parameter(ValueFromPipeline = $true)] $InputObject,
                [Parameter()] [hashtable]$Arguments,
                [Parameter()] $PutType )
        }

        Describe 'Test Method' {
            BeforeEach {
                Mock -CommandName Get-Printer -ParameterFilter { Write-Warning -Message "Unmocked Name: $Name" }
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter { $Name -eq 'myLPRPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter { $Name -eq 'myPaperCutPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Get-PrinterPort -ParameterFilter { Write-Warning -Message "Unmocked Port Name: $Name" }
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter { $Name -eq 'myPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter { $Name -eq 'myLPRPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter { $Name -eq 'myPaperCutPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter { $Name -eq 'myBadPortName' }

                Mock -CommandName Get-Item -ParameterFilter {Write-Warning -Message "Unmocked Path: $Path"}
                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort" }

                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }
            }

            Context 'Type Test' {
                it 'Should return a bool' {
                    $testParams = [Printer]$testPresentParams

                    $testParams.test() | Should -BeOfType bool
                }
            }

            Context 'Ensure Absent' {
                it 'Should return true when printer is absent' {
                    $testParams = [Printer]$testAbsentParams

                    $testParams.test() | should be $true

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                }
                it "Should return false when printer is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = $testPresentParams.Name

                    $testParams.test() | Should -Be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' }
                }
                it "Should return false when printer and port is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = $testPresentParams.Name
                    $testParams.PortName = $testPresentParams.PortName

                    $testParams.test() | Should -Be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPort' }
                }
                it "Should return false when printer is absent and the printer port is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.PortName = $testPresentParams.PortName

                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPort' }
                }
            }

            Context 'Ensure Present' {
                it 'Should return true when printer is present' {
                    $testParams = [Printer]$testPresentParams

                    $testParams.test() | Should -Be $true
                }

                it 'Should return false when printer is present and port is absent' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.PortName = 'myBadPortName'

                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myBadPortName' }
                }

                it 'Should return false when printer is absent and the port is present' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.Name = 'myAbsentPrinter'

                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                }
            }

            Context 'Ensure Correct Settings' {
                it 'Should return true when all printer settings are correct' {
                    $testParams = [Printer]$testPresentParams

                    $testParams.test() | Should -be $true
                }

                it 'Should return false when PortName is incorrect and does not exist' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.PortName = 'myAbsentPrinterPort'

                    $testParams.test() | Should -be $false

                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                }

                it 'Should return false when PortName is incorrect' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.PortName = 'myBadPortName'

                    $testParams.test() | Should -be $false

                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myBadPortName' }
                }

                it 'Should return false when DriverName is incorrect' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.DriverName = 'myBadDriverName'

                    $testParams.test() | Should -be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' }
                }

                it 'Should return false when the printer is not shared' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.Shared = $false

                    $testParams.test() | Should be $false
                }

                it 'Should return false when PermissionSDDL is incorrect' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.PermissionSDDL = 'bad perms'

                    $testParams.test() | Should be $false
                }

                it 'Should return true when SNMPIndex is set but SNMPCommunity is not' {
                    $testParams = [Printer]$testPresentSNMPParams
                    $testParams.SNMPIndex = '12'
                    $testParams.SNMPCommunity = ''

                    $testParams.test() | Should be $true

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                }

                it 'Should return false when the printer has incorrect SNMPCommunity settings' {
                    $testParams = [Printer]$testPresentSNMPParams
                    $testParams.SNMPCommunity = 'private'
                    $testParams.SNMPIndex = '1'

                    $testParams.test() | Should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                }

                it 'Should return false when the printer has incorrect SNMPIndex setting' {
                    $testParams = [Printer]$testPresentSNMPParams
                    $testParams.SNMPIndex = '123'
                    $testParams.SNMPCommunity = 'public'

                    $testParams.test() | Should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                }

                it 'Should return false when the printer has incorrect lprQueueName settings' {
                    $testParams = [Printer]$testPresentLPRParams
                    $testParams.lprQueueName = 'badQueueName'

                    $testParams.test() | Should be $false
                }

                it 'Should return true when all printer settings are correct for a printer using LPR queue name' {
                    $testParams = [Printer]$testPresentLPRParams

                    $testParams.test() | Should be $true
                }

                it 'Should return false when printer has the incorrect Address set for a LPR Port' {
                    $testParams = [Printer]$testPresentLPRParams
                    $testParams.Address = 'badAddress.local'

                    $testParams.test() | Should be $false
                }

                it 'Should return false when printer has the incorrect Address set for a TCPIP Port' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.Address = 'badAddress.local'

                    $testParams.test() | Should be $false
                }

                it 'Should return false when printer has the incorrect Address set for a PaperCut Port' {
                    $testParams = [Printer]$testPresentPaperCutParams
                    $testParams.Address = 'badAddress.local'

                    $testParams.test() | Should be $false
                }
            } # end context ensure correct settings
        } # end describe test method
        Describe 'Get Method' {
            BeforeEach {
                Mock -CommandName Get-Printer -ParameterFilter { Write-Warning -Message "Unmocked Name: $Name" }
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter { $Name -eq 'myLPRPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter { $Name -eq 'myPaperCutPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Get-PrinterPort -ParameterFilter { Write-Warning -Message "Unmocked PrintPort Name: $Name" }
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter { $Name -eq 'myPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter { $Name -eq 'myLPRPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter { $Name -eq 'myPaperCutPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter { $Name -eq 'myBadPortName' }

                Mock -CommandName Get-Item -ParameterFilter { Write-Warning -Message "Unmocked Get-Item Path: $Path"}
                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort" }
                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }
            }
            Context "Get type" {
                it 'Should return Printer object' {
                    $getParams = [Printer]$testPresentParams

                    $getParams.Get().GetType().Name | Should -Be 'Printer'
                } # End it
            } # End Context Get type

            Context "Get Ensure Absent" {
                It 'Should return Absent if the printer does not exist' {
                    $getParams = [Printer]$testAbsentParams

                    $getParams.Get().Ensure | Should -be 'Absent'

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                } # End It

                It 'Should return Absent if the printerPort does not exist' {
                    $getParams = [Printer]$testAbsentParams
                    $getParams.Name = $testPresentParams.Name

                    $getParams.Get().Ensure | Should -be 'Absent'

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq $testPresentParams.Name }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq $testAbsentParams.PortName }
                } # End It
            } # End Context Get Ensure Absent

            Context "Get Printer Settings" {

                it 'Should return correct properties for a printer using a RAW port' {
                    $getParams = [Printer]$testPresentParams

                    $returnObject = $getParams.Get()

                    $returnObject.Ensure | Should -be $testPresentParams.Ensure
                    $returnObject.DriverName | Should -be $testPresentParams.DriverName
                    $returnObject.Shared | Should -be $testPresentParams.Shared
                    $returnObject.PermissionSDDL | Should -be $testPresentParams.PermissionSDDL
                    $returnObject.PortName | Should -be $testPresentParams.PortName
                    $returnObject.Address | Should -be $testPresentParams.Address
                    $returnObject.SNMPCommunity | Should -BeNullOrEmpty
                    $returnObject.SNMPIndex | Should -BeExactly 0 # not enabled always returns 0
                    $returnObject.lprQueueName | Should -BeNullOrEmpty
                }

                it 'Should return correct properties for a printer using a LPR port' {
                    $getParams = [Printer]$testPresentLPRParams

                    $returnObject = $getParams.Get()

                    $returnObject.Ensure | Should -be $testPresentLPRParams.Ensure
                    $returnObject.DriverName | Should -be $testPresentLPRParams.DriverName
                    $returnObject.Shared | Should -be $testPresentLPRParams.Shared
                    $returnObject.PermissionSDDL | Should -be $testPresentLPRParams.PermissionSDDL
                    $returnObject.PortName | Should -be $testPresentLPRParams.PortName
                    $returnObject.Address | Should -be $testPresentLPRParams.Address
                    $returnObject.SNMPCommunity | Should -BeNullOrEmpty
                    $returnObject.SNMPIndex | Should -BeExactly 0 # not enabled always returns 0
                    $returnObject.lprQueueName | Should -be $testPresentLPRParams.lprQueueName
                }

                it 'Should return correct properties for a printer using a Papercut port' {
                    $getParams = [Printer]$testPresentPaperCutParams

                    $returnObject = $getParams.Get()

                    $returnObject.Ensure | Should -Be $testPresentPaperCutParams.Ensure
                    $returnObject.DriverName | Should -Be $testPresentPaperCutParams.DriverName
                    $returnObject.Shared | Should -Be $testPresentPaperCutParams.Shared
                    $returnObject.PermissionSDDL | Should -Be $testPresentPaperCutParams.PermissionSDDL
                    $returnObject.PortName | Should -Be $testPresentPaperCutParams.PortName
                    $returnObject.Address | Should -Be $testPresentPaperCutParams.Address
                    $returnObject.SNMPCommunity | Should -BeNullOrEmpty
                    $returnObject.SNMPIndex | Should -BeExactly 0 # not enabled always returns 0
                    $returnObject.lprQueueName | Should -BeNullOrEmpty
                }
            }
        }
        Describe 'Set Method' {
            BeforeEach {
                Mock -CommandName Add-Printer -ParameterFilter { Write-Warning -Message "Unmocked Add-Printer Name: $Name " }
                Mock -CommandName Add-Printer -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Add-Printer -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Set-Printer -ParameterFilter { Write-Warning -Message "Unmocked Set-Printer - Name: $Name - Port: $PortName - DriverName: $DriverName"}
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'myAbsentPrinterPort' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $DriverName -eq 'myDriver' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $Shared -eq $false }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PermissionSDDL -eq 'badPerms' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'myAbsentPrinterPort' }

                Mock -CommandName Remove-Printer
                Mock -CommandName Remove-PrinterPort
                Mock -CommandName Add-PrinterPort

                Mock -CommandName Get-Printer -ParameterFilter { Write-Warning -Message "Unmocked Name: $Name" }
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter { $Name -eq 'myLPRPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter { $Name -eq 'myPaperCutPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter { $Name -eq 'myPrinterSNMP' }
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Get-PrinterPort -ParameterFilter { Write-Warning -Message "Unmocked PrintPort Name: $Name" }
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter { $Name -eq 'myPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter { $Name -eq 'myLPRPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter { $Name -eq 'myPaperCutPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter { $Name -eq 'myPrinterPortSNMP' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter { $Name -eq 'myBadPortName' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myNewPrinterPort } -ParameterFilter { $Name -eq 'newPrinterPort' }

                Mock -CommandName Get-PrinterDriver -ParameterFilter { Write-Warning -Message "Unmocked Driver Name: $Name" }
                Mock -CommandName Get-PrinterDriver -MockWith { return $myDriver } -ParameterFilter { $Name -eq 'myDriver' }
                Mock -CommandName Get-PrinterDriver -MockWith { return $newDriver } -ParameterFilter { $Name -eq 'newDriver' }
                Mock -CommandName Get-PrinterDriver -MockWith { throw } -ParameterFilter { $Name -eq 'badDriver' }

                Mock -CommandName Get-PrintJob
                Mock -CommandName Remove-PrintJob

                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort" }
                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }

                Mock -CommandName Get-CimInstance -ParameterFilter { Write-Warning "Unmocked Get-CimInstance $Query" }
                Mock -CommandName Get-CimInstance -MockWith { return $myPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myPrinterPort'" }
                Mock -CommandName Get-CimInstance -MockWith { return $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myLPRPrinterPort'" }
                Mock -CommandName Get-CimInstance -MockWith { return $myPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'newPrinterPort'" }

                Mock -CommandName Invoke-Command
                Mock -CommandName Restart-Service
                Mock -CommandName Get-WmiObject
                Mock -CommandName Set-WmiInstance
                Mock -CommandName Write-Error
            } # end before each

            Context 'Ensure Present' {
                it 'Should add a new printer and use an existing port' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Name = $testAbsentParams.Name

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myPrinterPort'" }
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                }

                it 'Should add a new printerPort and re-assign the printer to use it' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.PortName = $testAbsentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'myAbsentPrinterPort' }
                }

                it 'PaperCut Port is created' {
                    $setParams = [Printer]$testPresentPaperCutParams
                    $setParams.PortName = $testAbsentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }

                it 'New Printer and PrinterPort should be created' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Name = $testAbsentParams.Name
                    $setParams.PortName = $testAbsentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }

                it 'Should handle Add-Printer throwing an error' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Name = $testAbsentParams.Name
                    $setParams.PortName = $testAbsentParams.PortName

                    Mock -CommandName Add-Printer -MockWith { throw [System.ArgumentException]::new("Cannot run command") } -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                    { $setParams.set() } | Should -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }

                it 'New Printer and PrinterPort should be created with SNMP enabled' {
                    $setParams = [Printer]$testPresentSNMPParams
                    $setParams.Name = $testAbsentParams.Name
                    $setParams.PortName = $testAbsentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }

                it 'New Printer and PrinterPort should be created with SNMP enabled for a LPR Port' {
                    $setParams = [Printer]$testPresentLPRSNMPParams
                    $setParams.Name = $testAbsentParams.Name
                    $setParams.PortName = $testAbsentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }

                it 'A Printer and PrinterPort should not be created' {
                    $setParams = [Printer]$testPresentParams

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }

                it 'A Printer should not be created due to the print driver missing' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Name = $testAbsentParams.Name
                    $setParams.DriverName = 'badDriver'

                    { $setParams.set() } | Should -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
                }

            } # end context ensure present

            Context 'Ensure Absent' {
                it 'Should remove a Printer' {
                    $setParams = [Printer]$testAbsentParams
                    $setParams.Name = $testPresentParams.Name

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver' }
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                }

                it 'Should remove a Printer and 2 PrintJobs in the queue' {
                    Mock -CommandName Get-PrintJob -MockWith { return $myPrintJobs }

                    $setParams = [Printer]$testAbsentParams
                    $setParams.Name = $testPresentParams.Name

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrintJob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 2 -Exactly -Scope It
                }

                it 'Should only remove a Printer Port' {
                    $setParams = [Printer]$testAbsentParams
                    $setParams.PortName = $testPresentParams.PortName

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 0 -Exactly -Scope It
                }

                it 'Should fail to remove the printer port, restart the spooler service and removes the printer port again' {
                    Mock -CommandName Remove-PrinterPort -MockWith {
                        if (-not $executed)
                        {
                            $executed = $true
                            throw
                        }
                    } # end mock Remove-PrinterPort

                    $setParams = [Printer]$testAbsentParams
                    $setParams.PortName = $testPresentParams.PortName

                    { $setParams.set() } | Should -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            } # end context ensure absent

            Context 'Update Printer Settings' {
                it 'Should update printer driver' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.DriverName = 'newDriver'

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $DriverName -eq 'newDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }
                it 'Should fail to update printer driver that does not exist' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.DriverName = 'badDriver'

                    { $setParams.set() } | Should -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $DriverName -eq 'newDriver' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0 -Exactly -Scope It
                }

                it 'Should update printer shared status' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Shared = $false

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $Shared -eq $false }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }

                it 'Should update printer PermissionSDDL' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.PermissionSDDL = 'badPerms'

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PermissionSDDL -eq 'badPerms' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }

                it 'Should update printer PortName' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.PortName = 'newPrinterPort'

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrintJob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'newPrinterPort' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }

                it 'Should update printer PortName with queued PrintJobs' {
                    Mock -CommandName Get-PrintJob -MockWith { return $myPrintJobs }

                    $setParams = [Printer]$testPresentParams
                    $setParams.PortName = 'newPrinterPort'

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrintJob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'newPrinterPort' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }
            } # end context Update Printer Settings

            Context 'Convert PortType' {
                BeforeEach {
                    Mock -CommandName Get-Random -MockWith { return 1 }
                    Mock -CommandName Remove-Item
                    Mock -CommandName Get-CimInstance -ParameterFilter { $Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111") }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance
                }

                AfterEach {
                    # Checking the printer queue prior to modifying the port. Pending jobs will result in a failure
                    Assert-MockCalled -CommandName Get-PrintJob -Times 1 -Exactly -Scope It

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It

                    # Printer already exists, just need to modify the port type
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It

                    # No print jobs are queued, so we expect the module to not try remove any
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                }

                it 'Convert PortType PaperCut -> LPR' {
                    $setParams = [Printer]$testPresentLPRParams

                    # returning a Papercut Port
                    Mock -CommandName Get-CimInstance -MockWith { $myPaperCutPrinterPort } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    { $setParams.set() } | Should -Not -Throw

                    # Getting the port type and one for use on useTempPort()
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111") }

                    # Jobs are found, they are removed to prevent failure
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It

                    # Changes the port to a temp port so the new one can be created with the desired name
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It

                    # PaperCut port is deleted from the registry and restarts the spooler
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It

                    # Removes the temp port
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                }

                it 'Convert PortType PaperCut -> TCPIP' {
                    $setParams = [Printer]$testPresentParams

                    # returning a Papercut Port
                    Mock -CommandName Get-CimInstance -MockWith { $myPaperCutPrinterPort } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    { $setParams.set() } | Should -Not -Throw

                    # Getting the port type and one for use on useTempPort()
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111") }

                    # Jobs are found, they are removed to prevent failure
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It

                    # Changes the port to a temp port so the new one can be created with the desired name
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It

                    # Removes the temp port
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It

                    # PaperCut port is deleted from the registry and restarts the spooler
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }

                it 'Convert PortType LPR -> TCPIP' {
                    $setParams = [Printer]$testPresentParams

                    # returning a Papercut Port
                    Mock -CommandName Get-CimInstance -MockWith { $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myLPRPrinterPort }

                    { $setParams.set() } | Should -Not -Throw

                    # Converting LPR to TCPIP does not require a new port created
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is. Then using WMI change it TCPIP
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }

                it 'Convert PortType LPR -> PaperCut' {
                    $setParams = [Printer]$testPresentPaperCutParams

                    Mock -CommandName Get-CimInstance -MockWith { $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    { $setParams.set() } | Should -Not -Throw

                    # a temp port is created while a PaperCut port is created to replace it
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It

                    # temp port and LPR port get removed
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # used in createPaperCutPort()
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }

                it 'Convert PortType TCPIP -> LPR' {
                    $setParams = [Printer]$testPresentLPRParams

                    Mock -CommandName Get-CimInstance -MockWith { $myPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Converting TCPIP to LPR does not require a new port created
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is. Then using WMI change it TCPIP
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }

                it 'Convert PortType TCPIP -> PaperCut' {
                    $setParams = [Printer]$testPresentPaperCutParams

                    Mock -CommandName Get-CimInstance -MockWith { $myPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Converting TCPIP to Papercut port requires a temp port to be created and the temp port and existing TCPIP port to be removed
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It

                    # Need to figure out what type of port it is.
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # used in createPaperCutPort()
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            } # End Context Convert PortType
            Context 'Update Port Settings' {
                AfterEach {
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It

                    # Printer exists and does not need to be created
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                }

                it 'Should update PaperCut Port Address' {
                    $setParams = [Printer]$testPresentPaperCutParams
                    $setParams.Address = 'new-address.local'

                    Mock -CommandName Get-CimInstance -MockWith { $myPaperCutPrinterPort } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    { $setParams.set() } | Should -Not -Throw

                    # No need to change printer ports as it is justing updating a value in the registry
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Used to determine if the address is correct
                    Assert-MockCalled -CommandName Get-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -Times 1 -Exactly -Scope It

                    # Used when updating the address
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Should update PaperCut Port Address even it cannot read the registry' {
                    $setParams = [Printer]$testPresentPaperCutParams
                    $setParams.Address = 'new-address.local'

                    Mock -CommandName Get-CimInstance -MockWith { $myPaperCutPrinterPort } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-ItemProperty -MockWith { throw }

                    { $setParams.set() } | Should -Not -Throw

                    # No need to change printer ports as it is justing updating a value in the registry
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Used to determine if the address is correct
                    Assert-MockCalled -CommandName Get-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -Times 1 -Exactly -Scope It

                    # Used when updating the address
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }

                it 'Should update LPR Port Address' {
                    $setParams = [Printer]$testPresentLPRParams
                    $setParams.Address = 'new-address.local'

                    Mock -CommandName Get-CimInstance -MockWith { $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myLPRPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Port properties will be modified, no new ports are needed
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Update the WMI object with the new address
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address

                it 'Should update LPR Port lprQueueName' {
                    $setParams = [Printer]$testPresentLPRParams
                    $setParams.lprQueueName = 'newQueue.local'

                    Mock -CommandName Get-CimInstance -MockWith { $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myLPRPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Port properties will be modified, no new ports are needed
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Update the WMI object with the new address
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address

                it 'Should update LPR/TCPIP Port SNMPCommunity' {
                    $setParams = [Printer]$testPresentSNMPParams
                    $setParams.SNMPCommunity = 'private'

                    Mock -CommandName Get-CimInstance -MockWith { $myPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Port properties will be modified, no new ports are needed
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Update the WMI object with the new address
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR/TCPIP Port SNMPCommunity

                it 'Should update LPR/TCPIP Port SNMPIndex' {
                    $setParams = [Printer]$testPresentSNMPParams
                    $setParams.SNMPIndex = 2

                    Mock -CommandName Get-CimInstance -MockWith { $myPrinterPortCIM } -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }
                    Mock -CommandName Get-WmiObject -MockWith { $myPrinterPortCIM }

                    { $setParams.set() } | Should -Not -Throw

                    # Port properties will be modified, no new ports are needed
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It

                    # Need to figure out what type of port it is
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $setParams.PortName) }

                    # Update the WMI object with the new address
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR/TCPIP Port SNMPIndex
            } # End Context Update Port Settings
        } # End Describe Set Method
        Describe 'UseTempPort Method' {
            BeforeEach {
                Mock -CommandName Add-PrinterPort -ParameterFilter {Write-Warning -Message "Adding PaperCutPort with Name : $Name"}
                Mock -CommandName Set-Printer -ParameterFilter { Write-Warning -Message "Setting Printer : $PortName" }
            }

            it 'Should create port with name 111111111' {
                $useTempPortParams = [Printer]$testPresentParams

                Mock -CommandName Get-Random -MockWith { return 1 }
                Mock -CommandName Get-CimInstance -MockWith { return $null } #-ParameterFilter { $Query -eq "Select Name From Win32_TCPIpPrinterPort WHERE Name = '111111111'" }

                $useTempPortParams.useTempPort() | Should -Be '111111111'
            }

            it 'Should create port with name 222222222' {
                $useTempPortParams = [Printer]$testPresentParams

                $script:mockCounter = 1
                Mock -CommandName Get-Random -MockWith {
                    if ($script:mockCounter -le 9)
                    {
                        $script:mockCounter++
                        return 1
                    }
                    else
                    {
                        $script:mockCounter++
                        return 2
                    }
                }

                Mock -CommandName Get-CimInstance -MockWith { return $myPrinterPortCIM } -ParameterFilter { $Query -eq "Select Name From Win32_TCPIpPrinterPort WHERE Name = '111111111'" }
                Mock -CommandName Get-CimInstance -MockWith { return $null } -ParameterFilter { $Query -eq "Select Name From Win32_TCPIpPrinterPort WHERE Name = '222222222'" }

                $useTempPortParams.useTempPort() | Should -Be '222222222'

                Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq "Select Name From Win32_TCPIpPrinterPort WHERE Name = '111111111'" }
                Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter { $Query -eq "Select Name From Win32_TCPIpPrinterPort WHERE Name = '222222222'" }
            }
        } # End UseTempPort Method
    } # End InModuleScope
} # End try
finally
{
    # region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    # end region
}
