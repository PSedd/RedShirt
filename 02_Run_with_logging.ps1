#Below might(?) be necessary when making powershell->exe
Set-ExecutionPolicy Bypass -Scope Process -Force
# Define the base path for atomic test files
$basePath = "C:\AtomicRedTeam\atomics\"

$atomicDir = "C:\AtomicRedTeam\"
# Define the path to the text file containing the list of atomic test IDs
$fileListPath = "C:\AtomicRedTeam\invoke-atomicredteam\IDList.txt"

# Define the log directory path
$logDirPath = "C:\AtomicRedTeam\invoke-atomicredteam\Logs"

# Create the log directory if it doesn't exist
if (-not (Test-Path -Path $logDirPath)) {
    New-Item -ItemType Directory -Path $logDirPath
}

# Read the list of atomic test IDs from the text file
$testIDs = Get-Content $fileListPath

foreach ($testID in $testIDs) {
    # Wait for the next full minute before executing the next test
    $currentTime = Get-Date
    $nextFullMinute = $currentTime.AddMinutes(1).AddSeconds(-$currentTime.Second)
    $timeToWait = ($nextFullMinute - $currentTime).TotalSeconds
    Start-Sleep -Seconds $timeToWait
    
    # Construct the full path to the atomic technique file
    $testFilePath = Join-Path $basePath "$testID\T*.yaml"
    Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing).Content
    #Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SecurityRiskAdvisors/invoke-atomic-attire-logger/main/Attire-ExecutionLogger.psm1' -OutFile "$atomicDir\invoke-atomicredteam\Loggers\Attire-ExecutionLogger.psm1" -UseBasicParsing
    Import-Module "$atomicDir\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
    Import-Module "$atomicDir\invoke-atomicredteam\Loggers\Attire-ExecutionLogger.psm1" -Force
    # Load the atomic technique from the file
    $technique = Get-AtomicTechnique -Path $testFilePath
    
    foreach ($atomic in $technique.atomic_tests) {
        if ($atomic.supported_platforms.contains("windows") -and ($atomic.executor -ne "manual")) {
            $logPath = Join-Path $logDirPath "$($technique.attack_technique)-$($atomic.auto_generated_guid).json"
            
            # Get Prereqs for test
            Invoke-AtomicTest $technique.attack_technique -TestGuids $atomic.auto_generated_guid -GetPrereqs
            
            # Invoke
            Invoke-AtomicTest $technique.attack_technique -TestGuids $atomic.auto_generated_guid `
                -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $logPath
            
            # Sleep then cleanup
            Start-Sleep 3
            Invoke-AtomicTest $technique.attack_technique -TestGuids $atomic.auto_generated_guid -Cleanup
        }
    }
}
