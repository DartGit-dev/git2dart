# Formula de dimensionamento (sizing-formula.md)

**Versao da formula:** 2.0
**Versao do schema do size.json:** 1.1

Documents the deterministic calculation that the `reversa-pricing-size` agent applies to transform the forward cycle artifacts into a complexity class (`S/M/L/XL/XXL`). The v2 formula abandons the linear sum of arbitrary weights and starts using task-based T-shirt sizing, with separate risk adjustment.

## Source and criterion

Reversa v1 needs a measurement that is understandable for lay users, multi-engine and derived from the files already produced in `reversa/sdd/forward/<feature>/`.

Function Points (IFPUG, ISO/IEC 20926) and COSMIC (ISO/IEC 19761) are formal functional measurement standards, but require specialized classification. For the UX of Reversa, the best base and approximate agile estimation, inspired by Story Points and T-shirt sizing. Mike Cohn, in *Agile Estimating and Planning* (Addison-Wesley, 2005), describes relative estimates and approximate sizes as agile planning practices.

This formula does not state that the tracks are a universal standard. It documents a simple Reversa heuristic, based on T-shirt sizing, and keeps the risk factors separate to avoid false precision.

## Entradas

As entradas continuam vindo de `metrics`:

- `tasks.total`
- `doubts.high`, `doubts.medium`, `doubts.low`, `doubts.total`
- `plan_depth`
- `principles_touched`
- `requirements.total`, used only as a consistency alert, not as a primary driver

## Passo 1: classe base por quantidade de tasks

`tasks.total` is the best size proxy because the forward cycle has already split the feature into work units.

```
if tasks.total <= 0:       base_complexity_class = "S"
elif tasks.total <= 3:     base_complexity_class = "S"
elif tasks.total <= 7:     base_complexity_class = "M"
elif tasks.total <= 15:    base_complexity_class = "L"
elif tasks.total <= 30:    base_complexity_class = "XL"
else:                      base_complexity_class = "XXL"
```

## Passo 2: pontos de risco

Risk is not size. It adjusts the class upward when the feature has uncertainty, depth, or cross-cutting impact.

```
unclassified_doubts =
  max(0, doubts.total - doubts.high - doubts.medium - doubts.low)

risk_points =
  doubts.high * 2 +
  doubts.medium * 1 +
  unclassified_doubts * 1 +
  max(0, plan_depth - 3) +
  floor(len(principles_touched) / 3)
```

`doubts.low` does not increase risk in v2. A low-severity doubt is expected refinement noise.

## Passo 3: ajuste de risco

```
if risk_points <= 2:       risk_adjustment_classes = 0
elif risk_points <= 5:     risk_adjustment_classes = 1
else:                      risk_adjustment_classes = 2
```

## Passo 4: classe final

Classes sao ordenadas assim:

```
S=0, M=1, L=2, XL=3, XXL=4
```

```
complexity_class =
  class_from_index(min(4, index(base_complexity_class) + risk_adjustment_classes))
```

## Passo 5: size_score auxiliar

`size_score` is only for compatibility and quick reading. He should no longer drive hours straight.

```
size_score_by_class:
  S:   15
  M:   35
  L:   60
  XL:  80
  XXL: 95
```

## Campos recomendados no size.json

The agent must record these fields in addition to the old fields:

```
sizing_method = "task_tshirt_with_risk_adjustment"
base_complexity_class = <class before risk>
risk_points = <inteiro>
risk_adjustment_classes = <0, 1 ou 2>
size_score = <midpoint auxiliar da classe final>
```

## Exemplos de calculo

### Example 1: small feature (S)

```
tasks.total = 3
doubts.high = 0
doubts.medium = 0
doubts.low = 0
doubts.total = 0
plan_depth = 2
principles_touched = []

base_complexity_class = S
risk_points = 0
risk_adjustment_classes = 0
complexity_class = S
size_score = 15
```

### Example 2: average feature that rises to L due to risk

```
tasks.total = 7
doubts.total = 3 (high=1, medium=2, low=0)
plan_depth = 3
principles_touched = ["non_destructive", "multi_engine", "handoff_pattern"]

base_complexity_class = M
risk_points = 1*2 + 2*1 + 0 + 0 + floor(3/3) = 5
risk_adjustment_classes = 1
complexity_class = L
size_score = 60
```

### Example 3: large feature (XL)

```
tasks.total = 12
doubts.total = 1 (high=0, medium=1, low=0)
plan_depth = 4
principles_touched = 2

base_complexity_class = L
risk_points = 0 + 1 + 0 + 1 + 0 = 2
risk_adjustment_classes = 0
complexity_class = L
size_score = 60
```

### Example 4: giant feature (XXL)

```
tasks.total = 31
doubts.total = 6 (high=2, medium=3, low=1)
plan_depth = 6
principles_touched = 8

base_complexity_class = XXL
risk_points = 2*2 + 3*1 + 0 + 3 + floor(8/3) = 12
risk_adjustment_classes = 2
complexity_class = XXL
size_score = 95
```

## Alertas de consistencia

Requirements are not included in the primary calculation, but can generate a note:

```
if requirements.total >= 12 and tasks.total <= 3:
notes += "Too many requirements for too few tasks. Check if tasks.md is granular enough."
```

## Limites e premissas

1. The formula measures structural size before coding, therefore it does not use LOC
2. Tokens are not counted
3. `size_score` is auxiliary, it should not be converted directly into hours
4. XXL must generate a recommendation to break scope before pricing or coding
5. If a class threshold changes, bump `formula_version`
