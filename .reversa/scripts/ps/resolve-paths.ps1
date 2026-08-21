$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $PSCommandPath
$projectRoot = (Resolve-Path (Join-Path $scriptDir '..\..\..')).Path
$setupPath = Join-Path $projectRoot '.reversa\setup.json'

$pathDefaults = @{
  'config-dir' = '.reversa'
  'sdd-dir' = 'reversa/sdd'
  'forward-dir' = 'reversa/forward'
  'docs-dir' = 'reversa/docs'
  'bugs-dir' = 'reversa/bugs'
}

$configuredPaths = @{}
if (Test-Path -LiteralPath $setupPath -PathType Leaf) {
  $setup = Get-Content -LiteralPath $setupPath -Raw -Encoding utf8 | ConvertFrom-Json
  if ($setup.paths) {
    foreach ($property in $setup.paths.PSObject.Properties) {
      $configuredPaths[$property.Name] = [string]$property.Value
    }
  }
}

function Resolve-ReversaProjectPath {
  param([Parameter(Mandatory)][string]$Name)

  $relativePath = $configuredPaths[$Name]
  if ([string]::IsNullOrWhiteSpace($relativePath)) {
    $relativePath = $pathDefaults[$Name]
  }
  if ([System.IO.Path]::IsPathRooted($relativePath)) {
    throw "Reversa path '$Name' must be relative to the project root: $relativePath"
  }

  $resolved = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $relativePath))
  $rootPrefix = $projectRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  if ($resolved -ne $projectRoot -and
      -not $resolved.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Reversa path '$Name' escapes the project root: $relativePath"
  }
  return $resolved
}

$reversaDir = Resolve-ReversaProjectPath 'config-dir'
$sddDir = Resolve-ReversaProjectPath 'sdd-dir'
$forwardDir = Resolve-ReversaProjectPath 'forward-dir'
$docsDir = Resolve-ReversaProjectPath 'docs-dir'
$bugsDir = Resolve-ReversaProjectPath 'bugs-dir'
