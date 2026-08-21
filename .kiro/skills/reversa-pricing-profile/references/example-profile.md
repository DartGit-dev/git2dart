# Perfil de Cobranca

**Criado em:** 2026-05-06 14:32 UTC
**Versao do schema:** 1.1

## Identificacao

| Field | Value |
|---|---|
| Country | Brazil (BR) |
| Moeda local | Real Brasileiro (BRL) |
| Seniority | senior |

## Direct cost

| Field | Value |
|---|---|
| Hourly rate mode | Derived |
| Renda mensal liquida desejada | 12.000,00 BRL |
| Horas faturaveis por mes | 120 |
| Calculated hourly rate | 100.00 BRL/h |

## Markup e impostos

| Field | Value |
|---|---|
| Project markup | 35% |
| Tax regime | Simples Nacional, IT services |
| Approximate factor | 15% |
| Factor type | effective_reserve_estimate |
| Factor source | Brazilian Federal Revenue Service, Simples Nacional, annexes, and R factor |
| Inclui imposto destacado | Sim |
| Aviso de repasse | Sim |
| Regime confidence | High, explicit choice |

## Modelo comercial

| Field | Value |
|---|---|
| Modelos de cobranca | escopo_fechado, time_and_materials |
| Perfil de cliente | pequena_empresa |
| Foreign-currency billing | No |

## Disclaimer

The recorded tax factor is an approximate budget reserve, not an exact legal rate. Real tax validation and responsibility of the user's accountant. This file contains sensitive financial data. It is recommended to add `reversa/sdd/_pricing/profile.json` and `reversa/sdd/_pricing/profile.md` to `.gitignore` before committing.
