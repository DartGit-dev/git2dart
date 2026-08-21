# Estimativa de Preco

**Feature:** `reversa/sdd/forward/042-pagamento-pix`
**Generated on:** 2026-05-06 16:42 UTC
**Calculation version:** Effort v2.0, Value v2.0, Market v2.0

**Pre-requisitos consumidos:**
- Profile: `reversa/sdd/_pricing/profile.json`
- Size: `reversa/sdd/_pricing/042-pagamento-pix/size.json` (classe `L`, score auxiliar `60`)

## Visao geral

| Scenario | Range | Comment |
|---|---|---|
| **Effort** | 4,800.00 to 12,000.00 BRL | 32 to 80h, cost + tax + markup |
| **Value** | 2,400.00 to 7,200.00 BRL | 10% to 30% of declared annual value |
| **Market Range** | 3,200.00 to 16,000.00 BRL | hourly rate sourced by country and seniority |

## Effort Scenario

**What it is:** price calculated based on probable hours, hourly rate, approximate tax reserve and project markup. And the floor is defensible so as not to subsidize the customer.

**When to use:** always as a sanity check. Charging below the Effort means assuming a loss or reducing the project's profit too much.

| Item | Value |
|---|---|
| Classe de complexidade | L |
| Seniority | senior |
| Seniority factor | 1.00 |
| Horas estimadas | 32 a 80 h |
| Ponto medio | 56 h |
| Hourly rate | 100.00 BRL/h |
| Direct cost | 3,200.00 to 8,000.00 BRL |
| Reserva tributaria aproximada | 480,00 a 1.200,00 BRL |
| Project markup (35%) | 1,120.00 to 2,800.00 BRL |
| **Effort range** | **4,800.00 to 12,000.00 BRL** |
| Ponto medio | 8.400,00 BRL |

Warning: part of the tax factor may be tax highlighted and passed on to the customer. Validate with an accountant.

## Value Scenario

**What it is:** price based on part of the annual economic value that the feature generates or protects for the customer. Reversa uses capture of 10% to 30% of the declared annual value.

**When to use:** when the customer is able to declare return, savings or cost of not doing it.

| Item | Value |
|---|---|
| Retorno mensal declarado | 2.000,00 BRL |
| Usuarios impactados | 500 |
| Cost of not doing it | 5,000.00 BRL |
| Annual value used | 24,000.00 BRL |
| Captura aplicada | 10% a 30% |
| Recommended price | 4,800.00 BRL |
| **Value range** | **2,400.00 to 7,200.00 BRL** |
| Approximate payback | 1.2 to 3.6 months |

## Market Range Scenario

**What it is:** range derived from hourly benchmark by country and seniority, multiplied by the same range of hours from the Effort scenario.

**When to use:** as an external reference. v2 does not multiply by customer profile because there is no reliable public dataset for this.

| Item | Value |
|---|---|
| Country / Seniority | Brazil / senior |
| Modelo / Perfil cliente | escopo_fechado / pequena_empresa |
| Complexidade | L |
| Market hourly rate | 100.00 to 200.00 BRL/h |
| Source type | salary_derived_freelance_estimate |
| Ano de referencia | 2025-2026 |
| Fontes | Portal Salario CAGED, Glassdoor Brasil |
| **Market range** | **3,200.00 to 16,000.00 BRL** |

## How to choose between the three

The Declared Value generates a smaller range than the Average Effort. Use Effort as a defensible floor and Market as an external reference. For this client, charge below 4,800 BRL only if there is a clear strategic reason.

Heuristica geral:

1. Customer without clear return: use Effort as a floor and Market as an external reference
2. Customer with high and clear return: prefer Value, with Effort only as a minimum floor
3. Effort above the Market: review the client’s profile, size or suitability
4. Market above Effort: there is room to increase markup or improve proposal

## Disclaimer

The numbers in this estimate are approximations for budget guidance, not a guarantee of closing the sale. The tax factor is an approximate reserve, not an exact legal rate. Real tax validation and responsibility of the user's accountant. The market range is static and based on sources documented in `market-benchmarks.md`. The return declared by the client in the Value scenario is raw input, not validated. It is recommended to add `reversa/sdd/_pricing/<feature>/estimate.{md,json}` to `.gitignore` before committing.
