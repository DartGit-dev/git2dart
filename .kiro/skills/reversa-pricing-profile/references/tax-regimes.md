# Catalogo de regimes tributarios

Extensible catalog used by the `reversa-pricing-profile` agent to map the tax regime declared by the user into an approximate `tax_factor`. The factors are didactic budget reserves, not exact legal rates.

## How to read this file

Each regime has:

- `key`: chave canonica gravada em `profile.json`
- `country`: codigo ISO 3166-1 alpha-2 ou `INTL`
- `name_pt_br`: nome amigavel usado no chat
- `tax_factor`: approximate factor applied to direct cost
- `tax_factor_kind`: `effective_reserve_estimate`, `statutory_proxy` ou `not_computed`
- `includes_vat`: combines income/contribution tax with highlighted VAT/VAT/ISS
- `vat_pass_through_warning`: whether the estimate should warn that part of the tax can be passed on to the customer
- `tax_factor_source`: public source or description of the basis
- `notes_pt_br`: short note for user

## Disclaimer obrigatorio

The factors recorded here are didactic approximations based on a known public reference in 2026-05. They do not replace accounting guidance. The accuracy depends on deductibles, municipality, income range, CNAE, framework, retentions, international treaties and rules in force at the time of issuing the note.

The agent must repeat the disclaimer during the interview and in the `profile.md` footer.

## Brasil (BR)

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| MEI | Individual Microentrepreneur (MEI) | 0.06 | effective_reserve_estimate | true | true | Entrepreneur Portal and DAS-MEI public rules | Simplified booking. MEI usually has a fixed DAS and revenue limit. Software activity may require framework validation. |
| simples_servicos | Simples Nacional, IT services | 0.15 | effective_reserve_estimate | true | true | Brazilian Federal Revenue Service, Simples Nacional, annexes and R factor | Average reserve. The actual rate depends on the annex, RBT12, R factor, ISS, and withholding. |
| presumed_profit | Presumed Profit, services | 0.165 | effective_reserve_estimate | true | true | Federal Revenue, IRPJ, CSLL, PIS, COFINS and ISS | Combined reservation for services. Validate municipal ISS and withholdings. |
| autonomous_pf | Self-employed individual, lion meat | 0.275 | effective_reserve_estimate | false | false | Federal Revenue, progressive IRPF and INSS | Book for senior professionals. Effective rate varies depending on deductions and social security contributions. |

## Estados Unidos (US)

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| self_employed_1099 | Self-Employed, 1099, sole proprietor | 0.30 | effective_reserve_estimate | false | false | IRS, self-employment tax, and federal income tax | Combined reserve. It does not include state tax or specific deductions. |
| s_corp_llc | S-Corp or LLC with S-Corp election | 0.22 | effective_reserve_estimate | false | false | IRS, payroll tax, reasonable salary and distributions | Simplified booking. Requires accountant for reasonable salary and distributions. |

## Portugal (PT)

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| pt_simplified | Category B, simplified regime | 0.21 | effective_reserve_estimate | true | true | Tax Authority, IRS Category B, VAT and Social Security | Combined booking. VAT can be highlighted and passed on to the customer. |
| pt_organizada | Categoria B, contabilidade organizada | 0.18 | effective_reserve_estimate | true | true | Autoridade Tributaria, contabilidade organizada | Reserva simplificada. Custos reais podem reduzir base tributavel. |

## Mexico (MX)

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| mx_resico | Regimen Simplificado de Confianza (RESICO) | 0.10 | effective_reserve_estimate | true | true | SAT, RESICO PF e IVA | Reserva combinada. ISR pode ser baixo, mas IVA pode aplicar conforme caso. |
| mx_actividad_empresarial | Business and Professional Activity (PF) | 0.20 | effective_reserve_estimate | true | true | SAT, progressive ISR and VAT | Simplified booking for independent professionals. |

## Internacional (INTL)

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| intl_freelance_no_withhold | International freelance, client without retention | 0.00 | not_computed | false | false | Depends on the country of the provider | Customer pays gross. Use the provider's national regime for actual tax. |
| intl_freelance_with_withhold | International freelance, client withholding | 0.15 | effective_reserve_estimate | false | false | Bilateral treaties and local rules | Actual retention depends on treaty and customer's country. |

## Outro

| key | name_pt_br | tax_factor | tax_factor_kind | includes_vat | vat_pass_through_warning | tax_factor_source | notes_pt_br |
|---|---|---:|---|---|---|---|---|
| other | Other regime, not listed | 0.00 | not_computed | false | false | User reported uncataloged regime | Tax not computed. Estimate must inform that the calculation is the responsibility of the accountant. |

## Essential regimes for future regions

Do not enable these countries as covered in the Market scenario without cataloging minimum regimes:

| country | regimes essenciais |
|---|---|
| GB | sole_trader_self_assessment, limited_company |
| DE | freiberufler, gewerbe_einzelunternehmen, gmbh |
| ES | autonomo_estimacion_directa_simplificada, autonomo_estimacion_directa_normal, sociedad_limitada |
| AR | monotributo, responsable_inscripto |
| CO | regimen_simple, regimen_ordinario_persona_natural, sociedad |

Fontes oficiais verificadas:

- UK GOV.UK, sole trader e limited company: https://www.gov.uk/set-up-business/sole-trader.html
- Alemanha, portal administrativo federal, registro fiscal: https://verwaltung.bund.de/leistungsverzeichnis/EN/leistung/99102019120000/herausgeber/HH-S1000020010000009790/region/020000000000
- Espanha, Agencia Tributaria, regimes de determinacao de rendimento: https://sede.agenciatributaria.gob.es/Sede/irpf/empresarios-individuales-profesionales/regimenes-determinar-rendimiento-actividad.html
- Argentina ARCA, Monotributo: https://www.afip.gob.ar/monotributo/
- Colombia DIAN, Regimen Simple de Tributacion: https://micrositios.dian.gov.co/regimen-simple-tributacion/

## Suggested default regime by country

When the user responds "I don't know", the agent suggests the pattern below and marks `tax_regime_confidence = "low"`:

| country | suggested default regime |
|---|---|
| BR | simples_servicos |
| US | self_employed_1099 |
| PT | pt_simplificado |
| MX | mx_resico |
| Other country | without suggestion, ask for explicit choice |

## How to extend

1. Add country section with the same table
2. Cite a public source
3. Check whether the factor includes VAT, VAT or highlighted tax
4. Do not call `tax_factor` a legal tax rate
5. Update the schema if new fields are needed
