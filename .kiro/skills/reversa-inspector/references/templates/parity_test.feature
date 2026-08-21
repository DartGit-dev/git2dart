# Gherkin scenario template for parity_tests/.
# Each file must cover a critical flow identified in legacy process_flows.
# Adapt criteria to the target paradigm according to `parity_specs.md`.

# language: pt
# spec-id: PT-001
# rastreabilidade:
# process_flows: <ref to flow in reversa/sdd>
#   target_architecture: <reference to component in target_architecture.md>
#   paradigma_alvo: <do paradigm_decision.md>

Funcionalidade: <Nome do fluxo>
As <actor>
I want <action>
For <purpose>

# General parity criterion applied to this scenario.
# When the target paradigm is event-driven, express eventual consistency tolerance here.
  @paridade @critico
Scenario: <description>
Given <observable precondition>
And <secondary precondition>
When <action performed via API/command/input event>
So <observable effect on the new system>
And <observable effect persists after <propagation window>>

# Specific scenario to validate idempotence (event-driven, safe retry).
  @paridade @idempotencia
Scenario: Reprocessing does not double the effect
Given <precondition>
When <action> is processed once
And <action> is redelivered by retry
So the observable effect is identical to that of the first delivery

# Specific scenario to validate order in an event-driven paradigm.
  @paridade @ordem
Scenario: Order of events is respected by key
    Dado <chave de particionamento>
When <event A> is published before <event B> with the same key
So <observable effect> reflects the order A → B
