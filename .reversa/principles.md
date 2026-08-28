# Project Principles

> Project: `git2dart`
> Last updated: `2026-08-26`
> Maintained by: `/reversa-principles`

## Evidence basis

This initial baseline is derived from the confirmed retrospective architecture
decisions in `reversa/sdd/adrs/001-separate-native-binaries-and-generated-declarations.md`
through `005-require-explicit-mobile-platform-initialization.md`,
`007-isolate-network-dependent-tests.md`, and
`reversa/sdd/architecture.md`. It records durable project constraints rather
than feature-specific implementation choices.

## Active principles

### I. Preserve the Safe Public Dart Facade

**Description.** Public Dart APIs remain idiomatic and null-safe, and hide raw pointers, generated declarations, and native-runtime mechanics. Internal dependency or binding changes must preserve public signatures and intended consumer behavior unless an explicitly approved public API change says otherwise.

**Application example.** When a companion package changes a generated FFI declaration, adapt the binding layer while keeping an existing public getter's Dart call form unchanged.

**Template impact.**
- `requirements-template.md`: state the affected consumer-facing contract and any compatibility guard separately from internal mechanics.
- `roadmap-template.md`: identify the wrapper and binding layers affected by the delta.
- `actions-template.md`: include public-API compatibility verification when a task changes an internal native boundary.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

### II. Keep Generated Artifacts in the Companion Boundary

**Description.** `git2dart_binaries` supplies native libraries and generated FFI declarations. This repository owns hand-written binding adapters and high-level wrappers; it neither vendors libgit2 nor regenerates companion declarations as part of normal feature work.

**Application example.** A dependency migration updates the compatible hosted companion-package range and adapts local code to its delivered declarations instead of copying generated files into this repository.

**Template impact.**
- `requirements-template.md`: distinguish a dependency-contract outcome from generated-code implementation work.
- `roadmap-template.md`: record the companion-package version and declaration boundary as an explicit technical decision.
- `actions-template.md`: prevent generated-declaration regeneration or vendoring unless an approved exception is recorded.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

### III. Preserve Native ABI and Memory Ownership Safety

**Description.** Raw native calls, pointer conversion, allocation, and ownership remain confined to binding adapters. Native-width values must retain their declared width; call-scoped allocations use arenas, and owned objects have deterministic cleanup with finalizers only as a safety net.

**Application example.** A getter whose native declaration returns `size_t` reads the complete native-width result before converting it to a Dart integer and releases its temporary output allocation on every path.

**Template impact.**
- `requirements-template.md`: express observable ABI, ownership, and truncation outcomes without prescribing source-level pointer mechanics.
- `roadmap-template.md`: document binding-level allocation, ownership, and native-width decisions with their evidence.
- `actions-template.md`: pair each native-boundary change with a focused memory/ABI validation task.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

### IV. Translate Native Failures at One Boundary

**Description.** Negative libgit2 results are translated immediately at the shared binding error boundary so native diagnostics are preserved and consumer failure behavior remains consistent. Pre-native argument and range validation uses specific Dart errors appropriate to the invalid input.

**Application example.** A native call that returns a negative result routes through the shared error helper instead of reconstructing an exception independently in each binding.

**Template impact.**
- `requirements-template.md`: define the externally observable failure contract and its negative scenarios.
- `roadmap-template.md`: locate error-translation changes at the shared boundary and reject duplicate per-call handling.
- `actions-template.md`: require both native-error-present and native-error-absent validation where the contract changes.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

### V. Keep Supported Platform Initialization Explicit

**Description.** Mobile platform preparation is an explicit consumer-visible startup contract. Android certificate setup and iOS native-symbol initialization remain available and documented; an internal change must not silently remove or defer those supported paths.

**Application example.** A native dependency migration verifies that an Android or iOS application can still call the documented initialization path before accessing Git APIs.

**Template impact.**
- `requirements-template.md`: name any affected supported-platform behavior and acceptance outcome.
- `roadmap-template.md`: include platform startup paths in the architectural delta and risk assessment.
- `actions-template.md`: add platform-target validation tasks when native runtime packaging or initialization changes.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

### VI. Make Validation Evidence Match Its Scope

**Description.** Completion claims must name the validation boundary they prove. Default offline tests do not prove live network interoperability, and local success on one platform does not prove the supported platform matrix; unresolved runtime or concurrency limits remain explicit gaps.

**Application example.** A migration reports local Windows analysis separately from CI evidence across desktop and mobile targets, and does not claim that skipped network tests prove remote interoperability.

**Template impact.**
- `requirements-template.md`: record validation limits as explicit gaps or scope boundaries with confidence markers.
- `roadmap-template.md`: distinguish local checks, CI matrix evidence, and unproven external behavior in risks and done criteria.
- `actions-template.md`: make verification tasks name their target, command, and proof boundary.

**Created.** `2026-08-26`
**Last reviewed.** `2026-08-26`

---

## Retired principles

None.

## Change history

| Date | Operation | Principle | Summary |
|------|-----------|-----------|---------|
| 2026-08-26 | create | I-VI | Initial evidence-based project principles baseline. |
