<#
.Synopsis
A function used to export all NSGs rules, check your Azure flow logs for hits relating to these NSG's in all your Azure Subscriptions and format them in a .csv

.DESCRIPTION
# PowerShell function perform NSG Review

# Call the function with your desired parameters
Get-FileHashes -src xxx -dst xxxx 

.Notes
Created   : 11-October-2023
Updated   : 11-October-2023
Version   : 1.0
Author    : NoodleStorm


Disclaimer: This script is provided "AS IS" with no warranties.
#>


function Get-FileHashes {
    param (
        [string]$src = $null,
        [string]$dst = $null,
        [string]$filename = $null
    )

    while ([string]::IsNullOrEmpty($src)) {
        $src = Read-Host "Enter src location, leave blank for current dir"

        if ([string]::IsNullOrEmpty($src)) {
            Write-Host "Location set to current dir"
            $src = Get-Location
        }
        elseif (-not (Test-Path $src)) {
            Write-Host "Invalid directory path, re-enter."
            $src = $null
        }
    }

    while ([string]::IsNullOrEmpty($dst)) {
        $dst = Read-Host "Enter output location, leave blank for current dir"

        if ([string]::IsNullOrEmpty($dst)) {
            Write-Host "Location set to current dir"
            $dst = Get-Location
        }
        elseif (-not (Test-Path $dst)) {
            Write-Host "Invalid directory path, re-enter."
            $dst = $null
        }
    }

    while ([string]::IsNullOrEmpty($filename)) {
        $filename = Read-Host "Enter file name, leave blank for 'hashes.csv"

        if ([string]::IsNullOrEmpty($filename)) {
            $filename = "hashes"
        }
    }

    $filename += ".csv"

    $outputarray = @()
    $Path = Get-ChildItem -Path $src -Recurse -Attributes !Directory
    Write-Output "Working....."

    foreach ($i in $Path) {
        $hashes = [ordered]@{
            FileName = $i.FullName
            MD5 = (Get-FileHash $i.Fullname -Algorithm MD5).Hash
            SHA1 = (Get-FileHash $i.Fullname -Algorithm SHA1).Hash
        }

        $hashobj = New-Object -Type PSObject -Property $hashes
        $outputarray += $hashobj
    }

    $compiled_outfile = Join-Path -Path $dst -ChildPath $filename
    $outputarray | Export-Csv -NoTypeInformation -Path $compiled_outfile -Encoding UTF8 -Force
}
