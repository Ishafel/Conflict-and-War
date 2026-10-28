# FR-014: execute the actual import function without installing tools or changing the SDK.
$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot '../../scripts/windows-build.ps1'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    (Resolve-Path -LiteralPath $scriptPath), [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw ($parseErrors | Out-String) }
$definition = $ast.Find({ param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq 'Import-VisualStudioEnvironment'
}, $true)
if (-not $definition) { throw 'Missing production environment import function.' }
. ([scriptblock]::Create($definition.Extent.Text))

$savedRoot = [Environment]::GetEnvironmentVariable('VCPKG_ROOT', 'Process')
$savedProbe = [Environment]::GetEnvironmentVariable('CWR_ENV_IMPORT_TEST', 'Process')
try {
    $callerRoot = Join-Path $PSScriptRoot 'pinned checkout with spaces'
    $bundledRoot = Join-Path $PSScriptRoot 'VS bundled checkout'
    $env:VCPKG_ROOT = $callerRoot
    Import-VisualStudioEnvironment @("VCPKG_ROOT=$bundledRoot", 'CWR_ENV_IMPORT_TEST=sdk=value')
    if ($env:VCPKG_ROOT -ne $callerRoot) { throw 'VS replaced the explicit pinned checkout.' }
    if ($env:CWR_ENV_IMPORT_TEST -ne 'sdk=value') { throw 'SDK values containing equals were not imported.' }

    [Environment]::SetEnvironmentVariable('VCPKG_ROOT', $null, 'Process')
    Import-VisualStudioEnvironment @("VCPKG_ROOT=$bundledRoot", 'CWR_ENV_IMPORT_TEST=default')
    if ([Environment]::GetEnvironmentVariable('VCPKG_ROOT', 'Process')) {
        throw 'VS installed a default VCPKG_ROOT instead of allowing the repository default.'
    }
    if ($env:CWR_ENV_IMPORT_TEST -ne 'default') { throw 'Other VS variables were not imported.' }
    Write-Output 'PASS: explicit/default vcpkg choice preserved; other developer variables imported.'
} finally {
    [Environment]::SetEnvironmentVariable('VCPKG_ROOT', $savedRoot, 'Process')
    [Environment]::SetEnvironmentVariable('CWR_ENV_IMPORT_TEST', $savedProbe, 'Process')
}
