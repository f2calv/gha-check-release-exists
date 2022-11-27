# GitHub Action: Check Release Exists

This GitHub Action executes GitHub CLI and evaluates it's output to see if a release name exists in the current repository, with this information you can then determine whether or not to create a new release.

## Example

```yaml
steps:

#insert your automated versioning system/tool here, e.g. gitversion, etc...
- name: gitversion
  shell: pwsh
  id: gitversion
  run: |
    dotnet tool update -g GitVersion.Tool
    $GitVersion = dotnet-gitversion ${{ github.workspace }} /nofetch | ConvertFrom-Json
    Write-Host "SemVer=$($GitVersion.SemVer)"
    echo "SemVer=$($GitVersion.SemVer)" >> $env:GITHUB_OUTPUT
    Write-Host "FullSemVer=$($GitVersion.FullSemVer)"
    echo "FullSemVer=$($GitVersion.FullSemVer)" >> $env:GITHUB_OUTPUT

- uses: f2calv/gha-check-release-exists@v1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ReleaseName: 1.2.3
    #Note: ideally pass in the desired release name from another action output
    #ReleaseName: ${{ steps.gitversion.outputs.SemVer }}

#insert your build steps here, e.g. nuget, container, etc...

#push package/create release
- name: dotnet push (api.nuget.org)
  shell: bash
  run: |
    #dotnet nuget push ...
    #docker push ...
    #etc...
  if: |
    steps.check-release-exists.outputs.ReleaseExists == 'false'
      && (github.ref == format('refs/heads/{0}', github.event.repository.default_branch) || github.event.inputs.PublishPreview == 'true')
```

## Inputs

- GITHUB_TOKEN, i.e. secrets.GITHUB_TOKEN
- ReleaseName, i.e. `1.2.2` or `1.2.2-2022-04-ci-updates.12`

## Outputs

- ReleaseExists, i.e. `True` or `False`
