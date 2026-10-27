[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string] $DataDir,
    [switch] $Slice,
    [ValidateSet('x64-win-rwdi','x64-win-dbg','x64-win-rel')][string] $Configuration='x64-win-rwdi'
)
$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
$distribution=Join-Path $repo "dist/$Configuration"
$game=Join-Path $distribution 'PoseidonGame.exe'
$data=(Resolve-Path -LiteralPath $DataDir).Path
if (!(Test-Path -LiteralPath (Join-Path $data 'Worlds'))) { throw 'DataDir must contain the external game Worlds directory (Everon required).' }
if (!(Test-Path -LiteralPath $game)) { throw 'Build the game with ./build.cmd -Component Cpp first.' }
$content=Join-Path $distribution 'cw'
if (!(Test-Path -LiteralPath (Join-Path $content 'ui/resources.cpp'))) { throw 'C&W content missing: rebuild the CWRContent target.' }
$gameArguments=@('-C',$data,'--window','--width','1280','--height','720')
if ($Slice) { $gameArguments+=@('--test-mission',(Join-Path $content 'Missions/CWEveron.eden')) }
& $game @gameArguments
exit $LASTEXITCODE
