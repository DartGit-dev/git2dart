# References and Remotes — Technical Design

> 🟢 **CONFIRMED** — The unit joins mutable Git names to libgit2 transports through typed options and synchronous callback bridges.

## Components

```mermaid
flowchart LR
    Repo --> Reference
    Reference --> Branch
    Reference --> Reflog
    Remote --> Refspec
    Remote --> Callback["Callbacks"]
    Callback --> Credentials
    Callback --> Certificate
    Callback --> Progress["Progress / Update Status"]
    Reference --> Bindings
    Remote --> Bindings
    Bindings --> Libgit2
    Libgit2 <--> GitRemote["HTTPS / SSH Git remote"]
```

## Interface Summary

| Component | Operations | Design notes | Confidence |
| --- | --- | --- | --- |
| Reference | create/createMatching/lookup/list/resolve/peel/setTarget/rename/delete | Runtime dispatch distinguishes OID/direct and String/symbolic. | 🟢 CONFIRMED |
| Branch | create/list/lookup/move/delete/upstream | Wraps refs plus HEAD/checked-out/tracking configuration. | 🟢 CONFIRMED |
| Reflog | read/write/append/drop/rename | Ordered native log entries with signatures and OID transitions. | 🟢 CONFIRMED |
| Refspec | parse/match/transform/rtransform | Native pattern mapping with fetch/push direction and force flag. | 🟢 CONFIRMED |
| Remote | create/config/list/ls/connect/fetch/download/push/prune | Repository config plus native transport operations. | 🟢 CONFIRMED |
| Callbacks | credentials/certificate/progress/sideband/update | Static/native bridge projects borrowed values to Dart closures. | 🟢 CONFIRMED |
| Credentials | user/password, keypair, agent, memory keypair | Caller-owned secrets selected by native allowed-type request. | 🟢 CONFIRMED |
| Certificate | X.509/hostkey projections | Borrowed callback-scoped data; caller bool is final decision. | 🟢 CONFIRMED |

## Reference Compare-and-Set

```mermaid
flowchart TD
    A["Desired + expected targets"] --> B{"Both Oid?"}
    B -- Yes --> C["Native direct create_matching"]
    B -- No --> D{"Both String?"}
    D -- Yes --> E["Native symbolic create_matching"]
    D -- No --> F["ArgumentError"]
    C --> G{"Expected matches?"}
    E --> G
    G -- No --> H["Modification error"]
    G -- Yes --> I["Owned Reference"]
```

## Remote Fetch Sequence

```mermaid
sequenceDiagram
    participant C as Caller
    participant R as Remote
    participant B as Binding/callback bridge
    participant L as libgit2
    participant N as Git remote
    C->>R: refspecs, prune, proxy, callbacks
    R->>B: native fetch options
    B->>L: git_remote_fetch/download
    L->>N: connect/negotiate
    L->>B: credential request
    B-->>L: typed credential
    L->>B: certificate and native validity
    B-->>L: trust decision
    N-->>L: objects and refs
    L->>B: progress/update callbacks
    L-->>R: stats/result
    R-->>C: TransferProgress or translated error
```

## Ownership and Trust

- 🟢 **CONFIRMED** — Reference/branch/reflog/refspec/remote wrappers own native handles when returned as owned objects.
- 🟢 **CONFIRMED** — Advertisements, progress, and certificate values may be borrowed and must be copied or consumed synchronously.
- 🟢 **CONFIRMED** — No callback means native/default certificate validation remains active.
- 🟢 **CONFIRMED** — Returning true from `certificateCheck` may override native invalidity and therefore transfers trust responsibility to the caller.
- 🟢 **CONFIRMED** — The library does not persist credentials.

## Error and State Model

- 🟢 **CONFIRMED** — Reference type mismatch fails locally; stale compare-and-set, missing name, invalid refspec, auth/trust/network/ref rejection fail explicitly.
- 🟢 **CONFIRMED** — `ls` connects in fetch direction and disconnects after copying advertisements.
- 🟢 **CONFIRMED** — Fetch returns transfer stats; push reports per-reference status through callbacks and final error state.
- 🔴 **GAP** — Static callback storage isolation under overlapping remote operations is not proven.

## Observability and Gaps

- 🟢 **CONFIRMED** — Sideband, transfer, update-tip, push-transfer, and push-ref-status callbacks are the main runtime observability surface.
- 🔴 **GAP** — Live HTTPS/SSH behavior for current binaries/platforms is not proven by default tests.
- 🔴 **GAP** — Secret-redaction behavior belongs to embedding application logging and is not guaranteed here.
- 🔴 **GAP** — Callback exception/overlap lifetime behavior needs dynamic characterization.

