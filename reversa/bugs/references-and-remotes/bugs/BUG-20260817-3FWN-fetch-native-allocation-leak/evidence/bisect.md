# Regression Bisect

- Bad boundary: `9683aa78b8eba77da50965d3a635005b6030d431`
- Good boundary: `0f78771da90054dedf0f54d28d4e154ea3eb7b2d`
- Automated probe: `evidence/bisect-test.ps1`
- Tested revisions: `7`
- First bad commit: `02c6784aaf6157c434e62dd99c4248f80d84ee80`
- Result: deterministic, exit code `0` from `git bisect run`

The first bad commit changed the three temporary `fetch` structures from arena
allocation to global `calloc` without adding any release. The temporary bisect
worktree was reset to `9683aa7` and removed after the run.
