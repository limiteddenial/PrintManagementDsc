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
            Address = 'myPrinterAddress.local'
            Shared = $true
            PermissionSDDL = 'fakeperms'
            SNMPEnabled = $true
            SNMPCommunity = 'public'
            SNMPIndex = 1
        }
        $testAbsentParams = $testPresentParams.clone()
        $testAbsentParams.Ensure = [Ensure]::Absent

        # Region Mock Returns
        $myPrinter = @{
            Name = 'myPrinter'
            PortName = 'myPrinterPort'
            DriverName = 'myDriver'
            Shared = 'True'
            PermissionSDDL = 'fakeperms'
        }
        $myPrinterNoSNMP = $myPrinter.clone()
        $myPrinterNoSNMP.Name = 'myPrinterNoSNMP'
        $myPrinterNoSNMP.PortName = 'myPrinterPortNoSNMP'

        $myPrinterPort = @{
            Name = 'myPrinterPort'
            Description = 'Standard TCP/IP Port'
            PrinterHostAddress = 'myPrinterAddress.local'
            SNMPEnabled = 'True'
            SNMPCommunity = 'public'
            SNMPIndex = '1'
        }
        $myBadPortName = $myPrinterPort.clone()
        $myBadPortName.Name = 'myBadPortName'
        $myPrinterPortNoSNMP = $myPrinterPort.clone()
        $myPrinterPortNoSNMP.Name = 'myPrinterPortNoSNMP'
        $myPrinterPortNoSNMP.SNMPEnabled = 'False'
        # End Region
        
        Describe 'Test Method'{
            BeforeEach {
                Mock -CommandName Write-Verbose
                Mock -CommandName Get-Printer -MockWith { return $myPrinter } -ParameterFilter {$Name -eq 'myPrinter'}
                Mock -CommandName Get-Printer -MockWith { return $myPrinterNoSNMP } -ParameterFilter {$Name -eq 'myPrinterNoSNMP'}
                Mock -CommandName Get-Printer -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                Mock -CommandName Get-PrinterPort -MockWith { throw } -ParameterFilter {$Name -eq 'myAbsentPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPort } -ParameterFilter {$Name -eq 'myPrinterPort'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myPrinterPortNoSNMP } -ParameterFilter {$Name -eq 'myPrinterPortNoSNMP'}
                Mock -CommandName Get-PrinterPort -MockWith { return $myBadPortName } -ParameterFilter {$Name -eq 'myBadPortName'}
            }
            AfterEach {
                Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
            }      
            Context 'Type Test' { 
                it 'Test should return a bool' {
                    $testParams = [Printer]$testPresentParams
                    $testParams.test() | Should -BeOfType bool
                }
            }
            Context 'Ensure Absent' {
                it 'Test should return true when printer is absent' {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = 'myAbsentPrinter'
                    $testParams.PortName = 'myAbsentPrinterPort'

                    $testParams.test() | should be $true
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinterPort'}
                }
                it "Test should return false when printer is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.PortName = 'myAbsentPrinterPort'

                    $testParams.test() | should be $false
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                }
                it "Test should return false when printer and port is present" {
                    $testParams = [Printer]$testAbsentParams

                    $testParams.test() | should be $false
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPort'}
                }
                it "Test should return false when printer is absent and the printer port is present" {
                    $testParams = [Printer]$testAbsentParams
                    $testParams.Name = 'myAbsentPrinter'
                    
                    $testParams.test() | should be $false
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myAbsentPrinter'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPort'}
                }
            }
            Context 'Ensure Present' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "printerExists"
                $PrinterResource.PortName = "printerExists"
                
                it 'Test should return true when printer is present' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PortName = 'printerExists'
                            Shared = $true
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            SNMPEnabled = $false
                        }
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.SNMPEnabled = $false
                    $PrinterResource.test() | should be $true
                }
                it 'Test should return false when printer is present and port is absent' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PortName = 'printerExists'
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { throw }
                    $PrinterResource.test() | should be $false
                }
                it 'Test should return false when printer is absent and the port is present' {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    } 
                    $PrinterResource.test() | should be $false
                }
            }
            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
            Context 'Ensure Correct Settings' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "printerExists"
                $PrinterResource.PortName = "printerExists"
                Mock -CommandName Get-Printer -MockWith { 
                    [System.Collections.Hashtable]@{
                        Name = 'printerExists'
                        DriverName = 'false Driver'
                        PortName = 'printerExists'
                        Shared = $true
                        PermissionSDDL = 'perms'
                    } 
                }
                Mock -CommandName Get-PrinterPort -MockWith { 
                    [System.Collections.Hashtable]@{
                        Name = 'printerExists'
                        PrinterHostAddress = 'printer.local'
                        SNMPEnabled = $true
                        SNMPCommunity = 'public'
                        SNMPIndex = [int]'1'
                    } 
                }
                it 'Test should return true when all printer settings are correct' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.test() | Should -be $true
                }
                it 'Test should return false when PortName is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.PortName = 'myBadPortName'
                    $testparams.test() | Should -be $false
                    
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myBadPortName'}   
                }
                it 'Test should return false when DriverName is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.DriverName = 'myBadDriverName'

                    $testparams.test() | Should -be $false
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinter'}
                }
                it 'Test should return false when the printer is not shared' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.Shared = $false

                    $testparams.test() | Should be $false
                }
                it 'Test should return false when PermissionSDDL is incorrect' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.PermissionSDDL = 'bad perms'
   
                    $testparams.test() | Should be $false
                }
                it 'Test should return false when the printer has incorrect SNMPEnabled settings' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.SNMPEnabled = $false
                    
                    $testparams.test() | Should be $false
                }
                it 'Test should return true when the printer has incorrect SNMP settings but SNMPEnabled is set to false' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.Name = 'myPrinterNoSNMP'
                    $testparams.PortName = 'myPrinterPortNoSNMP'
                    $testparams.SNMPEnabled = $false
                    $testparams.SNMPCommunity = 'private'
                    $testparams.SNMPIndex = '12'

                    $testparams.test() | Should be $true
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterNoSNMP'}
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq 'myPrinterPortNoSNMP'}
                }
                it 'Test should return false when the printer has incorrect SNMPCommunity settings' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.SNMPCommunity = 'private'

                    $testparams.test() | Should be $false
                }
                it 'Test should return false when the printer has incorrect SNMPIndex settings' {
                    $testparams = [Printer]$testPresentParams
                    $testparams.SNMPIndex = '123'

                    $testparams.test() | Should be $false
                }
                it 'Test should return false when the printer has incorrect lprQueueName settings' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = $true
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                            lprQueueName = 'print'
                        } 
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.Address = 'printer.local'
                    $PrinterResource.DriverName = 'false Driver'
                    $PrinterResource.PermissionSDDL = 'perms'
                    $PrinterResource.SNMPEnabled = $true
                    $PrinterResource.SNMPCommunity = "public"
                    $PrinterResource.SNMPIndex = '1'
                    $PrinterResource.lprQueueName = "lpr"
                    $PrinterResource.test() | Should be $false
                }
                it 'Test should return true when all printer settings are correct for a printer using LPR queue name' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = $true
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                            lprQueueName = 'lpr'
                        } 
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.Address = 'printer.local'
                    $PrinterResource.DriverName = 'false Driver'
                    $PrinterResource.PermissionSDDL = 'perms'
                    $PrinterResource.SNMPEnabled = $true
                    $PrinterResource.SNMPCommunity = "public"
                    $PrinterResource.SNMPIndex = '1'
                    $PrinterResource.lprQueueName = "lpr"
                    $PrinterResource.test() | Should be $true
                }
                it 'Test should return false when printer has the incorrect Address set for a LPR Port' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = $true
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                            lprQueueName = 'lpr'
                        } 
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.Address = 'incorrect.local'
                    $PrinterResource.DriverName = 'false Driver'
                    $PrinterResource.PermissionSDDL = 'perms'
                    $PrinterResource.SNMPEnabled = $true
                    $PrinterResource.SNMPCommunity = "public"
                    $PrinterResource.SNMPIndex = '1'
                    $PrinterResource.lprQueueName = "lpr"
                    $PrinterResource.test() | Should be $False
                }
                it 'Test should return false when printer has the incorrect Address set for a TCPIP Port' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = $true
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.Address = 'incorrect.local'
                    $PrinterResource.DriverName = 'false Driver'
                    $PrinterResource.PermissionSDDL = 'perms'
                    $PrinterResource.SNMPEnabled = $true
                    $PrinterResource.SNMPCommunity = "public"
                    $PrinterResource.SNMPIndex = '1'
                    $PrinterResource.test() | Should be $False
                }
                it 'Test should return false when printer has the incorrect Address set for a PaperCut Port' {
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            Description = 'PaperCut TCP/IP Port'
                        }
                    }
                    Mock -CommandName Get-Item -MockWith {
                        [System.Collections.Hashtable]@{
                            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\printerExists'
                        }
                    }
                    Mock -CommandName Get-ItemProperty -MockWith {
                        [System.Collections.Hashtable]@{
                            HostName = 'papercut.local'
                        }
                    }
                    $PrinterResource.Shared = $true
                    $PrinterResource.Address = 'incorrect.local'
                    $PrinterResource.DriverName = 'false Driver'
                    $PrinterResource.test() | Should be $False
                }
            }
        }
        Describe 'Get Method'{
            context "Get type" {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "printerExists"
                $PrinterResource.PortName = "printerExists"
                
                it 'Get should return Printer object' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    }
                    $PrinterResource.Get().GetType().Name | Should Be 'Printer'
                }
            }
            context "Get Enusre Absent" {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "printerExists"
                $PrinterResource.PortName = "printerExists"

                it 'Get should return Absent if the printer does not exist' {
                    Mock -CommandName Get-Printer -MockWith { throw }
                    $PrinterResource.Get().Ensure | Should be 'Absent'
                }
                it 'Get should return Absent if the printerPort does not exist' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { throw }
                    $PrinterResource.Get().Ensure | Should be 'Absent'
                }
            }
            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
            context "Get Printer Settings" {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "printerExists"
                $PrinterResource.PortName = "printerExists"
                it 'Should return correct properties for a printer using a RAW port' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            DriverName = 'false Driver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                        } 
                    }
                    $ReturnedValues = $PrinterResource.Get()
                    $ReturnedValues.Ensure | Should be 'Present'
                    $ReturnedValues.DriverName | Should be 'false Driver'
                    $ReturnedValues.Shared | Should be $true
                    $ReturnedValues.PermissionSDDL | Should be 'perms'
                    $ReturnedValues.PortName | Should be 'Exists'
                    $ReturnedValues.Address | Should be 'printer.local'
                    $ReturnedValues.SNMPEnabled | Should be $true
                    $ReturnedValues.SNMPCommunity | Should be 'public'
                    $ReturnedValues.SNMPIndex | Should be 1
                    $ReturnedValues.lprQueueName | Should be $null
                }
                it 'Should return correct properties for a printer using a LPR port' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            DriverName = 'false Driver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = [int]'1'
                            lprQueueName = 'testqueue'
                        } 
                    }
                    $ReturnedValues = $PrinterResource.Get()
                    $ReturnedValues.Ensure | Should be 'Present'
                    $ReturnedValues.DriverName | Should be 'false Driver'
                    $ReturnedValues.Shared | Should be $true
                    $ReturnedValues.PermissionSDDL | Should be 'perms'
                    $ReturnedValues.PortName | Should be 'Exists'
                    $ReturnedValues.Address | Should be 'printer.local'
                    $ReturnedValues.SNMPEnabled | Should be $true
                    $ReturnedValues.SNMPCommunity | Should be 'public'
                    $ReturnedValues.SNMPIndex | Should be 1
                    $ReturnedValues.lprQueueName | Should be 'testqueue'
                }
                it 'Should return correct properties for a printer using a Papercut port' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            DriverName = 'false Driver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'Exists'
                            Description = 'PaperCut TCP/IP Port'
                        }
                    }
                    Mock -CommandName Get-Item -MockWith {
                        [System.Collections.Hashtable]@{
                            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\PaperCut TCP/IP Port\Ports\Exists'
                        }
                    }
                    Mock -CommandName Get-ItemProperty -MockWith {
                        [System.Collections.Hashtable]@{
                            HostName = 'papercut.local'
                        }
                    }
                    $ReturnedValues = $PrinterResource.Get()
                    $ReturnedValues.Ensure | Should be 'Present'
                    $ReturnedValues.DriverName | Should be 'false Driver'
                    $ReturnedValues.Shared | Should be $true
                    $ReturnedValues.PermissionSDDL | Should be 'perms'
                    $ReturnedValues.PortName | Should be 'Exists'
                    $ReturnedValues.Address | Should be 'papercut.local'
                    $ReturnedValues.SNMPEnabled | Should be $false
                    $ReturnedValues.lprQueueName | Should be $null
                }
            }
        }
        Describe 'Set Method'{
            Function Remove-PrintJob { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $InputObject ) }
            Function Remove-PrinterPort{[Cmdletbinding()] param($name)}
            Function Add-PrinterPort{}
            Function Remove-PrinterPort {}
            Function Set-WmiInstance { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $InputObject,$Arguments,$PutType ) }
            context 'Ensure Present' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "newPrinter"
                $PrinterResource.PortName = "newPrinter"
                $PrinterResource.Address = "test.local"
                $PrinterResource.DriverName = "myDriver"
                $PrinterResource.SNMPEnabled = $false
                
                it 'Add-Printer should be called 1 time' {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                            PrinterHostAddress = "test.local"
                            SNMPENabled = $false
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Get-WmiObject -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # Port Check for TCPIP
                        } 
                    }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                }
                it 'Add-PrinterPort should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'newPrinter'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith {}
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }
                it 'PaperCut Port is created' {
                    $PrinterResource.PortType = 'PaperCut'
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'newPrinter'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith {}
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Add-PrinterPort and Add-Printer both should be called 1 time' {
                    $PrinterResource.PortType = 'TCPIP'
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }
                it 'Add-PrinterPort and Add-Printer both should not called' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                            PrinterHostAddress = "test.local"
                            SNMPENabled = $false
                        } 
                    }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PortName = 'newPrinter'
                        } 
                    }
                    Mock -CommandName Get-WmiObject -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # Port Check for TCPIP
                        } 
                    }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0 -Exactly -Scope It
                }
            }
            context 'Ensure Absent' {
                
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Absent
                $PrinterResource.Name = "removePrinter"
                $PrinterResource.PortName = "removePrinter"
                
                it 'Remove-Printer should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'removePrinter'
                        } 
                    }
                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-Printer -MockWith { }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                }
                it 'Remove-Printer and Remove-PrinJob should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'removePrinter'
                        } 
                    }
                    Mock -CommandName Get-Printjob -MockWith {
                        [System.Collections.Hashtable]@{
                            ID = '1'
                            PrinterName = 'removePrinter'
                            DocumentName = 'Test'
                        } 
                    }
                    Mock -CommandName Remove-Printer -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 1 -Exactly -Scope It
                }
                it 'Remove-PrinterPort should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'removePrinter'
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Remove-PrinterPort -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 0 -Exactly -Scope It
                }
                it 'Remove-PrinterPort should be called 2 times and the Spooler service restarted' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'removePrinter'
                        }
                    }
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Remove-PrinterPort -MockWith { throw }
                    Mock -CommandName Restart-Service -MockWith { }
                     { $PrinterResource.Set() } | Should Throw
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            }
            context 'Update Printer Settings' {
                $PrinterResource = [Printer]::new()
                $PrinterResource.Ensure = [Ensure]::Present
                $PrinterResource.Name = "myPrinter"
                $PrinterResource.PortName = "myPort"
                $PrinterResource.Address = "printer.local"
                $PrinterResource.DriverName = "myDriver"
                $PrinterResource.Shared = $true
                Mock -CommandName Add-Printer -MockWith { }

                it 'Update Printer Driver' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myFalseDriver'
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
                            Protocol = 1 # Port Check for TCPIP
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $DriverName -eq "myDriver"}
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $DriverName -eq "myDriver"}
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }
                it 'Update Printer Shared' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::FalseString
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
                            SNMPIndex = '1'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $Shared -eq [bool]::FalseString }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $Shared -eq [bool]::FalseString }
                }
                it 'Update Printer PermissionSDDL' {
                    $PrinterResource.PermissionSDDL = 'badperms'
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
                            SNMPIndex = '1'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PermissionSDDL -eq $PrinterResource.PermissionSDDL }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PermissionSDDL -eq $PrinterResource.PermissionSDDL }
                }
                it 'Update Printer PortName' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myBadPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = '1'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $PrinterResource.PortName }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $PrinterResource.PortName }
                }
                it 'Update Printer PortName with queued PrintJobs' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPrinter'
                            DriverName = 'myDriver'
                            Shared = [bool]::TrueString
                            PermissionSDDL = 'perms'
                            PortName = 'myBadPort'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'myPort'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = [bool]::TrueString
                            SNMPCommunity = 'public'
                            SNMPIndex = '1'
                        } 
                    }
                    Mock -CommandName Get-Printjob -MockWith {
                        [System.Collections.Hashtable]@{
                            ID = '1'
                            PrinterName = 'myPrinter'
                            DocumentName = 'Test'
                        },
                        [System.Collections.Hashtable]@{
                            ID = '2'
                            PrinterName = 'myPrinter'
                            DocumentName = 'Test2'
                        }  
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $PrinterResource.PortName }
                    $PrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $PrinterResource.PortName }
                }
            }
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
                    $PrinterResource.SNMPIndex = 1
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
        } # End Describe Set Method
    } 
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
