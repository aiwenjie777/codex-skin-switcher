[CmdletBinding()]
param(
  [int]$Port = 9335,
  [string]$ScreenshotPath,
  [string]$Theme
)

$ErrorActionPreference = 'Stop'
$node = (Get-Command node -ErrorAction Stop).Source
$injector = Join-Path $PSScriptRoot 'injector.mjs'
$arguments = @($injector, '--verify', '--port', "$Port")
if ($ScreenshotPath) { $arguments += @('--screenshot', $ScreenshotPath) }
if ($Theme) { $arguments += @('--theme', $Theme) }
& $node @arguments
exit $LASTEXITCODE
