$callbacksSource = Get-Content -Raw -LiteralPath 'lib/src/bindings/remote_callbacks.dart'
$credentialsSource = Get-Content -Raw -LiteralPath 'lib/src/bindings/credentials.dart'

$payloadIsUnmanaged = $callbacksSource.Contains('calloc<Int8>()')
$sshKeyStart = $credentialsSource.IndexOf('Pointer<git_credential> sshKey(')
$sshKeyEnd = $credentialsSource.IndexOf(
    'Pointer<git_credential> sshKeyFromAgent',
    $sshKeyStart
)

if ($sshKeyStart -lt 0 -or $sshKeyEnd -lt 0) {
    exit 125
}

$sshKeySource = $credentialsSource.Substring(
    $sshKeyStart,
    $sshKeyEnd - $sshKeyStart
)
$sshKeyIsUnmanaged = $sshKeySource.Contains('toCharAlloc(')

if ($payloadIsUnmanaged -or $sshKeyIsUnmanaged) {
    exit 1
}

exit 0
