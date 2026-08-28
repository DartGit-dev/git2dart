# Restricted Reproduction Capsule

- Base commit: `9683aa78b8eba77da50965d3a635005b6030d431`
- Branch: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0
- Command: `flutter test -j 1 <restricted reproduction test path>`
- Exit code: `0`
- Rate: `3/3` isolated failures reproduced retained callback state
- Classification: `deterministic`

The probe used only synthetic placeholder values and a loopback endpoint. It
confirmed that a failed remote operation can exit without clearing callback
state. Exact details remain restricted to this bug folder. The probe performs
manual cleanup in `finally` so the test process does not retain its synthetic
state after the assertion.
