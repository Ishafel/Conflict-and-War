# One entrypoint for local Windows development and CI. All generated state stays in build/.
[CmdletBinding()]
param(
    [ValidateSet('win-x64-clang-dbg', 'win-x64-clang-rwdi', 'win-x64-clang-rel')]
    [string] $Preset = 'win-x64-clang-rwdi',
    [ValidateSet('All', 'Prepare', 'Configure', 'Build', 'Test')]
    [string] $Stage = 'All',
    [ValidateSet('All', 'Cpp', 'Rust')]
    [string] $Component = 'All',
    [ValidateRange(1, 64)]
    [int] $Jobs = 3
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitProcess) {
    throw 'Run this script in a 64-bit PowerShell on Windows.'
}
$repoRoot = Split-Path -Parent $PSScriptRoot
$toolsRoot = Join-Path $repoRoot 'build/windows-tools'
$downloads = Join-Path $repoRoot 'build/downloads'
$logs = Join-Path $repoRoot 'build/logs'
foreach ($directory in @($toolsRoot, $downloads, $logs)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}
$logFile = Join-Path $logs (('windows-{0}-{1}.log' -f $Preset, (Get-Date -Format 'yyyyMMdd-HHmmss')))
$transcribing = $false
$currentStep = 'Prepare'

function Add-ToolPath([string] $Directory) {
    if (Test-Path -LiteralPath $Directory -PathType Container) {
        $env:PATH = $Directory + [IO.Path]::PathSeparator + $env:PATH
    }
}

function Import-VisualStudioEnvironment([string[]] $Lines) {
    # VS Enterprise may supply its bundled vcpkg, which is not our pinned checkout.
    # Preserve the caller's choice (or absence) so repository defaults still apply.
    $requestedVcpkgRoot = [Environment]::GetEnvironmentVariable('VCPKG_ROOT', 'Process')
    foreach ($line in $Lines) {
        if ($line -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process')
        }
    }
    [Environment]::SetEnvironmentVariable('VCPKG_ROOT', $requestedVcpkgRoot, 'Process')
}

function Invoke-Checked([string] $Tool, [string[]] $Arguments) {
    # Route native streams through the host so Start-Transcript records diagnostics too.
    $command = Get-Command $Tool -ErrorAction Stop
    $savedErrorAction = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $command @Arguments 2>&1 | ForEach-Object { Write-Host "$_" }
        $nativeExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $savedErrorAction
    }
    if ($nativeExitCode -ne 0) {
        throw "$currentStep failed: $Tool exited with code $nativeExitCode. See $logFile"
    }
}

function Get-Download([string] $Uri, [string] $FileName) {
    $destination = Join-Path $downloads $FileName
    if (-not (Test-Path -LiteralPath $destination)) {
        Write-Host "Downloading $FileName"
        $partial = "$destination.partial"
        Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $partial
        Move-Item -LiteralPath $partial -Destination $destination
    }
    return $destination
}

