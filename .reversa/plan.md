# Plano de Exploração — git2dart

> Criado pelo Reversa em 2026-08-16
> Marque cada tarefa com ✅ quando concluída.
> Você pode editar este plano antes de iniciar: adicione, remova ou reordene tarefas conforme necessário.

---

## Fase 1: Reconhecimento 🔍

- [x] ✅ **Scout** — Mapeamento de estrutura de pastas e tecnologias
- [x] ✅ **Scout** — Análise de dependências e gerenciadores de pacotes
- [x] ✅ **Scout** — Identificação de entry points, CI/CD e configurações

## Decisão de organização das specs 🗂️

> Entre o Scout e o Arqueólogo, o Reversa pergunta como você quer organizar as specs (por módulo, caso de uso, endpoint, híbrida, por features ou customizada). A escolha fica persistida em `.reversa/config.toml` na seção `[specs]` e não será reperguntada em execuções futuras. Para reapresentar o menu, remova manualmente a seção.

## Fase 2: Escavação 🏗️

> O Reversa preenche esta seção com os módulos reais após o Scout concluir o reconhecimento.

- [x] ✅ **Archaeologist** — Analysis of module `repository-lifecycle`
- [x] ✅ **Archaeologist** — Analysis of module `git-objects-and-object-database`
- [x] ✅ **Archaeologist** — Analysis of module `working-tree-and-index`
- [x] ✅ **Archaeologist** — Analysis of module `references-and-remotes`
- [x] ✅ **Archaeologist** — Analysis of module `history-and-integration-operations`
- [x] ✅ **Archaeologist** — Analysis of module `native-runtime-and-platform-boundary`

## Fase 3: Interpretação 🧠

- [x] ✅ **Detective** — Git archaeology and retrospective ADRs
- [x] ✅ **Detective** — Implicit domain rules and state machines
- [x] ✅ **Detective** — Permissions and trust-boundary matrix
- [x] ✅ **Architect** — C4 diagrams (Context, Containers, Components)
- [x] ✅ **Architect** — Complete logical ERD and external integrations
- [x] ✅ **Architect** — Spec Impact Matrix

## Fase 4: Geração 📝

- [x] ✅ **Writer** — Feature-oriented SDD specifications
- [x] ✅ **Writer** — OpenAPI applicability assessed (not applicable: no HTTP/RPC API)
- [x] ✅ **Writer** — User Stories
- [x] ✅ **Writer** — Code/Spec Matrix

## Fase 5: Revisão ✅

- [x] ✅ **Reviewer** — Cross-spec consistency and matrix validation
- [x] ✅ **Reviewer** — Open gaps collected (12 unanswered validation questions)
- [x] ✅ **Reviewer** — Final confidence report

---

## Agentes Independentes

> Execute estes agentes quando os recursos estiverem disponíveis — podem rodar em qualquer fase.

- [ ] **Visor** — Análise de interface via screenshots
- [ ] **Data Master** — Análise completa do banco de dados
- [ ] **Design System** — Extração de tokens de design
- [ ] **Tracer** — Análise dinâmica (requer sistema acessível)

---

## Próximo passo

Após o Time de Descoberta concluir e o `_reversa_sdd/` estar populado, você pode disparar um dos fluxos seguintes:

- `/reversa-migrate`: orquestrador do **Time de Migração** (Paradigm Advisor → Curator → Strategist → Designer → Screen Translator → Inspector). Gera as specs do sistema novo. Saída em `_reversa_sdd/migration/` e `_reversa_sdd/screens/`.
- `/reversa-reconstructor`: gera plano bottom-up para reimplementar o software a partir das specs do legado (uma tarefa por sessão).
