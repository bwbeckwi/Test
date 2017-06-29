#Requires -Version 4

[cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
param ()

# Set unrestricted execution policy so scripts can be executed remotely
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Get the module path
$CurrentPSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")

# Remove our module path if it is already there so we do not add duplicates
$CurrentPSModulePath = $CurrentPSModulePath.Replace(";C:\VirTra\PowerShell\Modules", "")

# Append our module path
[Environment]::SetEnvironmentVariable("PSModulePath", $CurrentPSModulePath + ";C:\VirTra\PowerShell\Modules", "Machine")