try {
    Start-Transcript -Path $logFile | Out-Null
    $transcribing = $true
    Push-Location $repoRoot
    Write-Host "Conflict & War: $Preset / $Component / $Stage"

    # vswhere discovers both the full IDE and Build Tools, including custom install paths.
    $vswhereCommand = Get-Command vswhere.exe -ErrorAction SilentlyContinue
    $vswhere = if ($vswhereCommand) { $vswhereCommand.Source } else {
        Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    }
    if (-not (Test-Path -LiteralPath $vswhere)) {
        throw 'Install Visual Studio 2022 Build Tools: Desktop development with C++, Windows SDK, C++ Clang tools and CMake tools.'
    }
    $vsPath = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $vsPath) {
        throw 'No Visual Studio C++ toolchain found. Install the Desktop development with C++ workload and a Windows SDK.'
    }
    $vsPath = $vsPath.Trim()
    $devCmd = Join-Path $vsPath 'Common7/Tools/VsDevCmd.bat'
    $developerEnvironment = & $env:ComSpec /d /c "call `"$devCmd`" -no_logo -arch=x64 -host_arch=x64 >nul && set"
    if ($LASTEXITCODE -ne 0) { throw 'Could not activate Visual Studio x64 developer environment.' }
    Import-VisualStudioEnvironment $developerEnvironment
    if (-not $env:WindowsSdkDir -or -not (Test-Path -LiteralPath $env:WindowsSdkDir)) {
        throw 'Windows SDK is missing. Add a Windows 10/11 SDK to Visual Studio Build Tools.'
    }
    Add-ToolPath (Join-Path $vsPath 'Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin')
    Add-ToolPath (Join-Path $vsPath 'Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja')

    if ($env:LLVM_ROOT) {
        if (-not (Test-Path -LiteralPath (Join-Path $env:LLVM_ROOT 'bin/clang-cl.exe'))) {
            throw 'LLVM_ROOT must contain bin/clang-cl.exe.'
        }
        Add-ToolPath (Join-Path $env:LLVM_ROOT 'bin')
    } elseif (-not (Get-Command clang-cl.exe -ErrorAction SilentlyContinue)) {
        Add-ToolPath (Join-Path $vsPath 'VC/Tools/Llvm/x64/bin')
    }
    foreach ($tool in @('git', 'cmake', 'ninja', 'clang-cl', 'clang-format')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "Missing $tool. Install the Visual Studio C++ Clang and CMake tools or put it on PATH."
        }
    }
    $env:LLVM_ROOT = Split-Path -Parent (Split-Path -Parent (Get-Command clang-cl.exe).Source)
    Invoke-Checked cmake @('--version')
    Invoke-Checked clang-cl @('--version')
    Invoke-Checked ninja @('--version')

    $ccacheVersion = '4.14.2'
    $ccacheDir = Join-Path $toolsRoot "ccache-$ccacheVersion-windows-x86_64"
    Add-ToolPath $ccacheDir
    if (-not (Get-Command ccache.exe -ErrorAction SilentlyContinue)) {
        $archive = Get-Download "https://github.com/ccache/ccache/releases/download/v$ccacheVersion/ccache-$ccacheVersion-windows-x86_64.zip" "ccache-$ccacheVersion-windows-x86_64.zip"
        Expand-Archive -LiteralPath $archive -DestinationPath $toolsRoot -Force
        Add-ToolPath $ccacheDir
    }
    if (-not (Get-Command ccache.exe -ErrorAction SilentlyContinue)) { throw 'ccache extraction did not produce ccache.exe.' }
    if (-not $env:CCACHE_DIR) { $env:CCACHE_DIR = Join-Path $repoRoot 'build/ccache' }
    Invoke-Checked ccache @('--version')

    if ($Component -ne 'Cpp') {
        $rustVersion = (Select-String -LiteralPath (Join-Path $repoRoot 'rust-toolchain.toml') -Pattern '^channel\s*=\s*"([^"]+)"').Matches.Groups[1].Value
        $localCargo = Join-Path $toolsRoot 'cargo'
        Add-ToolPath (Join-Path $localCargo 'bin')
        if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) {
            $env:CARGO_HOME = $localCargo
            $env:RUSTUP_HOME = Join-Path $toolsRoot 'rustup'
            Add-ToolPath (Join-Path $env:CARGO_HOME 'bin')
            $rustup = Get-Download 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe' 'rustup-init.exe'
            Invoke-Checked $rustup @('-y', '--no-modify-path', '--profile', 'minimal', '--default-toolchain', $rustVersion)
            Add-ToolPath (Join-Path $env:CARGO_HOME 'bin')
        } elseif (Test-Path -LiteralPath (Join-Path $localCargo 'bin/cargo.exe')) {
            $env:CARGO_HOME = $localCargo
            $env:RUSTUP_HOME = Join-Path $toolsRoot 'rustup'
        }
        Invoke-Checked cargo @('--version')
        Invoke-Checked rustc @('--version')
    }

    if ($Component -ne 'Rust') {
        $baseline = (Get-Content -LiteralPath (Join-Path $repoRoot 'vcpkg.json') -Raw | ConvertFrom-Json).'builtin-baseline'
        if (-not $env:VCPKG_ROOT) { $env:VCPKG_ROOT = Join-Path $repoRoot 'build/vcpkg' }
        $vcpkgGit = Join-Path $env:VCPKG_ROOT '.git'
        if (-not (Test-Path -LiteralPath $vcpkgGit)) {
            if (Test-Path -LiteralPath $env:VCPKG_ROOT) {
                throw 'VCPKG_ROOT exists but is not a Git checkout. Choose an empty directory or an existing vcpkg checkout.'
            }
            Invoke-Checked git @('clone', 'https://github.com/microsoft/vcpkg.git', $env:VCPKG_ROOT)
            Invoke-Checked git @('-C', $env:VCPKG_ROOT, 'checkout', $baseline)
        }
        $actualBaseline = & git -C $env:VCPKG_ROOT rev-parse HEAD
        if ($LASTEXITCODE -ne 0 -or $actualBaseline.Trim() -ne $baseline) {
            throw "vcpkg must be at $baseline. Use a separate checkout or update it explicitly after reviewing local changes."
        }
        $vcpkgChanges = & git -C $env:VCPKG_ROOT status --porcelain --untracked-files=no
        if ($LASTEXITCODE -ne 0 -or $vcpkgChanges) {
            throw 'The vcpkg checkout has tracked changes. Use a clean, pinned checkout; local changes will not be reset automatically.'
        }
        if (-not (Test-Path -LiteralPath (Join-Path $env:VCPKG_ROOT 'vcpkg.exe'))) {
            Invoke-Checked (Join-Path $env:VCPKG_ROOT 'bootstrap-vcpkg.bat') @('-disableMetrics')
        }
        $binaryCache = Join-Path $repoRoot 'build/vcpkg-cache'
        New-Item -ItemType Directory -Path $binaryCache -Force | Out-Null
        if (-not $env:VCPKG_DEFAULT_BINARY_CACHE) { $env:VCPKG_DEFAULT_BINARY_CACHE = $binaryCache }
        if (-not $env:VCPKG_DOWNLOADS) { $env:VCPKG_DOWNLOADS = $downloads }
        $env:VCPKG_DISABLE_METRICS = '1'
        $env:VCPKG_MAX_CONCURRENCY = [string]$Jobs
    }

    if ($Stage -eq 'All' -or $Stage -eq 'Configure') {
        $currentStep = 'Configure'
        if ($Component -ne 'Rust') { Invoke-Checked cmake @('--preset', $Preset) }
    }
    if ($Stage -eq 'All' -or $Stage -eq 'Build') {
        $currentStep = 'Build'
        if ($Component -ne 'Rust') { Invoke-Checked cmake @('--build', '--preset', $Preset, '--parallel', [string]$Jobs) }
        if ($Component -ne 'Cpp') { Invoke-Checked cargo @('build', '--workspace', '--locked', '--jobs', [string]$Jobs) }
    }
    if ($Stage -eq 'All' -or $Stage -eq 'Test') {
        $currentStep = 'Test'
        if ($Component -ne 'Rust') { Invoke-Checked ctest @('--preset', $Preset) }
        if ($Component -ne 'Cpp') { Invoke-Checked cargo @('test', '--workspace', '--locked', '--jobs', [string]$Jobs) }
    }
    Write-Host "SUCCESS: $Preset / $Component / $Stage. Log: $logFile"
} catch {
    Write-Host "FAILED ($currentStep): $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Log: $logFile"
    exit 1
} finally {
    if ($transcribing) {
        Pop-Location
        Stop-Transcript | Out-Null
    }
}
