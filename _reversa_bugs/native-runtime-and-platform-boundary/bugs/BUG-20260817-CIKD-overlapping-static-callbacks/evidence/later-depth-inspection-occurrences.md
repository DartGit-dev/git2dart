# Later Depth Inspection Occurrences

- Tree walking, tree-builder filtering, and tag iteration store operation-specific callbacks or results in process-global variables.
- Status iteration and repository fetch-head and merge-head iteration also use process-global collections.

These occurrences extend the cross-operation state bug BUG-20260817-CIKD.
