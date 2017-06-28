#Requires -Version 4

[cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]

param ([string]$DeploySource=$(Read-Host "Enter user name or press enter to deploy latest build"))

Import-module VirTraDeployUtilities

$sourcePath = ""

if ([string]::IsNullOrEmpty($DeploySource) -Or [string]::Compare($DeploySource, "buildserver", $True) -eq 0)
{
    $sourcePath = "\\buildserver\LatestBuild\Release\Installers"
}
else
{
    $sourcePath = "\\virtrana2\development\drivingsim\$DeploySource"
}

# Copy installers to temp directory on master

Write-Host "`nCreating C:\Temp\DrivingSim\" -ForegroundColor Green
New-Item "C:\Temp\DrivingSim\" -Force -Type Directory

Write-Host "`nCopying $sourcePath\VirTra.DrivingSim.Installer.msi to C:\Temp\DrivingSim" -ForegroundColor Green
Copy-Item "$sourcePath\VirTra.DrivingSim.Installer.msi" "C:\Temp\DrivingSim" -Force

Write-Host "`nCopying $sourcePath\VirTra.DrivingSim.Simulator.Installer.exe to C:\Temp\DrivingSim" -ForegroundColor Green
Copy-Item "$sourcePath\VirTra.DrivingSim.Simulator.Installer.exe" "C:\Temp\DrivingSim" -Force

# Stop the driving sim service on master

Write-Host "`nStopping driving sim service on Master" -ForegroundColor Green
Stop-Process -Name "VirTra.DrivingSim.Service" -Force

# Install on master

Write-Host "`nInstalling VirTra.DrivingSim.Installer.msi on Master" -ForegroundColor Green
InstallFile -file "C:\Temp\DrivingSim\VirTra.DrivingSim.Installer.msi" -args $true -arguments "/quiet"

Write-Host "`nInstalling VirTra.DrivingSim.Simulator.Installer.exe on Master" -ForegroundColor Green
InstallFile -file "C:\Temp\DrivingSim\VirTra.DrivingSim.Simulator.Installer.exe" -args $true -arguments "/S"

# Clean up temp on master

Write-Host "`nCleaning up C:\Temp\DrivingSim\" -ForegroundColor Green
Remove-Item -Recurse -Force "C:\Temp\DrivingSim\"

# Start up the driving sim service on master

Write-Host "`nStarting driving sim service on Master" -ForegroundColor Green
Start-Process -FilePath "C:\VirTra\Programs\DrivingSim\Service\VirTra.DrivingSim.Service.exe" -Verb runAs

# Create a list of the clusters we want to install on

$clusters = @(
    "IVR-CLUSTER1",
    "IVR-CLUSTER2",
    "IVR-CLUSTER3",
    "IVR-CLUSTER4",
    "IVR-CLUSTER6")

# Copy installer to temp directory on the clusters

foreach ($cluster in $clusters)
{
    Write-Host "`nCreating \\$cluster\VirTra\Temp\DrivingSim\" -ForegroundColor Green
    New-Item "\\$cluster\VirTra\Temp\DrivingSim\" -Force -Type Directory

    Write-Host "`nCopying $sourcePath\VirTra.DrivingSim.Simulator.Installer.exe to \\$cluster\VirTra\Temp\DrivingSim" -ForegroundColor Green
    Copy-Item "$sourcePath\VirTra.DrivingSim.Simulator.Installer.exe" "\\$cluster\VirTra\Temp\DrivingSim" -Force
}

# Install on the clusters

Write-Host "`nInstalling VirTra.DrivingSim.Simulator.Installer.exe on $clusters" -ForegroundColor Green
Invoke-Command -ComputerName $clusters -ScriptBlock { InstallFile -file "C:\VirTra\Temp\DrivingSim\VirTra.DrivingSim.Simulator.Installer.exe" -args $true -arguments "/S" }

# Clean up temp on the clusters

foreach ($cluster in $clusters)
{
    Write-Host "`nCleaning up \\$cluster\VirTra\Temp\DrivingSim\" -ForegroundColor Green
    Remove-Item -Recurse -Force "\\$cluster\VirTra\Temp\DrivingSim\"
}
