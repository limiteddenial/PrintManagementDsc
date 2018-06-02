function Invoke-TestHarness
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $TestResultsFile,

        [Parameter()]
        [System.String]
        $DscTestsPath
    )
    $moduleName = 'PrintManagementDsc'
    Write-Verbose -Message "Commencing all $moduleName tests"

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '..\' -Resolve

    $testCoverageFiles = @()
    Get-ChildItem -Path "$repoDir\modules\$moduleName\DSCClassResources\**\*.psm1" -Recurse | ForEach-Object {
        if ($_.FullName -notlike '*\DSCResource.Tests\*') {
            $testCoverageFiles += $_.FullName
        }
    }

    $testResultSettings = @{ }
    if ([String]::IsNullOrEmpty($TestResultsFile) -eq $false) {
        $testResultSettings.Add('OutputFormat', 'NUnitXml' )
        $testResultSettings.Add('OutputFile', $TestResultsFile)
    }

    Import-Module -Name "$repoDir\modules\$moduleName\$moduleName.psd1"
    $testsToRun = @()

    # Run Unit Tests
    $unitTestsPath = Join-Path -Path $repoDir -ChildPath 'Tests\Unit'
    $testsToRun += @( (Get-ChildItem -Path $unitTestsPath).FullName )

    # Integration Tests
    $integrationTestsPath = Join-Path -Path $repoDir -ChildPath 'Tests\Integration'
    $testsToRun += @( (Get-ChildItem -Path $integrationTestsPath -Filter '*.Tests.ps1').FullName )

    # DSC Common Tests
    if ($PSBoundParameters.ContainsKey('DscTestsPath') -eq $true)
    {
        $getChildItemParameters = @{
            Path = $DscTestsPath
            Recurse = $true
            Filter = '*.Tests.ps1'
        }

        # Get all tests '*.Tests.ps1'.
        $commonTestFiles = Get-ChildItem @getChildItemParameters

        # Remove DscResource.Tests unit and integration tests.
        $commonTestFiles = $commonTestFiles | Where-Object -FilterScript {
            $_.FullName -notmatch 'DSCResource.Tests\\Tests'
        }

        $testsToRun += @( $commonTestFiles.FullName )
    }

    $results = Invoke-Pester -Script $testsToRun `
        -CodeCoverage $testCoverageFiles `
        -PassThru @testResultSettings

    return $results
}