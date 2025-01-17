[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug',
    [switch]$Test
)

# Setup
$ErrorActionPreference = 'Stop'
$BuildOutput = Join-Path $PSScriptRoot 'build'
$Source = Join-Path $PSScriptRoot 'src'
$TestsPath = Join-Path $PSScriptRoot 'tests'

# Clean and create build output
if (Test-Path $BuildOutput) {
    Remove-Item $BuildOutput -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildOutput | Out-Null

# Copy source files
Copy-Item -Path "$Source\*" -Destination $BuildOutput -Recurse

# Run tests if specified
if ($Test) {
    $TestResults = Invoke-Pester -Path $TestsPath -PassThru
    if ($TestResults.FailedCount -gt 0) {
        throw "Tests failed"
    }
}

Write-Host "Build completed successfully" -ForegroundColor Green
