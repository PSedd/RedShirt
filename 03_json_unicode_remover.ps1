# Define the directory containing the JSON files
$directoryPath = "C:\AtomicRedTeam\invoke-atomicredteam\Logs"

# Get all JSON files in the directory
$jsonFiles = Get-ChildItem -Path $directoryPath -Filter *.json

# Define a regex pattern to match all Unicode escape sequences
$unicodePattern = '\\u[0-9A-Fa-f]{4}'

# Loop through each JSON file
foreach ($file in $jsonFiles) {
    # Read the content of the JSON file
    $content = Get-Content -Path $file.FullName -Raw

    # Remove all Unicode escape sequences from the content
    $content = $content -replace $unicodePattern, ''

    # Save the modified content back to the JSON file
    Set-Content -Path $file.FullName -Value $content
}

Write-Host "All Unicode characters removed from JSON files in directory: $directoryPath"
