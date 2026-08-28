# Specification verdict

## Decision

The user authorized an evidence-based default verdict of `spec-correta` in the
automatic remediation campaign.

## Rationale

BR-NP-03, FR-NP-04, FL-NP-05, and ADR-004 require negative native statuses to
be translated immediately through the project error contract. The previous
wrappers discarded forty such statuses, making native failures look like
success. The correction restores the specified behavior.

## Remaining closure condition

The bug uses package closure. It remains active until the corrected package is
prepared, published, and its release destination is verified.
