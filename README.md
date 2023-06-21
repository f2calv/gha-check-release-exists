# GitHub Action: Check Release Exists

This GitHub Action executes GitHub CLI and evaluates it's output to see if a release name exists in the current repository, with this information you can then determine whether or not to create a new release.

## Example

```yaml
steps:

#insert your automated versioning system/tool here, e.g. gitversion, etc...
- name: gitversion (1 of 2)
  uses: gittools/actions/gitversion/setup@v0
  with:
    versionSpec: 5.x

- name: gitversion (2 of 2)
  id: gitversion
  uses: gittools/actions/gitversion/execute@v0
  with:
    useConfigFile: true
    additionalArguments: /nofetch

- uses: f2calv/gha-check-release-exists@v2
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ReleaseName: 1.2.3
    #Note: ideally pass in the desired release name from another action output
    #ReleaseName: ${{ steps.gitversion.outputs.semVer }}

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
