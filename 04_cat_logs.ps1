# Define the log directory path and combined log file path
$logDirPath = "C:\AtomicRedTeam\invoke-atomicredteam\Logs"
$combinedLogFilePath = "C:\AtomicRedTeam\invoke-atomicredteam\CombinedLog.json"

# Initialize the combined log structure
$combinedLog = @{
    "attire-version" = "1.1"
    "execution-data" = @{
        "execution-command" = "Combined Logs"
        "execution-id" = (New-Guid).ToString()
        "execution-source" = "Atomic Red Team Combined Logs"
        "execution-category" = @{
            "name" = "Atomic Red Team"
            "abbreviation" = "art"
        }
        "target" = @{
            "host" = $env:COMPUTERNAME
            "ip" = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq "Ethernet" }).IPAddress
            "path" = $env:PATH
            "user" = "$env:USERNAME"
        }
        "time-generated" = (Get-Date).ToString("o")
    }
    "procedures" = @()
}

# Read each log file and extract the relevant data
$logFiles = Get-ChildItem -Path $logDirPath -Filter "*.json"
foreach ($logFile in $logFiles) {
    $logContent = Get-Content -Path $logFile.FullName -Raw | ConvertFrom-Json
    
    if ($logContent.procedures) {
        foreach ($procedure in $logContent.procedures) {
            $combinedLog.procedures += $procedure
        }
    }
}

# Convert the combined log structure to JSON and save to the combined log file
$combinedLog | ConvertTo-Json -Depth 10 | Set-Content -Path $combinedLogFilePath
