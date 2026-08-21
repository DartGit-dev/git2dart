# Effort Scenario Formula (effort-formula.md)

**Versao da formula:** 2.0

Documents the deterministic calculation that the `reversa-pricing-estimate` agent applies to the Effort scenario. The v2 formula removes the old linear conversion from score to hours and uses ranges of hours per T-shirt size, with a seniority factor inspired by the COCOMO II staff capacity multipliers.

## Source and criterion

COCOMO II is a parametric effort estimation model that uses size, product attributes, platform, personnel and project. For the UX of Reversa, using the full model would be too complex. v2 only uses the defensible idea of ​​staffing capacity multipliers while maintaining simple hour ranges by class.

Main reference:

- Barry Boehm et al., *Software Cost Estimation with COCOMO II*, Prentice Hall, 2000
- Carnegie Mellon SEI, visao geral de software cost estimation e COCOMO II: https://insights.sei.cmu.edu/blog/software-cost-estimation-explained/

## Step 1: base hour range for senior

```
hours_by_complexity_class_senior:
  S:   4 a 12 horas
  M:   12 a 32 horas
  L:   32 a 80 horas
  XL:  80 a 160 horas
  XXL: 160 to 320 hours, with mandatory recommendation to break the scope
```

These ranges are Reversa heuristics, based on T-shirt sizing. They are more honest than a linear constant because software estimates have real uncertainty.

## Step 2: Seniority factor

```
seniority_factor:
  junior:      1.34
  mid:         1.15
  senior:      1.00
  staff_lead:  0.88
  principal:   0.76
```

Aliases accepted for compatibility:

```
pleno -> mid
especialista -> staff_lead
staff -> staff_lead
lead -> staff_lead
```

## Passo 3: horas estimadas

```
horas_min = round(hours_min[complexity_class] * seniority_factor)
horas_max = round(hours_max[complexity_class] * seniority_factor)
horas_estimadas = round((horas_min + horas_max) / 2)
```

The `horas_estimadas` field is the midpoint for compatibility and summary. The range `horas_min` to `horas_max` should be displayed in estimate.md.

## Step 4: direct cost

```
custo_direto_min = horas_min * profile.hourly_rate
custo_direto_max = horas_max * profile.hourly_rate
custo_direto = horas_estimadas * profile.hourly_rate
```

## Passo 5: imposto aproximado

```
imposto_aproximado_min = custo_direto_min * profile.tax_factor
imposto_aproximado_max = custo_direto_max * profile.tax_factor
imposto_aproximado = custo_direto * profile.tax_factor
```

When `profile.tax_regime == "outro"` or `tax_factor = 0`, tax is not computed and estimate.md should show explicit warning.

If the profile indicates that the factor includes VAT, VAT or tax highlighted on the invoice, estimate.md must warn that this amount can be passed on to the customer and does not necessarily reduce margin.

## Step 6: project markup

The historical field `margin_percent` must be treated as a **project markup on direct cost**, not as a net accounting margin.

```
markup_min = custo_direto_min * (profile.margin_percent / 100)
markup_max = custo_direto_max * (profile.margin_percent / 100)
markup_aplicado = custo_direto * (profile.margin_percent / 100)
```

## Passo 7: preco total

```
preco_minimo = round_currency(custo_direto_min + imposto_aproximado_min + markup_min)
preco_maximo = round_currency(custo_direto_max + imposto_aproximado_max + markup_max)
preco_total = round_currency(custo_direto + imposto_aproximado + markup_aplicado)
```

`preco_total` is the midpoint of the range and exists for compatibility. estimate.md should highlight `preco_minimo` to `preco_maximo`.

## Example

```
profile:
  country = BR, currency = BRL, seniority = senior
  hourly_rate = 100.00, margin_percent = 35, tax_factor = 0.15

size:
  complexity_class = L

hours_by_complexity_class_senior[L] = 32 a 80
seniority_factor[senior] = 1.00
horas_min = 32
horas_max = 80
horas_estimadas = 56

custo_direto_min = 3200.00
custo_direto_max = 8000.00
imposto_min = 480.00
imposto_max = 1200.00
markup_min = 1120.00
markup_max = 2800.00

preco_minimo = 4800.00 BRL
preco_maximo = 12000.00 BRL
preco_total = 8400.00 BRL
```

## Conversion to billing currency

When `profile.billing_currency` and `profile.exchange_rate_to_local` are filled:

```
valor_billing = round_currency(valor_local / exchange_rate_to_local)
```

estimate.md should print the rate used:

```
1 <billing_currency> = <exchange_rate_to_local> <currency>
```

## Limites

1. The formula does not mix team seniority levels
2. XXL remains calculable, but should generate a strong recommendation to break scope
3. The hour range is a heuristic, not a delivery promise
4. `size_score` is not part of the hour calculation
