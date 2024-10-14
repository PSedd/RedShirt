# Function to reformat the timestamp
function Reformat-Timestamp {
    param (
        [string]$timestamp
    )
    $datetime = [datetime]::ParseExact($timestamp, "yyyy-MM-ddTHH:mm:ss.fffZ", $null)
    return $datetime.ToString("M/d/yyyy HH:mm:ss")
}

# Prompt user for the directory containing JSON files
$directory = Read-Host "Please enter the directory containing the JSON files"

# Check if the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Output "Directory does not exist. Exiting script."
    exit
}

# Define the CSV headers
$headers = "Mitre Technique Id", "Procedure Name", "Start Time", "Stop Time", "Command"

# Output CSV file path
$outputCsvPath = Join-Path $directory "output.csv"

# Initialize the CSV file with headers
$headers -join ',' | Out-File -FilePath $outputCsvPath -Encoding utf8

# Iterate through all JSON files in the directory
Get-ChildItem -Path $directory -Filter *.json | ForEach-Object {
    $jsonFilePath = $_.FullName
    # Load the JSON data
    $data = Get-Content -Path $jsonFilePath | ConvertFrom-Json

    # Iterate through the procedures and extract the necessary fields
    foreach ($procedure in $data.procedures) {
        $techniqueId = $procedure.'mitre-technique-id'
        $procedureName = $procedure.'procedure-name'
        foreach ($step in $procedure.steps) {
            $startTime = Reformat-Timestamp -timestamp $step.'time-start'
            $stopTime = Reformat-Timestamp -timestamp $step.'time-stop'
            $command = $step.command -replace '"', '""' # Escape double quotes for CSV
            $row = "$techniqueId,$procedureName,$startTime,$stopTime,""$command"""
            $row | Out-File -FilePath $outputCsvPath -Append -Encoding utf8
        }
    }
}

Write-Output "Data extracted to output.csv successfully."
