[cmdletbinding()]
Param()

$Global:ModuleName = 'PrintManagementDsc'
$Global:DscResourceName = 'Printer'

#region HEADER
# Unit Test Template Version: 1.1.0
[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\PrintManagementDsc'
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
#endregion HEADER
$VerbosePreference = "Continue"
# Begin Testing
try {
    #region Pester Tests
    InModuleScope -ModuleName $Global:DscResourceName  {
        $testPresentParams = @{
            Ensure = [Ensure]::Present
            Name = 'myPrinter'
            PortName = 'myPrinterPort'
            DriverName = 'myDriver'
            PortType = 'TCPIP'
            Address = 'printer.local'
            Shared = $true
            PermissionSDDL = 'G:SYD:(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)'
        }
        $testPresentSNMPParams = $testPresentParams.clone()
        $testPresentSNMPParams.SNMPCommunity = 'public'
        $testPresentSNMPParams.SNMPIndex = 1
        $testPresentSNMPParams.Name = 'myPrinterSNMP'
        $testPresentSNMPParams.PortName = 'myPrinterPortSNMP'

        $testPresentLPRParams = $testPresentParams.clone()
        $testPresentLPRParams.PortType = 'LPR'
        $testPresentLPRParams.lprQueueName = 'fake'
        $testPresentLPRParams.Name = 'myLPRPrinter'
        $testPresentLPRParams.PortName = 'myLPRPrinterPort'

        $testPresentPaperCutParams = $testPresentParams.clone()
        $testPresentPaperCutParams.Name = 'myPaperCutPrinter'
        $testPresentPaperCutParams.PortName ='myPaperCutPrinterPort'
        $testPresentPaperCutParams.PortType = 'PaperCut'
        $testPresentPaperCutParams.Address = 'papercut.local'

        $testAbsentParams = $testPresentParams.clone()
        $testAbsentParams.Ensure = [Ensure]::Absent
        $testAbsentParams.Name = 'myAbsentPrinter'
        $testAbsentParams.PortName = 'myAbsentPrinterPort'

        # Region Mock Returns
        $myPrinter = @{
            Name = 'myPrinter'
            PortName = 'myPrinterPort'
            DriverName = 'myDriver'
            Shared = 'True'
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
            Name = 'myPrinterPort'
            Description = 'Standard TCP/IP Port'
            PrinterHostAddress = 'printer.local'
            SNMPEnabled = $false
            SNMPIndex = 0
            SNMPCommunity = ''
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
        $myPrinterPortSNMP.SNMPEnabled = $true
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
            Name = 'myDriver'
            PrinterEnvironment = 'Windows x64'
            MajorVersion = '3'
        }
        $newDriver = @{
            Name = 'newDriver'
            PrinterEnvironment = 'Windows x64'
            MajorVersion = '3'
        }

        $myPrintJobs = @(
            [System.Collections.Hashtable]@{
                ID = '1'
                PrinterName = 'myPrinter'
                DocumentName = 'job1'
            },
            [System.Collections.Hashtable]@{
                ID = '2'
                PrinterName = 'myPrinter'
                DocumentName = 'job2'
            }
        ) # end myprintjobs

        # End Region
        Describe 'Test Method'{
            BeforeEach {
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter {$Name -eq 'myPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter {$Name -eq 'myLPRPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter {$Name -eq 'myPaperCutPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter {$Name -eq 'myPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter {$Name -eq 'myLPRPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter {$Name -eq 'myPaperCutPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter {$Name -eq 'myBadPortName'}
    
                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort"}
                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }
            }
            AfterEach {
                
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

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinterPort'}
                }
                it "Should return false when printer is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = $testPresentParams.Name

                    $testParams.test() | Should -Be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                }
                it "Should return false when printer and port is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = $testPresentParams.Name
                    $testParams.PortName = $testPresentParams.PortName

                    $testParams.test() | Should -Be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPort'}
                }
                it "Should return false when printer is absent and the printer port is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.PortName = $testPresentParams.PortName
                    
                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPort'}
                }
            }

            Context 'Ensure Present' {
                it 'Should return true when printer is present' {
                    $testParams = [Printer]$testPresentParams
                    
                    $testParams.test() | Should -Be $true
                }

                it 'Should return false when printer is present and port is absent' {
                    $testParams = [Printer]$testPresentParams
                    $testparams.PortName = 'myBadPortName'

                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myBadPortName'}
                }

                it 'Should return false when printer is absent and the port is present' {
                    $testParams = [Printer]$testPresentParams
                    $testparams.Name = 'myAbsentPrinter'

                    $testParams.test() | should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                }
            }

            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
            Context 'Ensure Correct Settings' {
                it 'Should return true when all printer settings are correct' {
                    $testparams = [Printer]$testPresentParams

                    $testparams.test() | Should -be $true
                }

                it 'Should return false when PortName is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.PortName = 'myBadPortName'

                    $testparams.test() | Should -be $false
                    
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myBadPortName'}   
                }

                it 'Should return false when DriverName is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.DriverName = 'myBadDriverName'

                    $testparams.test() | Should -be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                }

                it 'Should return false when the printer is not shared' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.Shared = $false

                    $testparams.test() | Should be $false
                }

                it 'Should return false when PermissionSDDL is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.PermissionSDDL = 'bad perms'
   
                    $testparams.test() | Should be $false
                }

                it 'Should return true when SNMPIndex is set but SNMPCommunity is not' {
                    $testparams = [Printer]$testPresentSNMPParams
                    $testparams.SNMPIndex = '12'
                    $testparams.SNMPCommunity = ''

                    $testparams.test() | Should be $true

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                }

                it 'Should return false when the printer has incorrect SNMPCommunity settings' {
                    $testparams = [Printer]$testPresentSNMPParams
                    $testparams.SNMPCommunity = 'private'
                    $testparams.SNMPIndex = '1'

                    $testparams.test() | Should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                }

                it 'Should return false when the printer has incorrect SNMPIndex setting' {
                    $testparams = [Printer]$testPresentSNMPParams
                    $testparams.SNMPIndex = '123'
                    $testparams.SNMPCommunity = 'public'

                    $testparams.test() | Should be $false

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                }

                it 'Should return false when the printer has incorrect lprQueueName settings' {
                    $testparams = [Printer]$testPresentLPRParams
                    $testparams.lprQueueName = 'badQueueName'

                    $testparams.test() | Should be $false
                }

                it 'Should return true when all printer settings are correct for a printer using LPR queue name' {
                    $testparams = [Printer]$testPresentLPRParams

                    $testparams.test() | Should be $true
                }

                it 'Should return false when printer has the incorrect Address set for a LPR Port' {
                    $testparams = [Printer]$testPresentLPRParams
                    $testparams.Address = 'badAddress.local'

                    $testparams.test() | Should be $false
                }

                it 'Should return false when printer has the incorrect Address set for a TCPIP Port' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.Address = 'badAddress.local'

                    $testparams.test() | Should be $false
                }

                it 'Should return false when printer has the incorrect Address set for a PaperCut Port' {
                    $testparams = [Printer]$testPresentPaperCutParams
                    $testparams.Address = 'badAddress.local'

                    $testparams.test() | Should be $false
                }
            } # end context ensure correct settings
        } # end describe test method
        Describe 'Get Method' {
            BeforeEach {
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter {$Name -eq 'myPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter {$Name -eq 'myLPRPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter {$Name -eq 'myPaperCutPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter {$Name -eq 'myPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter {$Name -eq 'myLPRPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter {$Name -eq 'myPaperCutPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter {$Name -eq 'myBadPortName'}
    
                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort"}
                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }
            }
            Context "Get type" {
                it 'Get should return Printer object' {
                    $getParams = [Printer]$testPresentParams

                    $getParams.Get().GetType().Name | Should -Be 'Printer'
                } # End it
            } # End Context Get type

            Context "Get Ensure Absent" {
                It 'Get should return Absent if the printer does not exist' {
                    $getParams = [Printer]$testAbsentParams

                    $getParams.Get().Ensure | Should -be 'Absent'

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                } # End It

                It 'Get should return Absent if the printerPort does not exist' {
                    $getParams = [Printer]$testAbsentParams
                    $getParams.Name = $testPresentParams.Name

                    $getParams.Get().Ensure | Should -be 'Absent'

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq $testPresentParams.Name}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq $testAbsentParams.PortName}
                } # End It
            } # End Context Get Ensure Absent

            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
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
        Describe 'Set Method'{
            Function Remove-PrintJob { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $InputObject ) }
            Function Remove-PrinterPort { [Cmdletbinding()] param($name) }
            Function Add-PrinterPort { }
            Function Remove-PrinterPort { }
            Function Set-WmiInstance { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $InputObject,$Arguments,$PutType ) }

            BeforeEach {
                Mock -CommandName Add-Printer -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Add-Printer -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Set-Printer
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'myAbsentPrinterPort' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $DriverName -eq 'myDriver' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $Shared -eq $false }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PermissionSDDL -eq 'badperms' }
                Mock -CommandName Set-Printer -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'myAbsentPrinterPort' }

                Mock -CommandName Remove-Printer
                Mock -CommandName Remove-PrinterPort
                Mock -CommandName Add-PrinterPort

                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter { $Name -eq 'myPrinter' }
                Mock -CommandName Get-Printer -MockWith { return $myLPRPrinter } -ParameterFilter {$Name -eq 'myLPRPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPaperCutPrinter } -ParameterFilter {$Name -eq 'myPaperCutPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPrinterSNMP } -ParameterFilter {$Name -eq 'myPrinterSNMP'}
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinter' }

                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter { $Name -eq 'myAbsentPrinterPort' }
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter {$Name -eq 'myPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myLPRPrinterPort } -ParameterFilter {$Name -eq 'myLPRPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPaperCutPrinterPort } -ParameterFilter {$Name -eq 'myPaperCutPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortSNMP } -ParameterFilter {$Name -eq 'myPrinterPortSNMP'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter {$Name -eq 'myBadPortName'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myNewPrinterPort } -ParameterFilter {$Name -eq 'newPrinterPort'}

                Mock -CommandName Get-PrinterDriver -MockWith { return $myDriver } -ParameterFilter { $Name -eq 'myDriver'}
                Mock -CommandName Get-PrinterDriver -MockWith { return $newDriver } -ParameterFilter { $Name -eq 'newDriver'}

                Mock -CommandName Get-PrintJob
                Mock -CommandName Remove-PrintJob

                Mock -CommandName Get-Item -MockWith { return $testPaperCutRegistryItem } -ParameterFilter { $Path -eq "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPaperCutPrinterPort"}
                Mock -CommandName Get-ItemProperty -MockWith { return $testPaperCutRegistryItemProperty }
                Mock -CommandName Get-CimInstance -MockWith { return $myPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myPrinterPort'"}
                Mock -CommandName Get-CimInstance -MockWith { return $myLPRPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myLPRPrinterPort'"}
                Mock -CommandName Get-CimInstance -MockWith { return $myPrinterPortCIM } -ParameterFilter { $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'newPrinterPort'"}

                Mock -CommandName Invoke-Command
                Mock -CommandName Restart-Service
                Mock -CommandName Get-WmiObject
            } # end beforeeach

            Context 'Ensure Present' {                
                it 'Should add a new printer and use an existing port' {
                    $setParams = [Printer]$testPresentParams
                    $setParams.Name = $testAbsentParams.Name

                    { $setParams.set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myAbsentPrinter' }
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinterPort' }
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver'}
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter{ $Query -eq "Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = 'myPrinterPort'"}
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
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver'}
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
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver'}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
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
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 0 -Exactly -Scope It -ParameterFilter { $Name -eq 'myDriver'}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                }

                it 'Should remove a Printer and 2 printjobs in the queue' {
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
                        if(-not $executed) {
                            $executed = $true
                            throw
                        }
                    } # end mock remove-printerport

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
                    $setParams.PermissionSDDL = 'badperms'

                    { $setParams.set() } | Should -Not -Throw                  

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PermissionSDDL -eq 'badperms' }
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
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'newPrinterPort' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }

                it 'Should update printer PortName with queued PrintJobs' {
                    Mock -CommandName Get-Printjob -MockWith { return $myPrintJobs }

                    $setParams = [Printer]$testPresentParams
                    $setParams.PortName = 'newPrinterPort'

                    { $setParams.set() } | Should -Not -Throw                  

                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'myPrinter' -and $PortName -eq 'newPrinterPort' }
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }
            }<#
            context 'Convert PortType' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "myPrinter"
                $PrinterResource.PortName = "myPort"
                $PrinterResource.Address = "printer.local"
                $PrinterResource.DriverName = "myDriver"
                $PrinterResource.Shared = $true

                it 'Convert PortType PaperCut -> LPR' {
                    $PrinterResource.PortType = "LPR"
                    $PrinterResource.lprQueueName = "myQueue"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-Random -MockWith { return 1 }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = $null
                            Description = "PaperCut TCP/IP Port"
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Mock -CommandName Get-CimInstance -MockWith { } -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Remove-Item -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Remove-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-Printer -MockWith { }
                    $PrinterResource.Set()
                    
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Random -Times 9 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType PaperCut -> TCPIP' {
                    $PrinterResource.PortType = "TCPIP"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-Random -MockWith { return 1 }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = $null
                            Description = "PaperCut TCP/IP Port"
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Mock -CommandName Get-CimInstance -MockWith { } -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Remove-Item -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Remove-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-Printer -MockWith { }
                    $PrinterResource.Set()
                    
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Random -Times 9 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType LPR -> TCPIP' {
                    $PrinterResource.PortType = "TCPIP"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        } 
                    }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType LPR -> PaperCut' {
                    $PrinterResource.PortType = "PaperCut"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                   
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType TCPIP -> LPR' {
                    $PrinterResource.PortType = "LPR"
                    $PrinterResource.lprQueueName = "queue"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # TCPIP
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        } 
                    }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType TCPIP -> PaperCut' {
                    $PrinterResource.PortType = "PaperCut"
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                   
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            } # End Context Convert PortType
            context 'Update Port Settings' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "myPrinter"
                $PrinterResource.PortName = "myPort"
                $PrinterResource.Address = "printer.local"
                $PrinterResource.DriverName = "myDriver"
                $PrinterResource.Shared = $true

                it 'Update PaperCut Port Address' {
                    $PrinterResource.PortType = 'PaperCut'
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Description = "PaperCut TCP/IP Port"
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Get-Item -MockWith {
                        [System.Collections.Hashtable]@{
                            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\myPort'
                        }
                    }
                    Mock -CommandName Get-ItemProperty -MockWith {
                        [System.Collections.Hashtable]@{
                            HostName = 'badaddress.local'
                        }
                    }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith {}
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = $null
                            Description = "PaperCut TCP/IP Port"
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Update LPR Port Address' {
                    $PrinterResource.PortType = 'LPR'
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            PrinterHostAddress = 'myBadAddress.local'
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address
                it 'Update LPR Port lprQueueName' {
                    $PrinterResource.PortType = 'LPR'
                    $PrinterResource.lprQueueName = 'myQueue'
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            PrinterHostAddress = 'printer.local'
                            lprQueueName = 'myBadQueue'
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address
                it 'Update LPR/TCPIP Port SNMPEnabled' {
                    $PrinterResource.PortType = 'LPR'
                    $PrinterResource.SNMPEnabled = $true
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            PrinterHostAddress = 'printer.local'
                            lprQueueName = 'myQueue'
                            SNMPEnabled = $false
                            SNMPCommunity = 'public'
                            SNMPIndex = 1
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR/TCPIP Port SNMPEnabled
                it 'Update LPR/TCPIP Port SNMPCommunity' {
                    $PrinterResource.PortType = 'LPR'
                    $PrinterResource.SNMPCommunity = 'public'
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            PrinterHostAddress = 'printer.local'
                            lprQueueName = 'myQueue'
                            SNMPEnabled = $true
                            SNMPCommunity = 'notPublic'
                            SNMPIndex = 1
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR/TCPIP Port SNMPCommunity
                it 'Update LPR/TCPIP Port SNMPIndex' {
                    $PrinterResource.PortType = 'LPR'
                    $PrinterResource.SNMP = 1
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            PrinterHostAddress = 'printer.local'
                            lprQueueName = 'myQueue'
                            SNMPEnabled = $true
                            SNMPCommunity = 'public'
                            SNMPIndex = 2
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'myPort'
                        } 
                    }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $PrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $this.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        }
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $PrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR/TCPIP Port SNMPIndex
            } # End Context Update Port Settings
        #>} # End Describe Set Method
    } 
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
