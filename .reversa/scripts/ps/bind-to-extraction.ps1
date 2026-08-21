# bind-to-extraction.ps1
# Helper that reads reversa/sdd/ and returns a JSON with the canonical sources that skills forward should consult.
#
# Uso:
#   bind-to-extraction.ps1 [-Json] [-For <command>]
#
# -For requirements   architecture, domain, inventory
# -For plan           architecture, c4-context, state-machines, dependencies, code-analysis
# -For to-do          architecture, code-analysis
# -For audit          architecture, domain
# -For coding         architecture, domain, code-analysis
# without -For all files from reversa/sdd
#
# Exit codes: 0 ok, 1 reversa/sdd missing, 2 invalid usage.

[CmdletBinding()]
param(
  [switch]$Json,
  [string]$For = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'resolve-paths.ps1')

if (-not (Test-Path -LiteralPath $sddDir -PathType Container)) {
Write-Error "$sddDir does not exist. Run the reversa pipeline first."
  exit 1
}

$wanted = switch ($For) {
  'requirements' { @('architecture.md','domain.md','inventory.md') }
  'plan'         { @('architecture.md','c4-context.md','state-machines.md','dependencies.md','code-analysis.md') }
  'to-do'        { @('architecture.md','code-analysis.md') }
  'todo'         { @('architecture.md','code-analysis.md') }
  'audit'        { @('architecture.md','domain.md') }
  'coding'       { @('architecture.md','domain.md','code-analysis.md') }
  default        { @('architecture.md','c4-context.md','code-analysis.md','confidence-report.md','dependencies.md','domain.md','inventory.md','questions.md','state-machines.md') }
}

$present = New-Object System.Collections.Generic.List[string]
$absent  = New-Object System.Collections.Generic.List[string]

foreach ($f in $wanted) {
  $full = Join-Path $sddDir $f
  if (Test-Path -LiteralPath $full) {
    $present.Add($full) | Out-Null
  } else {
    $absent.Add($f) | Out-Null
  }
}

$result = [ordered]@{
  'sdd-dir' = $sddDir
  'target'  = $For
  'present' = @($present)
  'absent'  = @($absent)
}

if ($Json) {
  $result | ConvertTo-Json -Compress -Depth 4 | Write-Output
} else {
  Write-Output 'presentes:'
  foreach ($p in $present) { Write-Output "  $p" }
  Write-Output 'ausentes:'
  foreach ($a in $absent) { Write-Output "  $a" }
}

exit 0
