# Gate 1 Red Test Evidence

## Approved Test Run

```powershell
flutter test -j 1 test\repository_test.dart --plain-name "status performance"
```

- Exit code: 1
- Result: 0 passed, 2 failed
- Failure for both tests: `git_error_t.GIT_ERROR_INVALID: invalid version 0 on git_diff_perfdata`

## Finding

The approved tests reached `git_status_list_get_perfdata`, but libgit2 rejected
the zero-initialized `git_diff_perfdata.version` before the assertions could
observe the returned value. The safe analog in the diff binding assigns
`GIT_DIFF_PERFDATA_VERSION` before its native call.

This is an additional defect in the same private helper. It does not invalidate
the source-level dangling-pointer proof, but it masks that defect at runtime.
The reproduction test therefore needs a type-contract assertion that does not
invoke libgit2. The runtime regression test remains valid and will cover the
version initialization plus managed counter copy after the correction.

## Revised Reproduction Test Run

The approved type-contract revision was applied and the same focused command
was run again.

- Exit code: 1
- Result: 0 passed, 2 failed
- Reproduction failure: expected a function that does not return
  `Pointer<git_diff_perfdata>`, but the actual closure returns that exact type
- Regression failure: `git_error_t.GIT_ERROR_INVALID: invalid version 0 on git_diff_perfdata`

The two failures now independently prove both defects in the helper.

## Proof Boundary

The type-contract test proves the unsafe raw pointer boundary without executing
freed memory. The runtime test proves the invalid native structure version. No
crash, sanitizer finding, or dereference of freed storage is claimed. Gate 1 is
complete.
