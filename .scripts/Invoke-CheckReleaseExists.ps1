#Checks to see if a release already exists.
#i.e. If the release already exists then we wouldn't want to create a new release as it'll fail with an error 'version x.x.x already exists'.

Param(
    [Parameter(Mandatory = $true)][System.String][ValidateNotNullOrEmpty()]$ReleaseName
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

Write-Host "Release Name`t`t:`t$ReleaseName"

$null = gh release view $ReleaseName --json tagName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Warning "Release '$ReleaseName' already exists."
    return $true
}
else {
    Write-Host "Release '$ReleaseName' not found."
    return $false
}