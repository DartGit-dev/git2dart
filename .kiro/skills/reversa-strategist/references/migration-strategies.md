> Local copy of the advisory catalogue. Canonical font in `templates/migration/catalogs/migration_strategies.md`.

# Migration Strategies (local copy)

## Strategies

### Strangler Fig
- **When applied**: system in production, cannot stop; need for incrementality; possibility of routing (proxy / API gateway).
- **Cost**: medium. **Risk**: low. **Time**: long.
- **Apetite favorecido**: conservative, balanced.

### Big Bang
- **When applied**: small system; tolerated window; transformational appetite; few live integrations.
- **Cost**: low. **Risk**: high. **Time**: short.
- **Apetite favorecido**: transformational (em sistemas pequenos).

### Parallel Run
- **When applicable**: critical logic (financial / tax / regulatory); requires proof of equivalence over a long period.
- **Cost**: high. **Risk**: medium. **Time**: medium.
- **Apetite favorecido**: balanced.

### Branch by Abstraction
- **When applicable**: internal migration (language or framework changes, domain stays); conservative appetite.
- **Cost**: low. **Risk**: low. **Time**: medium.
- **Apetite favorecido**: conservative.

## Recommendation rules

- apetite `conservative` → Branch by Abstraction + Strangler Fig.
- apetite `balanced` → Strangler Fig + Parallel Run.
- appetite `transformational` → Big Bang in small systems; Strangler Fig with deep edges on larger ones.
- major paradigm shift + transformational appetite → recommend Parallel Run to validate parity.
- system with regulatory integrations → never recommend Big Bang.

## Pseudo-procedimento

1. Filter applicable strategies based on brief.
2. Score remaining points for adherence to appetite and paradigm gap.
3. Selecionar 2 a 3 candidatas.
4. Mark one as recommended with justification.
5. For each other, list cons as a reason for non-recommendation.
