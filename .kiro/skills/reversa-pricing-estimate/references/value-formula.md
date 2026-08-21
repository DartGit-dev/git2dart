# Value Scenario Formula (value-formula.md)

**Versao da formula:** 2.0

Documents the deterministic calculation that the `reversa-pricing-estimate` agent applies to the Value scenario. Formula v2 replaces the fixed multiple of 6 to 12 months with percentage capture of the declared annual economic value.

## Source and criterion

Value-based pricing uses the perceived or economic value for the customer as a price basis, not just internal costs or competitors' prices.

Referencias:

- Hinterhuber, A. (2008), *Customer value-based pricing strategies: why companies resist*, Journal of Business Strategy, 29(4), DOI 10.1108/02756660810887079
- Nagle, Hogan e Zale, *The Strategy and Tactics of Pricing*, 5a ed., Routledge, 2016, especialmente Economic Value to the Customer

The 10% to 30% range is a Reversa business heuristic for B2B/freelance/agency. It should be described as capturing part of the annual value, not as a universal academic law.

## Passo 1: validacao de input

```
if monthly_return_declared == 0 AND cost_of_not_doing == 0:
  available = false
  explanation_pt_br = "The Value scenario cannot be calculated because the client did not declare a measurable return."
```

`users_impacted` and business context. It appears in estimate.md, but does not enter the numerical calculation v2.

## Step 2: Annual economic value

```
annual_value =
  max(monthly_return_declared * 12, cost_of_not_doing)
```

The customer can declare:

- retorno mensal recorrente
- annual cost of not doing it
- ambos

When both exist, the formula uses the highest defensible economic value.

## Step 3: Value capture

```
value_capture_min = 0.10
value_capture_recommended = 0.20
value_capture_max = 0.30

preco_minimo = round_currency(annual_value * value_capture_min)
preco_recomendado = round_currency(annual_value * value_capture_recommended)
preco_maximo = round_currency(annual_value * value_capture_max)
```

## Passo 4: payback explicativo

If `monthly_return_declared > 0`, calculate payback as a secondary explanation:

```
payback_months_min = preco_minimo / monthly_return_declared
payback_months_max = preco_maximo / monthly_return_declared
```

If `monthly_return_declared == 0`, write `payback_months_min = null` and `payback_months_max = null`.

Payback does not define price. It only helps the user to explain the proposal.

## Exemplos

### Example 1: clear monthly return

```
monthly_return_declared = 2000 BRL
cost_of_not_doing = 5000 BRL

annual_value = max(2000 * 12, 5000) = 24000
preco_minimo = 24000 * 0.10 = 2400
preco_recomendado = 24000 * 0.20 = 4800
preco_maximo = 24000 * 0.30 = 7200
payback_months_min = 1.2
payback_months_max = 3.6
```

### Example 2: annual loss prevention

```
monthly_return_declared = 0
cost_of_not_doing = 60000 BRL

annual_value = max(0, 60000) = 60000
preco_minimo = 6000
preco_recomendado = 12000
preco_maximo = 18000
payback_months_min = null
payback_months_max = null
```

### Example 3: no measurable data

```
monthly_return_declared = 0
cost_of_not_doing = 0

available = false
```

## Conversion to billing currency

Identical to Effort. When `profile.billing_currency` is filled:

```
preco_minimo_billing = round_currency(preco_minimo / exchange_rate_to_local)
preco_recomendado_billing = round_currency(preco_recomendado / exchange_rate_to_local)
preco_maximo_billing = round_currency(preco_maximo / exchange_rate_to_local)
```

## Limites e premissas

1. The return declared by the customer is not validated by the agent
2. A faixa de captura 10% a 30% e heuristica documentada
3. `users_impacted` is not part of the v2 numerical calculation
4. Extreme values are not truncated
5. The explanation may mention months of payback, but should not say that the price is "6 to 12 months"
