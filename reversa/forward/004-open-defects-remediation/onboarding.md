# Onboarding: Open Defects Remediation

1. Start from the current shared working tree; do not revert unrelated edits.
2. Read this feature's `roadmap.md` and the assigned bug record before editing.
3. Mark only the owned record `active` after reproducing or confirming the
   static path; preserve its evidence state.
4. Implement one batch at a time and add focused positive and negative tests.
5. Run formatter, targeted tests, `flutter analyze`, and the full test suite.
6. Record the exact validation scope: local Windows, CI platform matrix, and
   any live remote check are separate evidence categories.
7. Attach root-cause, tests, and change-set evidence to each record.
8. Do not mark a record fixed/resolved until package policy is met: test and
   specification verdict, merge, publication, and required backports.
