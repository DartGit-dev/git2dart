# Regression Bisect

- Bad boundary: `9683aa78b8eba77da50965d3a635005b6030d431`
- Good boundary: `4dcd65b348f9f62d0080299806305fe7c0a4dd9e`
- Automated probe: `evidence/bisect-test.ps1`
- Tested revisions: `7`
- First bad commit: `37c3c41d3073207ccd2cf362acf39b05e719a5ae`
- Result: deterministic, exit code `0` from `git bisect run`

The first bad commit changed both registered ownership paths: the credential
attempt payload and the SSH-key credential builder. The temporary bisect
worktree was reset to `9683aa7` and removed after the run.
