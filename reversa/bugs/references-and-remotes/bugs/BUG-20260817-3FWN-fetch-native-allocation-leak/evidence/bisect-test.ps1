$source = Get-Content -Raw -LiteralPath 'lib/src/bindings/remote.dart'
$fetchStart = $source.IndexOf('void fetch(')
$fetchEnd = $source.IndexOf('/// Perform a push', $fetchStart)

if ($fetchStart -lt 0 -or $fetchEnd -lt 0) {
    exit 125
}

$fetchSource = $source.Substring($fetchStart, $fetchEnd - $fetchStart)
$hasUnmanagedFetchStorage =
    $fetchSource.Contains('calloc<git_strarray>()') -or
    $fetchSource.Contains('calloc<Pointer<Char>>') -or
    $fetchSource.Contains('calloc<git_fetch_options>()')

if ($hasUnmanagedFetchStorage) {
    exit 1
}

exit 0
