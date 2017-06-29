#Requires -Version 4

[cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
param ()

# Set execution policy so scripts can be executed remotely
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Get the module path
$CurrentPSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")

# Remove our module path if it is already there so we do not add duplicates
#$CurrentPSModulePath = $CurrentPSModulePath.Replace(";C:\VirTra\PowerShell\Modules", "")
$CurrentPSModulePath = $CurrentPSModulePath.Replace(";($env:userprofile + '\Documents\WindowsPowerShell\Modules')", "")

# Append our module path
[Environment]::SetEnvironmentVariable("PSModulePath", $CurrentPSModulePath + ";($env:userprofile + '\Documents\WindowsPowerShell\Modules')", "Machine")