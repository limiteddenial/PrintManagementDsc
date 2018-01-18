$Global:ModuleName = 'cPrinterManagement'
$Global:DscResourceName = 'cPrinter'

#region HEADER

# Unit Test Template Version: 1.2.0
<#$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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

function Invoke-TestSetup {
}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try {
    Invoke-TestSetup
#>
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'cPrinterManagement.psd1') -Force
    #region Pester Tests
    InModuleScope -ModuleName cPrinter {
        Describe 'Test Method'{          
            Context 'Type Test' { 
                $cPrinterResource = [cPrinter]::new()
                it 'Test should return a bool' {
                    $cPrinterResource.Ensure = [Ensure]::Present
                    $cPrinterResource.Name = "testprinter"
                    $cPrinterResource.PortName = "testprinter"
                    Mock -CommandName Get-Printer -MockWith {} -ParameterFilter {$Name -eq "testprinter"}
                    Mock -CommandName Get-PrinterPort -MockWith {} -ParameterFilter {$Name -eq "testprinter"}
                    $cPrinterResource.test() | Should BeOfType bool
                }
            }
            Context 'Ensure Absent' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Absent
                $cPrinterResource.Name = "testprinter"
                $cPrinterResource.PortName = "testprinter"

                it 'Test should return true when printer is absent' {
                    Mock -CommandName Get-Printer -MockWith {}
                    Mock -CommandName Get-PrinterPort -MockWith {}
                    $cPrinterResource.test() | should be $true
                }
                it "Test should return false when printer is present" {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    $cPrinterResource.test() | should be $false
                }
                it "Test should return false when printer and port is present" {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    }
                    $cPrinterResource.test() | should be $false
                }
                it "Test should return false when printer is absent and the printer port is present" {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    }
                    $cPrinterResource.test() | should be $false
                }
            }
            Context 'Ensure Present' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "printerExists"
                $cPrinterResource.PortName = "printerExists"
                
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.SNMPEnabled = $false
                    $cPrinterResource.test() | should be $true
                }
                it 'Test should return false when printer is present and port is absent' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PortName = 'printerExists'
                        }
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    $cPrinterResource.test() | should be $false
                }
                it 'Test should return false when printer is absent and the port is present' {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    } 
                    $cPrinterResource.test() | should be $false
                }
            }
            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
            Context 'Ensure Correct Settings' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "printerExists"
                $cPrinterResource.PortName = "printerExists"
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.test() | Should be $true
                }
                it 'Test should return false when the printer is not shared' {
                    $cPrinterResource.Shared = $false
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.test() | Should be $false
                }
                it 'Test should return false when the printer has inccorect PermissionSDDL set' {
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'bad perms'
                    $cPrinterResource.test() | Should be $false
                }
                it 'Test should return false when the printer has incorrect SNMPEnabled settings' {
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $false
                    $cPrinterResource.SNMPCommunity = "private"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.test() | Should be $false
                }
                it 'Test should return true when the printer has incorrect SNMP settings but SNMPEnabled is set to false' {
                    Mock -CommandName Get-PrinterPort -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PrinterHostAddress = 'printer.local'
                            SNMPEnabled = $false
                        } 
                    }
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $false
                    $cPrinterResource.SNMPCommunity = "private"
                    $cPrinterResource.SNMPIndex = '12'
                    $cPrinterResource.test() | Should be $true
                }
                it 'Test should return false when the printer has incorrect SNMPCommunity settings' {
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "private"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.test() | Should be $false
                }
                it 'Test should return false when the printer has incorrect SNMPIndex settings' {
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '123'
                    $cPrinterResource.test() | Should be $false
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.lprQueueName = "lpr"
                    $cPrinterResource.test() | Should be $false
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'printer.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.lprQueueName = "lpr"
                    $cPrinterResource.test() | Should be $true
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'incorrect.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.lprQueueName = "lpr"
                    $cPrinterResource.test() | Should be $False
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'incorrect.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.PermissionSDDL = 'perms'
                    $cPrinterResource.SNMPEnabled = $true
                    $cPrinterResource.SNMPCommunity = "public"
                    $cPrinterResource.SNMPIndex = '1'
                    $cPrinterResource.test() | Should be $False
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
                    $cPrinterResource.Shared = $true
                    $cPrinterResource.Address = 'incorrect.local'
                    $cPrinterResource.DriverName = 'false Driver'
                    $cPrinterResource.test() | Should be $False
                }
            }
        }
        Describe 'Get Method'{
            context "Get type" {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "printerExists"
                $cPrinterResource.PortName = "printerExists"
                
                it 'Get should return cPrinter object' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    }
                    $cPrinterResource.Get().GetType().Name | Should Be 'cPrinter'
                }
            }
            context "Get Enusre Absent" {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "printerExists"
                $cPrinterResource.PortName = "printerExists"

                it 'Get should return Absent if the printer does not exist' {
                    Mock -CommandName Get-Printer -MockWith { throw }
                    $cPrinterResource.Get().Ensure | Should be 'Absent'
                }
                it 'Get should return Absent if the printerPort does not exist' {
                    Mock -CommandName Get-Printer -MockWith { 
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        } 
                    }
                    Mock -CommandName Get-PrinterPort -MockWith { throw }
                    $cPrinterResource.Get().Ensure | Should be 'Absent'
                }
            }
            Function Get-ItemProperty { [CmdletBinding()] param ( [Parameter(ValueFromPipeline = $true)] $Path ) }
            context "Get Printer Settings" {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "printerExists"
                $cPrinterResource.PortName = "printerExists"
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
                    $ReturnedValues = $cPrinterResource.Get()
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
                    $ReturnedValues = $cPrinterResource.Get()
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
                    $ReturnedValues = $cPrinterResource.Get()
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
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "newPrinter"
                $cPrinterResource.PortName = "newPrinter"
                $cPrinterResource.Address = "test.local"
                $cPrinterResource.DriverName = "myDriver"
                $cPrinterResource.SNMPEnabled = $false
                
                it 'Add-Printer should be called 1 time' {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                        }
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # Port Check for TCPIP
                        } 
                    }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterDriver -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
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
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                }
                it 'PaperCut Port is created' {
                    $cPrinterResource.PortType = 'PaperCut'
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
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Add-PrinterPort and Add-Printer both should be called 1 time' {
                    $cPrinterResource.PortType = 'TCPIP'
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    $cPrinterResource.Set()
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
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Set-Printer -MockWith { }
                    Mock -CommandName Get-CimInstance -MockWith {
                        [System.Collections.Hashtable]@{
                            Protocol = 1 # Port Check for TCPIP
                        } 
                    }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It
                }
            }
            context 'Ensure Absent' {
                
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Absent
                $cPrinterResource.Name = "removePrinter"
                $cPrinterResource.PortName = "removePrinter"
                
                it 'Remove-Printer should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'removePrinter'
                        } 
                    }
                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-Printer -MockWith { }
                    $cPrinterResource.Set()
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
                    $cPrinterResource.Set()
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
                    $cPrinterResource.Set()
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
                     { $cPrinterResource.Set() } | Should Throw
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            }
            context 'Update Printer Settings' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "myPrinter"
                $cPrinterResource.PortName = "myPort"
                $cPrinterResource.Address = "printer.local"
                $cPrinterResource.DriverName = "myDriver"
                $cPrinterResource.Shared = $true
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
                    $cPrinterResource.Set()
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
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $Shared -eq [bool]::FalseString }
                }
                it 'Update Printer PermissionSDDL' {
                    $cPrinterResource.PermissionSDDL = 'badperms'
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
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PermissionSDDL -eq $cPrinterResource.PermissionSDDL }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PermissionSDDL -eq $cPrinterResource.PermissionSDDL }
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
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $cPrinterResource.PortName }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $cPrinterResource.PortName }
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
                    Mock -CommandName Set-Printer -MockWith {} -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $cPrinterResource.PortName }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 1 -Exactly -Scope It -ParameterFilter {$Name -eq "myPrinter" -and $PortName -eq $cPrinterResource.PortName }
                }
            }
            context 'Convert PortType' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "myPrinter"
                $cPrinterResource.PortName = "myPort"
                $cPrinterResource.Address = "printer.local"
                $cPrinterResource.DriverName = "myDriver"
                $cPrinterResource.Shared = $true

                it 'Convert PortType PaperCut -> LPR' {
                    $cPrinterResource.PortType = "LPR"
                    $cPrinterResource.lprQueueName = "myQueue"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
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
                    $cPrinterResource.Set()
                    
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Random -Times 9 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType PaperCut -> TCPIP' {
                    $cPrinterResource.PortType = "TCPIP"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
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
                    $cPrinterResource.Set()
                    
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Random -Times 9 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Name From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f "111111111")}
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType LPR -> TCPIP' {
                    $cPrinterResource.PortType = "TCPIP"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $cPrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        } 
                    }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType LPR -> PaperCut' {
                    $cPrinterResource.PortType = "PaperCut"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                   
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType TCPIP -> LPR' {
                    $cPrinterResource.PortType = "LPR"
                    $cPrinterResource.lprQueueName = "queue"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Get-WmiObject -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = $cPrinterResource.PortName
                            Protocol = 2 # LPR
                            Description = $null
                        } 
                    }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                }
                it 'Convert PortType TCPIP -> PaperCut' {
                    $cPrinterResource.PortType = "PaperCut"
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}

                    Mock -CommandName Get-Printjob -MockWith { }
                    Mock -CommandName Remove-PrintJob -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Get-PrinterDriver -MockWith { return $true }
                    Mock -CommandName Set-WmiInstance -MockWith { }
                    Mock -CommandName Invoke-Command -MockWith { }
                    Mock -CommandName Restart-Service -MockWith { }
                   
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-Printjob -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}                    
                    Assert-MockCalled -CommandName Remove-PrinterPort -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
            } # End Context Convert PortType
            context 'Update Port Settings' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "myPrinter"
                $cPrinterResource.PortName = "myPort"
                $cPrinterResource.Address = "printer.local"
                $cPrinterResource.DriverName = "myDriver"
                $cPrinterResource.Shared = $true

                it 'Update PaperCut Port Address' {
                    $cPrinterResource.PortType = 'PaperCut'
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-Item -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-ItemProperty -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Restart-Service -Times 1 -Exactly -Scope It
                }
                it 'Update LPR Port Address' {
                    $cPrinterResource.PortType = 'LPR'
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
                            Name = $cPrinterResource.PortName
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address
                it 'Update LPR Port lprQueueName' {
                    $cPrinterResource.PortType = 'LPR'
                    $cPrinterResource.lprQueueName = 'myQueue'
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
                            Name = $cPrinterResource.PortName
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
                    } -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-Printer -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1 -Exactly -Scope It -ParameterFilter {$Query -eq ("Select Protocol,Description From Win32_TCPIpPrinterPort WHERE Name = '{0}'" -f $cPrinterResource.PortName)}
                    Assert-MockCalled -CommandName Get-WmiObject -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Set-WmiInstance -Times 1 -Exactly -Scope It
                } # End It Update LPR Port Address
            } # End Context Update Port Settings
        } # End Describe Set Method
    } <#
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}#>
