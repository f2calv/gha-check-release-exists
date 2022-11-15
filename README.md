# GitHub Action: Check Release Exists

This GitHub Action executes GitHub CLI and evaluates it's output to see if a release name exists in the current repository, with this information you can then determine whether or not to create a new release.

## Example

```yaml
steps:

- uses: f2calv/gha-check-release-exists@1
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ReleaseName: 1.2.3
    #Note: ideally pass in the desired release name from another action output
    #ReleaseName: ${{ steps.gitversion.outputs.SemVer }}
```

## Inputs

- GITHUB_TOKEN, i.e. secrets.GITHUB_TOKEN
- ReleaseName, i.e. `1.2.2` or `1.2.2-2022-04-ci-updates.13`

## Outputs

- ReleaseExists, i.e. `True` or `False`
