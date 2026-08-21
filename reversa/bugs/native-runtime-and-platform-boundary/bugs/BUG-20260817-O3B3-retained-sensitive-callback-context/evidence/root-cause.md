# Restricted Root Cause

State: `confirmed`.

Remote callback cleanup is not guaranteed for every exit. A controlled local
failure reproduced retained callback state in three of three isolated runs.
The detailed causal path and repair surface remain restricted to this bug
folder. The correction must guarantee cleanup while leaving the separately
registered callback-concurrency defect out of scope.
