[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug',
    [switch]$Test
)

# Add build summary and logging functions
function Initialize-BuildEnvironment {
    [CmdletBinding()]
    param()
    
    $script:buildStart = Get-Date
    $script:buildSummary = @{
        StartTime = $buildStart
        Errors = @()
        Warnings = @()
        Steps = @()
    }
    
    # Create logs directory
    $script:logsPath = Join-Path $PSScriptRoot 'logs'
    if (-not (Test-Path $logsPath)) {
        New-Item -ItemType Directory -Path $logsPath | Out-Null
    }
    
    # Initialize log file
    $script:logFile = Join-Path $logsPath "build_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    "Build started at $buildStart" | Out-File $logFile
}

function Write-BuildLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] ${Level}: $Message"
    
    # Add to summary
    switch ($Level) {
        'Warning' { $script:buildSummary.Warnings += $Message }
        'Error' { $script:buildSummary.Errors += $Message }
    }
    
    # Write to console with color
    switch ($Level) {
        'Info' { Write-Host $logMessage -ForegroundColor Cyan }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error' { Write-Host $logMessage -ForegroundColor Red }
    }
    
    # Write to log file
    $logMessage | Out-File $logFile -Append
}

function Write-BuildSummary {
    [CmdletBinding()]
    param()
    
    $duration = (Get-Date) - $script:buildStart
    $summary = @"
====== Build Summary ======
Start Time: $($buildSummary.StartTime)
Duration: $($duration.ToString())
Steps Completed: $($buildSummary.Steps.Count)
Errors: $($buildSummary.Errors.Count)
Warnings: $($buildSummary.Warnings.Count)

Steps:
$(($buildSummary.Steps | ForEach-Object { "- $_" }) -join "`n")

Warnings:
$(($buildSummary.Warnings | ForEach-Object { "- $_" }) -join "`n")

Errors:
$(($buildSummary.Errors | ForEach-Object { "- $_" }) -join "`n")
========================
"@
    
    # Write to console and log
    Write-Host $summary -ForegroundColor White
    $summary | Out-File $logFile -Append
    
    # Generate HTML report
    $htmlReport = Join-Path $logsPath "build_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    $htmlContent = $summary | ConvertTo-Html -Title "Build Report" -PreContent "<h1>Build Report</h1>"
    $htmlContent | Out-File $htmlReport
}

# Initialize build environment
Initialize-BuildEnvironment

function Install-BuildDependencies {
    [CmdletBinding()]
    param()
    
    $requiredModules = @(
        @{Name = 'Pester'; MinimumVersion = '5.0.0'},
        @{Name = 'PSScriptAnalyzer'; MinimumVersion = '1.20.0'}
    )

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module.Name | 
            Where-Object { $_.Version -ge $module.MinimumVersion })) {
            Write-Host "Installing $($module.Name)..." -ForegroundColor Yellow
            Install-Module -Name $module.Name -Force -AllowClobber -Scope CurrentUser -MinimumVersion $module.MinimumVersion
        }
        else {
            Write-Host "$($module.Name) is already installed." -ForegroundColor Green
        }
    }
}

try {
    Write-BuildLog "Starting build process for configuration: $Configuration"
    
    # Setup paths
    $ErrorActionPreference = 'Stop'
    $BuildOutput = Join-Path $PSScriptRoot 'build'
    $Source = Join-Path $PSScriptRoot 'src'
    $TestsPath = Join-Path $PSScriptRoot 'tests'
    
    # Ensure dependencies
    Write-BuildLog "Checking build dependencies..."
    Install-BuildDependencies
    $script:buildSummary.Steps += "Dependencies installed"
    
    # Clean and create build output
    Write-BuildLog "Cleaning build output..."
    if (Test-Path $BuildOutput) {
        Remove-Item $BuildOutput -Recurse -Force
    }
    New-Item -ItemType Directory -Path $BuildOutput | Out-Null
    $script:buildSummary.Steps += "Build directory cleaned"
    
    # Copy source files
    Write-BuildLog "Copying source files..."
    Copy-Item -Path "$Source\*" -Destination $BuildOutput -Recurse
    $script:buildSummary.Steps += "Source files copied"
    
    # Run PSScriptAnalyzer
    Write-BuildLog "Running PSScriptAnalyzer..."
    $Analysis = Invoke-ScriptAnalyzer -Path $Source -Recurse
    if ($Analysis) {
        $Analysis | ForEach-Object {
            $message = "[$($_.RuleName)] $($_.Message) in $($_.ScriptName):$($_.Line)"
            if ($_.Severity -eq 'Error') {
                Write-BuildLog $message -Level Error
            } else {
                Write-BuildLog $message -Level Warning
            }
        }
        if ($Analysis.Severity -contains 'Error') {
            throw "PSScriptAnalyzer found errors"
        }
    }
    $script:buildSummary.Steps += "PSScriptAnalyzer completed"
    
    # Run tests if specified
    if ($Test) {
        Write-BuildLog "Running Pester tests..."
        $PesterConfig = New-PesterConfiguration
        $PesterConfig.Run.Path = $TestsPath
        $PesterConfig.Output.Verbosity = 'Detailed'
        $PesterConfig.TestResult.Enabled = $true
        $PesterConfig.TestResult.OutputPath = Join-Path $logsPath "pester_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
        
        $TestResults = Invoke-Pester -Configuration $PesterConfig
        if ($TestResults.FailedCount -gt 0) {
            throw "Tests failed: $($TestResults.FailedCount) failures found"
        }
        $script:buildSummary.Steps += "Pester tests completed"
    }
    
    Write-BuildLog "Build completed successfully"
    $script:buildSummary.Steps += "Build successful"
}
catch {
    Write-BuildLog $_.Exception.Message -Level Error
    throw
}
finally {
    Write-BuildSummary
}
