#You sHoUlD be able to run this as a script via the following in powershell:
#Set-ExecutionPolicy Bypass -Scope Process -Force
#./01_Install_and_Load.ps1


#New Script:
#Make Directory
mkdir C:\AtomicRedTeam

# Set Directory
$atomicDir = "C:\AtomicRedTeam\"

# Add Windows Defender exclusion for AtomicRedTeam
Add-MpPreference -ExclusionPath $atomicDir

# Disable Windows Defender (Hit or Miss)
Set-MpPreference -DisableRealtimeMonitoring $true

# Set PowerShell execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Download and install  Invoke Atomic
Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing).Content

# Download and install attire logger (not verified and likely doesn't work, but it doesn't error out, so I'm leaving it)
Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/SecurityRiskAdvisors/invoke-atomic-attire-logger/main/Attire-ExecutionLogger.psm1' -UseBasicParsing).Content

# Install Atomic Red Team (No Force, will not overwrite existing, read ART docs for more detail)
Install-AtomicRedTeam -getAtomics

#make log path dir
mkdir C:\atomicredteam\invoke-atomicredteam\Loggers

#Download the Logging Module
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SecurityRiskAdvisors/invoke-atomic-attire-logger/main/Attire-ExecutionLogger.psm1' -OutFile "$atomicDir\invoke-atomicredteam\Loggers\Attire-ExecutionLogger.psm1" -UseBasicParsing

#mv to load
cd $atomicDir
# Import the module
Import-Module ".\invoke-atomicredteam\Invoke-AtomicRedTeam.psm1" -Force

#imports attire logger
Import-Module ".\invoke-atomicredteam\Loggers\Attire-ExecutionLogger.psm1" -Force

#download all prerequisites
#Will take a long time. Go get coffee.
Invoke-AtomicTest All -GetPrereqs

#enter a basic test so we can check it works
$TestTID = "T1082"
$TestTid | Out-File -FilePath 'C:\AtomicRedTeam\invoke-atomicredteam\IDList.txt'
