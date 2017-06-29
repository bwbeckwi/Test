#Requires -Version 4

[cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
#Support Whatif
param ()

Function InstallFile {

    [cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param
    (   
        [parameter(Mandatory = $true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$file,

        [parameter(Mandatory = $true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [bool]$args = $false,

        [parameter(Mandatory = $false,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$false)]
        [string]$arguments = "/S /v /qn"
    )

    if (Test-path -Path $file)
    {
        Write-Host "Installing $file" -ForegroundColor Green
        if ($args -eq $true)
        {
            Write-Verbose "We have arguments: $arguments"
            Start-Process $file -ArgumentList $arguments -Wait
        }
        else
        {
            Write-Host "No arguments provided" -ForegroundColor Green
            Start-Process $file -Wait 
        }
    }
    else
    {
        Write-Host "File: $file does not exist..." -ForegroundColor Red
    }

    Write-Host "End Install" -ForegroundColor Green

}

Function UninstallProgram {

    [cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param
    (   
        [parameter(Mandatory = $true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$program
    )

    $app = Get-WmiObject -Class Win32_Product -Filter ("Name = '" + $program + "'")
    if($app -ne $null)
    {
        $app.Uninstall()
    }
    else
    {
        Write-Host "`nCould not find program '" $program "'" -ForegroundColor Red
    }
}

Function DisableUAC {
    ## Disable UAC
    Write-Host "`nDisabling UAC Control" -ForegroundColor Green
    New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system `
    -Name EnableLUA -PropertyType DWord -Value 0 -Force
}

Function DisableCortana {

    # Disable Cortana
    Write-Host "Disabling Cortana..." -ForegroundColor Green
    
    If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
    }
   
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
   
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }
    
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
}

Function DisableFirewall {
    # Disable Firewall
    Write-Host "Disabling Firewall..." -ForegroundColor Green
    Set-NetFirewallProfile -Profile * -Enabled False
}

Function DisableDefender {
    # Disable Windows Defender
    Write-Host "Disabling Windows Defender..."
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
}

Function EnableRemoteDesktop {
    # Enable Remote Desktop w/o Network Level Authentication
    Write-Host "Enabling Remote Desktop w/o Network Level Authentication..." -ForegroundColor Green
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
}

Function HideSearchButton {
    # Hide Search button / box
    Write-Host "Hiding Search Box / Button..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
}

Function HideTaskView {
    # Hide Task View button
    Write-Host "Hiding Task View button..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
}
