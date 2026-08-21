# Root Cause

State: `confirmed`.

Credential callback memory has no single lifecycle owner. Callback setup uses
the global allocator for its attempt payload, but only the native options
structure retains the pointer and `RemoteCallbacks.reset()` clears Dart fields
without freeing it. The SSH-key credential builder independently replaced an
arena-owned output slot and four arena-owned strings with unmanaged allocations.

The current source, the three-run reproduction, and the introducing diff at
`37c3c41d3073207ccd2cf362acf39b05e719a5ae` close both ownership paths. The
parent commit `4dcd65b348f9f62d0080299806305fe7c0a4dd9e` is the last known version before
those allocation changes.
