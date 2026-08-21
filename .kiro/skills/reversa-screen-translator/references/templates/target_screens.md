---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: target_screens
producedBy: screen-translator
mode: literal | modernized | hybrid
sourcePlatform: <slug>
targetPlatform: <slug>
adapter: <adapters/origem__alvo>
screenCount: <int>
hash: "sha256:<body hash below front-matter>"
---

# Target Screens

> Executable specification of each screen of the new system, derived from the legacy according to the method approved in `screen_modernization_decision.md`. Textual content preserved verbatim, unless explicit linguistic revision approval.
> Primary reading for the encoder. Each section is a contract.

## Summary

- **Applied mode**: <literal | modernized | hybrid>
- **Telas geradas**: <N>
- **Adapter**: <slug>
- **Tokens consumed**: see `reversa/sdd/design-system/tokens.md` and `tokens-derived.md` when applicable
- **Golden files**: <N> em `reversa/sdd/screens/golden/` (manifest em `golden/manifest.yaml`)
- **Deviations registradas**: <N> em `screen_deviation_log.md`

> If the legacy does not have a UI (batch system / API / daemon), replace this section with:
> "No screen detected. Agent skipped in `skipped` mode. Next agent: Inspector."

---

## Screen: <canonical-name>

**Origin**: `<legacy-file>:<linha-ou-paragrafo>`
**Applied mode**: literal | modernized
**Design-system components**: [<token1>, <token2>, ...]
**Interpolation points**: `{{var1}}`, `{{var2}}`
**Exit transitions**: [<next screen or event>]
**Critical screen?**: yes | no (query `reversa-detective` when available)

### Specification

> The block below varies depending on the source→target pair and the mode. See `references/adapter-pairs.md` for the canonical format of each pair. Examples below.

#### Example: COBOL TUI → Go CLI/TUI (literal)

```yaml
spec.kind: ansi-byte-stream
spec.normalize:
  - trim_trailing_spaces: false
  - line_endings: "\n"
spec.lines:
  - bytes: "\x1b[96m╔══════════════════════════════════════════════════╗\x1b[0m\n"
  - bytes: "\x1b[96m║ \x1b[93m▓▓▓ BANCO ATM ▓▓▓\x1b[96m ║\x1b[0m\n"
  - bytes: "\x1b[96m║                  \x1b[97m{{header_subtitle}}\x1b[96m                ║\x1b[0m\n"
    interpolations:
      header_subtitle:
        type: string
        max_width: 16
        source: literal "ATM" | literal "System Access"
  - bytes: "\x1b[96m╚══════════════════════════════════════════════════╝\x1b[0m\n"
spec.input_prompts:
  - kind: accept-line
    prompt_bytes: " \x1b[96m>>\x1b[97m Select an option: \x1b[0m"
    captures: opcao
    valid: ["0", "1", "2", "3", "4", "5"]
```

#### Example: Win32/Delphi VCL → Web SPA (modernized)

```yaml
spec.kind: component-tree
spec.states: [idle, loading, error, success]
spec.root:
  component: PageLayout
  variant: form
  children:
    - component: Header
      tokens: [color.brand-primary, typography.h1]
      content:
        text: "Cadastro de Cliente"
    - component: Form
      submit_event: cliente.create
      children:
        - component: FormField
          name: nome
          label: "Full name"
          legacy_origin: "TForm1.edtNome"
          validation:
            required: true
            max_length: 80
        - component: FormField
          name: cpf
          label: "CPF"
          legacy_origin: "TForm1.mskCPF"
          mask: "999.999.999-99"
          validation:
            required: true
            cpf: true
    - component: ButtonRow
      children:
        - component: Button
          variant: primary
          label: "Salvar"
          legacy_origin: "TForm1.btnSalvar"
          action: form.submit
        - component: Button
          variant: ghost
          label: "Cancelar"
          legacy_origin: "TForm1.btnCancelar"
          action: navigate.back
spec.state_messages:
  loading: "Salvando..."
  error: "{{error_message}}"
  success: "Client registered successfully."
```

#### Example: server-rendered legacy HTML → componentized SPA (modernized)

```yaml
spec.kind: route-component
spec.route: /clients/new
spec.layout: AppLayout
spec.states: [idle, loading, error, success]
spec.component:
  component: ClientesNovoPage
  legacy_origin: "/admin/cliente_novo.asp"
  state:
    cliente:
      type: Cliente
      initial: empty
  children:
    - component: PageTitle
      content: "New Customer"
    - component: ClienteForm
      props:
        onSubmit: clienteService.create
        initial: $state.cliente
spec.api_changes:
  - legacy: POST /admin/cliente_novo.asp (form-urlencoded)
    target: POST /api/clientes (application/json)
    deviation: DEV-014
```

#### Example: Android XML → Flutter (modernized)

```yaml
spec.kind: composable
spec.name: ClienteListScreen
spec.legacy_origin: "app/src/main/res/layout/activity_cliente_list.xml + ClienteListActivity.java"
spec.states: [idle, loading, error, success]
spec.composable: |
  Scaffold(
    appBar: AppBar(title: Text("Clientes")),
    body: Consumer<ClienteListVM>(
      builder: (ctx, vm, _) => vm.loading
        ? CircularProgressIndicator()
        : ListView.builder(
            itemCount: vm.clientes.length,
            itemBuilder: (_, i) => ClienteListTile(cliente: vm.clientes[i]),
          ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.pushNamed(ctx, '/clientes/novo'),
      child: Icon(Icons.add),
    ),
  )
spec.viewmodel:
  name: ClienteListVM
  legacy_origin: "ClienteListActivity.onResume"
  methods:
    - load(): chama clienteService.listar
```

### Points of divergence accepted

- DEV-XXX: <short description> (see `screen_deviation_log.md#DEV-XXX`)

### States (modernized mode only)

| Status | Description | Content/message |
|---|---|---|
| Idle | Default state before any action | <content> |
| Loading | Asynchronous operation in progress | <spinner/skeleton> |
| Error | Operation failed or invalid data | `{{error_message}}` |
| Success | Operation completed successfully | <confirmation message> |

> In literal mode, this section can be omitted or replaced with "preserves the states of the legacy" if the legacy has no explicit arrangement of states.

---

## Screen: <second-screen>

(repeat the block above for each screen)

---

## Appendix: inventory traceability

| `target_screens.md` Screen | Source in `reversa/sdd/ui/inventory.md` | Source in `reversa/sdd/screens/inventory.json` |
|---|---|---|
| <screen 1> | <inventory line> | <internal inventory id> |
| <screen 2> | <inventory line> | <internal inventory id> |
