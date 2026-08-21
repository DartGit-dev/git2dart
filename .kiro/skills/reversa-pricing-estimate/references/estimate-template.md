# `estimate.md` Template

This is the Markdown template that the `reversa-pricing-estimate` agent uses to generate `reversa/sdd/_pricing/<feature>/estimate.md`. Replace all `<placeholders>` with actual values. Keep the structure fixed.

```markdown
# Price Estimate

**Feature:** `<feature_dir_relativa>`
**Generated on:** <created_at_local_legivel>
**Calculation version:** Effort v<effort_formula_version>, Value v<value_formula_version>, Market v<market_table_version>

**Consumed prerequisites:**
- Profile: `<output_folder>/_pricing/profile.json`
- Size: `<output_folder>/_pricing/<feature>/size.json` (class `<complexity_class>`, auxiliary score `<size_score>`)

## Overview

| Scenario | Range | Comment |
|---|---|---|
| **Effort** | <esforco_str> | <horas_min> to <horas_max>h, cost + tax + markup |
| **Value** | <valor_str> | 10% to 30% of declared annual value |
| **Market Range** | <mercado_str> | hourly rate sourced by country and seniority |

## Effort Scenario

**What it is:** price calculated based on probable hours, hourly rate, approximate tax reserve and project markup. And the floor is defensible so as not to subsidize the customer.

**When to use:** always as a sanity check. Charging below the Effort means assuming a loss or reducing the project's profit too much.

| Item | Value |
|---|---|
| Complexity class | <complexity_class> |
| Seniority | <seniority> |
| Seniority factor | <seniority_factor> |
| Estimated hours | <horas_min> to <horas_max> h |
| Midpoint | <horas_estimadas> h |
| Hourly rate | <hourly_rate> <currency>/h |
| Direct cost | <custo_direto_min> to <custo_direto_max> <currency> |
| Approximate tax reserve | <imposto_aproximado_min> to <imposto_aproximado_max> <currency> |
| Project markup (<margin_percent>%) | <markup_aplicado_min> to <markup_aplicado_max> <currency> |
| **Effort range** | **<preco_minimo> to <preco_maximo> <currency>** |
| Midpoint | <preco_total> <currency> |

<aviso_vat_se_aplicavel>
<bloco_billing_currency_se_aplicavel>

## Value Scenario

**What it is:** price based on part of the annual economic value that the feature generates or protects for the customer. Reversa uses capture of 10% to 30% of the declared annual value.

**When to use:** when the customer is able to declare return, savings or cost of not doing it.

<if value.available>

| Item | Value |
|---|---|
| Declared monthly return | <monthly_return_declared> <currency> |
| Users impacted | <users_impacted> |
| Cost of not doing it | <cost_of_not_doing> <currency> |
| Annual value used | <annual_value> <currency> |
| Applied capture | 10% to 30% |
| Recommended price | <preco_recomendado> <currency> |
| **Value range** | **<preco_minimo> to <preco_maximo> <currency>** |
| Approximate payback | <payback_str> |

<bloco_billing_currency_se_aplicavel>

<if NOT value.available>

> **Value Scenario unavailable:** <razao_unavailable>

</if>

## Market Range Scenario

**What it is:** range derived from hourly benchmark by country and seniority, multiplied by the same range of hours from the Effort scenario.

**When to use:** as an external reference. v2 does not multiply by customer profile because there is no reliable public dataset for this.

<if market.available>

| Item | Value |
|---|---|
| Country / Seniority | <country_name> / <seniority> |
| Pricing model / Client profile | <pricing_model> / <client_profile> |
| Complexity | <complexity_class> |
| Market hourly rate | <market_hourly_min> to <market_hourly_max> <currency>/h |
| Source type | <source_kind> |
| Reference year | <source_year> |
| Sources | <sources> |
| **Market range** | **<preco_minimo_mercado> to <preco_maximo_mercado> <currency>** |

<if fallback applied>

> Fallback applied: <razao>

</if>

<bloco_billing_currency_se_aplicavel>

<if NOT market.available>

> **Market Scenario unavailable:** <razao_unavailable>

</if>

## How to choose between the three

<orientacao_pt_br_baseada_nos_cenarios>

General heuristic:

1. Customer without clear return: use Effort as a floor and Market as an external reference
2. Customer with high and clear return: prefer Value, with Effort only as a minimum floor
3. Effort above the Market: review the client’s profile, size or suitability
4. Market above Effort: there is room to increase markup or improve proposal

## Disclaimer

The numbers in this estimate are approximations for budget guidance, not a guarantee of closing the sale. The tax factor is an approximate reserve, not an exact legal rate. Real tax validation and responsibility of the user's accountant. The market range is static and based on sources documented in `market-benchmarks.md`. The return declared by the client in the Value scenario is raw input, not validated. It is recommended to add `reversa/sdd/_pricing/<feature>/estimate.{md,json}` to `.gitignore` before committing.
```

## Billing currency

When `profile.billing_currency` is filled, each scenario gets an extra line:

```markdown
| In <billing_currency> | <valor_billing> <billing_currency> (exchange rate: 1 <billing_currency> = <exchange_rate_to_local> <currency>) |
```

## Short comments

| Scenario | Short comment |
|---|---|
| Effort | `<horas_min> to <horas_max>h, cost + tax + markup` |
| Value | `10% to 30% of declared annual value` or `Unavailable` |
| Market | `hourly rate sourced by country and seniority` or `Unavailable` |
