Function Get-BBInstalledSoftware
{
<#	
.SYNOPSIS
.DESCRIPTION
.EXAMPLE
.PARAMETER
.NOTES
Version:    1.0.2
Updated:    July 05, 2017
Purpose:    Changed output file name by including the date and time the 
			script was run.
	
Version:    1.0.1
Updated:    June 22, 2017
Purpose:    Stopped information from being displayed on
            the default screen.
	
Version:	1.0.0
Author:		Brad Beckwith
Group:		IKGF ISE Team
Date:		May 8, 2017
#>
	
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
	param
	(
		[parameter(mandatory = $false,
				   ValueFromPipeline = $True,
				   ValueFromPipelineByPropertyName = $True)
		]
		[alias('hostname')]
		[ValidateLength(1, 16)]
		[ValidateCount(1, 125)]
		[string]$computername = ($ENV:Computername),
		[string]$dt = (Get-Date -uformat "%Y%m%d%H%M%S"),
		[string]$output = "$computername.SoftwareList.$dt.txt",
		[string]$outputcsv = "$computername.SoftwareList.$dt.csv"
	)
	
	#CLEAR
	
	If (test-path 'C:\temp')
	{
		Set-Location -Path 'C:\temp'
	}
	Else
	{
		Write-Warning "Temp directory does not exist; Exiting Script"
		Exit
	}
	
	Write-Host "`nGathering local software list`n" -ForegroundColor Green
	
	Write-Verbose "Creating empty arrays`n"
	$arry = @()
	$arrya = @()
	$arryb = @()
	
	Write-Verbose "Creating Array A`n"
	$arrya = invoke-command {
		Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall |
		Foreach { Get-ItemProperty $_.PsPath } |
		where { $_.Displayname -and ($_.Displayname -match ".*") } |
		sort Displayname | select DisplayName, Publisher, DisplayVersion
	} -ComputerName $computername
	
	Write-Verbose "Creating Array B`n"
	$arryb = invoke-command {
		Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
		Foreach { Get-ItemProperty $_.PsPath } |
		where { $_.Displayname -and ($_.Displayname -match ".*") } |
		sort Displayname | select DisplayName, Publisher, DisplayVersion
	} -ComputerName $computername
	
	Write-Verbose "Creating main Array`n"
	$arry = $arrya + $arryb
	
	Write-Verbose "Selecting Columns of data and placing into output files.`n"
	$arry | select DisplayName, Publisher, DisplayVersion -Unique | sort DisplayName | Out-File $output
	
	# Creating CSV File
	if (Test-Path $output)
	{
		$a = Get-Content $output | Select -skip 1
		$a = $a -replace "`0", " "
		$a | out-file $output
		$a = $a -replace "\s{2,}", ","
		$a = $a -replace "Microsoft.P", "Microsoft"
		$a -replace ",$", "" | Out-Null
		$a = $a -replace ",$", ""
		$a | Out-file $outputcsv
		#$a | Select -skip 1 | Out-file $outputcsv
		
		Write-Host "`nCompleted... See ""$output"" for a list of installed software" -ForegroundColor Green
		
		if (Test-Path $outputcsv)
		{
			Write-Host "Completed... See ""$outputcsv"" for a list of installed software in CSV format`n" -ForegroundColor Green
		}
	}
	else
	{
		Write-Warning "Path/File: $output does not exist. Cannot create 'txt' or 'csv' files"
	}
	
} #End: Function Get-InstalledSoftware