#Checks to see if a release already exists.
#i.e. If the release already exists then we wouldn't want to create a new release as it'll fail with an error 'version x.x.x already exists'.

Param(
    [Parameter(Mandatory = $true)][System.String][ValidateNotNullOrEmpty()]$ReleaseName
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

Write-Host "Release Name`t`t:`t$ReleaseName"

#Note: sadly gh cli doesn't have --json output on all commands so we parse the response manually.
$prior = (gh release list --limit 1)
$priorRelease = "0.0.0"
if ($null -ne $prior) {
    $priorRelease = $prior.Split("`t")[0]
}
Write-Host "Previous Release`t:`t$priorRelease"

if (($ReleaseName -eq $priorRelease)) {
    Write-Host "Release '$ReleaseName' already exists."
    return $true
}
else {
    Write-Host "Release '$ReleaseName' not found."
    return $false
}