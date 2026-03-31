# GitHub Action: Check Release Exists

[![Latest Release](https://img.shields.io/github/v/release/f2calv/gha-check-release-exists)](https://github.com/f2calv/gha-check-release-exists/releases/latest)
[![License](https://img.shields.io/github/license/f2calv/gha-check-release-exists)](LICENSE)

This GitHub Action uses the GitHub CLI to check whether a specific release exists in the current repository. With this information you can then determine whether or not to create a new release.

## Usage

```yaml
steps:
  # Insert your automated versioning step here, e.g. gitversion, etc...
  - name: gitversion (1 of 2)
    uses: gittools/actions/gitversion/setup@v4
    with:
      versionSpec: 6.x

  - name: gitversion (2 of 2)
    id: gitversion
    uses: gittools/actions/gitversion/execute@v4
    with:
      useConfigFile: true
      additionalArguments: /nofetch

  - name: check-release-exists
    id: check-release-exists
    uses: f2calv/gha-check-release-exists@v2
    with:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      ReleaseName: ${{ steps.gitversion.outputs.semVer }}

  # Insert your build steps here, e.g. nuget, container, etc...

  - name: publish
    shell: bash
    run: |
      # dotnet nuget push ...
      # docker push ...
      # etc...
    if: >-
      ${{ steps.check-release-exists.outputs.ReleaseExists == 'false' &&
        (github.ref == format('refs/heads/{0}', github.event.repository.default_branch) ||
         github.event.inputs.PublishPreview == 'true') }}
```

## Inputs

| Name | Required | Description |
| ---- | -------- | ----------- |
| `GITHUB_TOKEN` | ✅ | GitHub token used to query releases, i.e. `secrets.GITHUB_TOKEN` |
| `ReleaseName` | ✅ | Release name to check for, i.e. `1.2.2` or `1.2.2-2022-04-ci-updates.12` |

## Outputs

| Name | Description | Values |
| ---- | ----------- | ------ |
| `ReleaseExists` | Whether the named release already exists | `true` or `false` |
