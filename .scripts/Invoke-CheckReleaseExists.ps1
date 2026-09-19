#!/usr/bin/env pwsh
#Requires -Version 7.4

<#
.SYNOPSIS
    Checks whether a GitHub release exists in the current repository.
.DESCRIPTION
    Queries GitHub CLI for a release by tag name and returns a Boolean. A successful query returns
    true. GitHub CLI's release-not-found response returns false. Authentication, network, API, and
    other GitHub CLI failures terminate the script with a nonzero exit code instead of being
    reported as a missing release.
.PARAMETER ReleaseName
    Tag name of the GitHub release to check.
.EXAMPLE
    ./.scripts/Invoke-CheckReleaseExists.ps1 -ReleaseName 'v2.1.0'
.NOTES
    Requires GitHub CLI to be installed and authenticated for the current repository. In GitHub
    Actions, authentication is supplied through the GITHUB_TOKEN environment variable.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$PSNativeCommandUseErrorActionPreference = $false

#region Functions

function Invoke-GitHubReleaseView {
    <#
    .SYNOPSIS
        Invokes GitHub CLI to retrieve a release.
    .PARAMETER ReleaseName
        Tag name of the GitHub release to retrieve.
    .OUTPUTS
        PSCustomObject containing the GitHub CLI exit code and combined output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseName
    )

    $Output = @(
        & gh release view $ReleaseName --json tagName 2>&1 | ForEach-Object { $_.ToString() }
    )

    [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = $Output
    }
}

function Resolve-GitHubReleaseViewResult {
    <#
    .SYNOPSIS
        Converts a GitHub CLI release-view result to an existence Boolean.
    .PARAMETER ReleaseName
        Tag name of the GitHub release that was queried.
    .PARAMETER ExitCode
        Exit code returned by GitHub CLI.
    .PARAMETER Output
        Combined standard output and standard error returned by GitHub CLI.
    .OUTPUTS
        Boolean indicating whether the release exists.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseName,

        [Parameter(Mandatory = $true)]
        [int]$ExitCode,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Output
    )

    if ($ExitCode -eq 0) {
        return $true
    }

    $Message = ($Output -join [Environment]::NewLine).Trim()
    if ($ExitCode -eq 1 -and $Message -eq 'release not found') {
        return $false
    }

    $Details = if ([string]::IsNullOrWhiteSpace($Message)) {
        'GitHub CLI returned no diagnostic output.'
    }
    else {
        $Message
    }

    throw "GitHub CLI failed to check release '$ReleaseName' (exit code $ExitCode): $Details"
}

function Test-GitHubReleaseExists {
    <#
    .SYNOPSIS
        Checks whether a GitHub release exists.
    .PARAMETER ReleaseName
        Tag name of the GitHub release to check.
    .OUTPUTS
        Boolean indicating whether the release exists.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseName
    )

    $Result = Invoke-GitHubReleaseView -ReleaseName $ReleaseName
    return Resolve-GitHubReleaseViewResult `
        -ReleaseName $ReleaseName `
        -ExitCode $Result.ExitCode `
        -Output @($Result.Output)
}

#endregion Functions

#region Main Execution

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Write-Host "Release Name`t`t:`t$ReleaseName"
        $ReleaseExists = Test-GitHubReleaseExists -ReleaseName $ReleaseName

        if ($ReleaseExists) {
            Write-Warning "Release '$ReleaseName' already exists."
        }
        else {
            Write-Host "Release '$ReleaseName' not found."
        }

        Write-Output $ReleaseExists
        exit 0
    }
    catch {
        Write-Error -ErrorAction Continue "Check release failed: $($_.Exception.Message)"
        exit 1
    }
}

#endregion Main Execution
