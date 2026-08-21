# Market Benchmarks (market-benchmarks.md)

**Versao da tabela:** 2.0
**Benchmark reference date:** 2026-05

Documents the static references that the `reversa-pricing-estimate` agent uses for the Market Range scenario. v2 removes total ranges invented by combination and starts using hourly benchmark by country and seniority, deriving the total from the `effort-formula.md` hour range.

## Disclaimer obrigatorio

The numbers are didactic approximations based on public and commercial sources known as of May 2026. They do not replace up-to-date regional research. Many public sources bring monthly or annual salary, not direct freelance fees. When the line derives a freelance rate from salary, the `source_kind` field must say so explicitly.

## How to calculate the Market scenario

Each line has:

```
country | seniority | currency | min_hourly | max_hourly | source_kind | source_year | sources
```

The total per feature is derived as follows:

```
market_min = horas_min[complexity_class][seniority] * min_hourly
market_max = horas_max[complexity_class][seniority] * max_hourly
```

`pricing_model` only changes the presentation:

- `time_and_materials`: show the hourly rate and estimated total based on hours
- `escopo_fechado`, `sprint`, `valor_fixo_por_entrega`: show the per-feature total derived from hours (legacy schema values)
- `retainer`: mostrar "faixa equivalente por feature dentro de retainer"

`client_profile` does not change the number in v2. Without a dataset per profile, multipliers per customer would be an invention. estimate.md can add qualitative alerts for micro, small businesses or enterprises.

## Tabela v2

| country | seniority | currency | min_hourly | max_hourly | source_kind | source_year | sources |
|---|---|---:|---:|---:|---|---:|---|
| BR | junior | BRL | 40 | 80 | salary_derived_freelance_estimate | 2025-2026 | Portal Salario CAGED, Glassdoor Brasil |
| BR | mid | BRL | 70 | 130 | salary_derived_freelance_estimate | 2025-2026 | Portal Salario CAGED, Glassdoor Brasil |
| BR | senior | BRL | 100 | 200 | salary_derived_freelance_estimate | 2025-2026 | Portal Salario CAGED, Glassdoor Brasil |
| BR | staff_lead | BRL | 160 | 300 | salary_derived_freelance_estimate | 2025-2026 | Portal Salario CAGED, Glassdoor Brasil |
| BR | main | BRL | 220 | 420 | salary_derived_freelance_estimate | 2025-2026 | CAGED Salary Portal, Glassdoor Brazil |
| US | junior | USD | 20 | 40 | freelance_platform_and_public_wage | 2024-2025 | Upwork, O*NET/BLS |
| US | mid | USD | 40 | 70 | freelance_platform_and_public_wage | 2024-2025 | Upwork, O*NET/BLS |
| US | senior | USD | 70 | 150 | freelance_platform_and_public_wage | 2024-2025 | Upwork, O*NET/BLS |
| US | staff_lead | USD | 120 | 200 | freelance_platform_and_public_wage | 2024-2025 | Upwork, O*NET/BLS |
| US | main | USD | 160 | 260 | freelance_platform_and_public_wage | 2024-2025 | Upwork, O*NET/BLS |
| PT | junior | EUR | 25 | 45 | salary_derived_contractor_estimate | 2024-2026 | Landing.Jobs, Hays Portugal |
| PT | mid | EUR | 40 | 70 | salary_derived_contractor_estimate | 2024-2026 | Landing.Jobs, Hays Portugal |
| PT | senior | EUR | 60 | 100 | salary_derived_contractor_estimate | 2024-2026 | Landing.Jobs, Hays Portugal |
| PT | staff_lead | EUR | 90 | 140 | salary_derived_contractor_estimate | 2024-2026 | Landing.Jobs, Hays Portugal |
| PT | main | EUR | 120 | 180 | salary_derived_contractor_estimate | 2024-2026 | Landing.Jobs, Hays Portugal |
| MX | junior | MXN | 200 | 400 | salary_derived_freelance_estimate | 2025 | Glassdoor Mexico, Computrabajo Mexico |
| MX | mid | MXN | 350 | 650 | salary_derived_freelance_estimate | 2025 | Glassdoor Mexico, Computrabajo Mexico |
| MX | senior | MXN | 600 | 1000 | salary_derived_freelance_estimate | 2025 | Glassdoor Mexico, Computrabajo Mexico |
| MX | staff_lead | MXN | 900 | 1500 | salary_derived_freelance_estimate | 2025 | Glassdoor Mexico, Computrabajo Mexico |
| MX | main | MXN | 1200 | 2000 | salary_derived_freelance_estimate | 2025 | Glassdoor Mexico, Computrabajo Mexico |

## Seniority aliases

```
pleno -> mid
especialista -> staff_lead
staff -> staff_lead
lead -> staff_lead
```

## Fontes

- Salary Portal, Information Systems Programmer, CBO 317110, data CAGED/eSocial/Employer Web, updated in 2026: https://www.salario.com.br/profissao/programador-de-sistemas-de-informacao-cbo-317110/
- Glassdoor Brasil, Software Developer, monthly range, updated in 2025: https://www.glassdoor.com/Salaries/br%C3%A9sil-software-developer-salary-SRCH_IL.0%2C6_IN36_KO7%2C25.htm
- O*NET Online, Software Developers 15-1252.00, local salaries with BLS 2024 source: https://www.onetonline.org/link/localwages/15-1252.00
- Upwork, Software Developer hourly cost guide, entry, intermediate and expert ranges: https://www.upwork.com/hire/software-developers/cost/
- Landing.Jobs Global Tech Talent Trends 2024: https://campaign.landing.jobs/gttt-2024
- Hays Portugal Salary Guide 2026: https://www.hays.pt/en/salary-guide/overview
- Glassdoor Mexico, Software Developer, monthly range, updated in 2025: https://www.glassdoor.com/Salaries/mexico-software-developer-salary-SRCH_IL.0%2C6_IN169_KO7%2C25.htm
- Computrabajo Mexico, IT Developer and Developer salaries, updated in 2025: https://mx.computrabajo.com/salarios/desarrollador-it

## Fallback rules

1. If `country` is not in the table, Market remains `unavailable: true`
2. If `seniority` uses an alias, normalize it and calculate
3. If `pricing_model` is not among the known models, use presentation of `escopo_fechado` and record fallback
4. `client_profile` does not change the price in v2
5. `complexity_class` must always exist in size; if absent, fail with message asking for Sizer recalculation

## Countries not covered in v2

For `country` outside of `[BR, US, PT, MX]`, the Market scenario is unavailable with explanation:

"Market range for `<country>` is not yet documented in this version of Reversa. Covered in v2: BR, US, PT, MX."

## How to extend

To add parents:

1. Prefer a public source for direct freelance rates
2. If you use salary, register `source_kind = salary_derived_freelance_estimate`
3. Cite the source and year on each line
4. Do not add multipliers for `client_profile` without dataset
5. Bump em `market` formula_version
