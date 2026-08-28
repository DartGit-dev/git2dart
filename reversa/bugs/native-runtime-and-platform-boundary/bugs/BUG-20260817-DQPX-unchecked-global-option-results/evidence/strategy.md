# Repair Strategy

Selected on 2026-08-23: direct correction.

The confirmed cause is uniform across one facade: 40 global-option wrappers
discard an integer native status. The smallest coherent repair is to reuse the
existing `checkErrorAndThrow` convention immediately after every such call.

A multi-agent debate was not selected because the causal path, affected scope,
and correction pattern are already demonstrated by runtime and static evidence.
