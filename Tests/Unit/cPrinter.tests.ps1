$Global:ModuleName = 'cPrinterManagement'
$Global:DscResourceName = 'cPrinter'

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

function Invoke-TestSetup {
}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try {
    Invoke-TestSetup

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
                    Mock -CommandName Get-Printer -MockWith {} -ParameterFilter {$Name -eq "testprinter"}
                    Mock -CommandName Get-PrinterPort -MockWith {} -ParameterFilter {$Name -eq "testprinter"}
                    $cPrinterResource.test() | should be $true
                }
                it "Test should return false when printer is present" {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    } -ParameterFilter {$Name -eq "testprinter"}
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    } -ParameterFilter {$Name -eq "testprinter"}
                    $cPrinterResource.test() | should be $false
                }
                it "Test should return false when printer is absent and the printer port is present" {
                    Mock -CommandName Get-Printer -MockWith { } -ParameterFilter {$Name -eq "testprinter"}
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'testprinter'
                        }
                    } -ParameterFilter {$Name -eq "testprinter"}
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
                        }
                    } -ParameterFilter {$Name -eq "printerExists"}
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    } -ParameterFilter {$Name -eq "printerExists"}
                    $cPrinterResource.test() | should be $true
                }
                it 'Test should return false when printer is present and port is absent' {
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                            PortName = 'printerExists'
                        }
                    } -ParameterFilter {$Name -eq "printerExists"}
                    Mock -CommandName Get-PrinterPort -MockWith {} -ParameterFilter {$Name -eq "printerExists"}
                    $cPrinterResource.test() | should be $false
                }
                it 'Test should return false when printer is absent and the port is present' {
                    Mock -CommandName Get-Printer -MockWith { } -ParameterFilter {$Name -eq "printerExists"}
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'printerExists'
                        }
                    } -ParameterFilter {$Name -eq "printerExists"}
                    $cPrinterResource.test() | should be $false
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
                    } -ParameterFilter {$Name -eq "printerExists"}
                    $object = $cPrinterResource.Get()

                    $object.GetType().Name | Should Be 'cPrinter'
                    $object.Ensure | Should Be 'Present'
                }
            }
        }
        Describe 'Set Method'{
            context 'Ensure Present' {
                $cPrinterResource = [cPrinter]::new()
                $cPrinterResource.Ensure = [Ensure]::Present
                $cPrinterResource.Name = "newPrinter"
                $cPrinterResource.PortName = "newPrinter"
                
                it 'Add-Printer should be called 1 time' {
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Get-PrinterPort -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                }
                it 'Add-PrinterPort should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith {
                        [System.Collections.Hashtable]@{
                            Name = 'newPrinter'
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith {}
                    Mock -CommandName Add-Printer -MockWith { }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
                }
                it 'Add-PrinterPort and Add-Printer both should be called 1 time' {
                    Mock -CommandName Get-PrinterPort -MockWith { }
                    Mock -CommandName Get-Printer -MockWith { }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 1 -Exactly -Scope It
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
                        } 
                    }
                    Mock -CommandName Add-PrinterPort -MockWith { }
                    Mock -CommandName Add-Printer -MockWith { }
                    $cPrinterResource.Set()
                    Assert-MockCalled -CommandName Get-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-PrinterPort -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PrinterPort -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-Printer -Times 0 -Exactly -Scope It
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
                    Assert-MockCalled -CommandName Get-Printjob -Times 2 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-Printer -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-PrintJob -Times 1 -Exactly -Scope It
                }
            }
        }
    }
} finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}