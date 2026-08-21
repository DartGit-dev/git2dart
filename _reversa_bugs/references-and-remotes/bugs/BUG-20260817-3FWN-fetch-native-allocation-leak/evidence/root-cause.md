# Root Cause

State: `confirmed`.

`fetch` runs inside `using((arena) { ... })`, but commit
`02c6784aaf6157c434e62dd99c4248f80d84ee80` changed its three temporary native
structures from arena allocation to global `calloc` without adding matching
releases. Both normal completion and error unwind therefore leak them.

The parent commit `0f78771da90054dedf0f54d28d4e154ea3eb7b2d` is the last known good version
for this ownership pattern. The adjacent `push` implementation confirms the
intended arena-owned design.
