#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

BeforeAll {
    . (Join-Path $PSScriptRoot '../Invoke-CheckReleaseExists.ps1') -ReleaseName 'synthetic-release'
}

Describe 'Resolve-GitHubReleaseViewResult' -Tag 'Unit' {
    It 'Returns true when GitHub CLI succeeds' {
        $Result = Resolve-GitHubReleaseViewResult `
            -ReleaseName 'v1.2.3' `
            -ExitCode 0 `
            -Output '{"tagName":"v1.2.3"}'

        $Result | Should -BeTrue
    }

    It 'Returns false when GitHub CLI reports release not found' {
        $Result = Resolve-GitHubReleaseViewResult `
            -ReleaseName 'v9.9.9' `
            -ExitCode 1 `
            -Output 'release not found'

        $Result | Should -BeFalse
    }

    It 'Throws when GitHub CLI reports an operational failure' {
        {
            Resolve-GitHubReleaseViewResult `
                -ReleaseName 'v1.2.3' `
                -ExitCode 4 `
                -Output 'To get started with GitHub CLI, run: gh auth login'
        } | Should -Throw "GitHub CLI failed to check release 'v1.2.3' (exit code 4):*"
    }
}