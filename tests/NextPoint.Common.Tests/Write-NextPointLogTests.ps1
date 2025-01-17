BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Common\NextPoint.Common.psm1"
    Import-Module $ModulePath -Force
}

Describe "Write-NextPointLog" {
    BeforeEach {
        # Setup test log file path
        $script:TestLogPath = Join-Path $TestDrive "NextPoint.log"
        Mock Get-NextPointLogPath { return $script:TestLogPath }
    }

    Context "When writing log entries" {
        It "Should create log file if it doesn't exist" {
            # Act
            Write-NextPointLog -Message "Test message" -Level "Information"

            # Assert
            $script:TestLogPath | Should -Exist
        }

        It "Should write correct log format" {
            # Act
            $testMessage = "Test log message"
            Write-NextPointLog -Message $testMessage -Level "Information"

            # Assert
            $logContent = Get-Content $script:TestLogPath -Raw
            $logContent | Should -Match "\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \[Information\] $testMessage"
        }

        It "Should support different log levels" {
            # Act
            Write-NextPointLog -Message "Error message" -Level "Error"
            Write-NextPointLog -Message "Warning message" -Level "Warning"
            Write-NextPointLog -Message "Debug message" -Level "Debug"

            # Assert
            $logContent = Get-Content $script:TestLogPath
            $logContent | Should -Contain { $_ -match "\[Error\] Error message" }
            $logContent | Should -Contain { $_ -match "\[Warning\] Warning message" }
            $logContent | Should -Contain { $_ -match "\[Debug\] Debug message" }
        }
    }

    Context "When handling errors" {
        It "Should throw when log file is not writable" {
            # Arrange
            Mock Get-NextPointLogPath { return "Z:\NonExistent\Path\log.txt" }

            # Act & Assert
            { Write-NextPointLog -Message "Test" -Level "Information" } | Should -Throw
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Common -ErrorAction SilentlyContinue
}
