# Adapter Pairs

Map of source→target pairs supported in v1, with mode recommended by default and the canonical spec format to use in `target_screens.md`. Unlisted pairs return `EC-01` and offer raw template.

## Tabela mestre

| Origin | Target | Recommended mode | Adapter | Spec format |
|---|---|---|---|---|
| `cobol-ansi-tui` | `go-cli` | literal | `cobol_ansi__go_cli` | `ansi-byte-stream` |
| `cobol-ansi-tui` | `rust-cli` | literal | `cobol_ansi__rust_cli` | `ansi-byte-stream` |
| `cobol-ansi-tui` | `web-spa` | modernizado | `cobol_ansi__web_spa` | `component-tree` |
| `cobol-screen-section` | `go-cli` | literal | `cobol_screen__go_cli` | `ansi-byte-stream` |
| `ncurses-c` | `go-cli` | literal | `ncurses__go_cli` | `ansi-byte-stream` |
| `ncurses-c` | `rust-cli` | literal | `ncurses__rust_cli` | `ansi-byte-stream` |
| `delphi-vcl` | `web-spa` | modernizado | `delphi_vcl__web_spa` | `component-tree` |
| `delphi-vcl` | `tauri` | modernized (with literal-ish option) | `delphi_vcl__tauri` | `component-tree` |
| `delphi-vcl` | `electron` | modernizado | `delphi_vcl__electron` | `component-tree` |
| `delphi-firemonkey` | `flutter` | modernizado | `delphi_firemonkey__flutter` | `composable` |
| `vb6` | `web-spa` | modernizado | `vb6__web_spa` | `component-tree` |
| `vb6` | `tauri` | modernizado | `vb6__tauri` | `component-tree` |
| `vbnet-winforms` | `web-spa` | modernizado | `vbnet_winforms__web_spa` | `component-tree` |
| `csharp-winforms` | `web-spa` | modernizado | `csharp_winforms__web_spa` | `component-tree` |
| `csharp-wpf` | `web-spa` | modernizado | `csharp_wpf__web_spa` | `component-tree` |
| `win32-mfc` | `web-spa` | modernizado | `win32_mfc__web_spa` | `component-tree` |
| `win32-raw` | `web-spa` | modernizado | `win32_raw__web_spa` | `component-tree` |
| `asp-classic` | `web-spa` (React/Vue/Svelte) | modernizado | `asp_classic__spa` | `route-component` |
| `aspnet-webforms` | `web-spa` | modernizado | `aspnet_webforms__spa` | `route-component` |
| `jsp` | `web-spa` | modernizado | `jsp__spa` | `route-component` |
| `php-server-rendered` | `web-spa` | modernizado | `php__spa` | `route-component` |
| `html-legacy-jquery` | `web-spa` | modernizado | `html_legacy__spa` | `route-component` |
| `android-xml-java` | `flutter` | modernizado | `android_xml__flutter` | `composable` |
| `android-xml-java` | `compose` | modernized (close language) | `android_xml__compose` | `composable` |
| `android-xml-kotlin` | `compose` | modernized (close language) | `android_xml_kt__compose` | `composable` |
| `ios-xib-objc` | `flutter` | modernizado | `ios_xib_objc__flutter` | `composable` |
| `ios-xib-objc` | `swiftui` | modernized (close language) | `ios_xib_objc__swiftui` | `composable` |
| `ios-xib-swift` | `swiftui` | modernized (close language) | `ios_xib_swift__swiftui` | `composable` |

## Modes available per pair

For each pair, in general three modes are presented to the user, but some combinations have a literal **infeasible** mode. The table below restricts it.

| Pair | Viable literal? | Why |
|---|---|---|
| `cobol-ansi-tui` → `go-cli` | sim | terminais textuais respeitam ANSI byte-a-byte |
| `cobol-ansi-tui` → `web-spa` | no | terminal has no literal equivalent in DOM; refuses literal mode |
| `delphi-vcl` → `web-spa` | partial | only with a screenshot of the legacy and explicit acceptance; pixel-perfect rare |
| `win32-mfc` → `web-spa` | no | refuses literal mode; recommends modernized |
| `android-xml-*` → `flutter` | partial | only with screenshots by density; font-dependent pixel-perfect |
| `android-xml-*` → `compose` | partial | same language, closer, but widgets differ |
| `ios-xib-*` → `swiftui` | parcial | mesma plataforma, mas constraints e auto-layout divergem |

When `literal` is not viable, the agent presents only modernized and hybrid as options, and explains to the user why literal it was discarded.

## Formato de spec por kind

### `ansi-byte-stream` (terminais textuais)

Each line as `bytes` block containing the literal string, including ANSI escapes. Use `\x1b[...m` for colors. Interpolations declared with `interpolations.<name>` per line. User inputs via `spec.input_prompts`.

Typical target implementation: one function per screen in `pkg/menu/screens.<ext>` that writes to `io.Writer`.

### `component-tree` (graphical desktop/web/mobile, modernized mode)

Nominal component hierarchy (`PageLayout`, `Form`, `FormField`, `Button`, ...). Tokens referenced in `tokens: [...]`. Events in `submit_event`, `action`. States in `spec.states: [idle, loading, error, success]`. Messages by state in `spec.state_messages`.

Target implementation: free framework (React, Vue, Svelte, SwiftUI, Compose, Tauri webview, etc.) unless `target_architecture.md` has already fixed a specific framework.

### `route-component` (web modernizado a partir de server-rendered)

Includes `spec.route` (target canonical URL) and `spec.layout` (parent layout). Body is a `component-tree`. `spec.api_changes` lists HTTP contract changes between legacy and target (URL, method, content-type), referencing deviations.

### `composable` (mobile cross-platform)

`spec.composable` block with declarative pseudo-code in the target language (Flutter Dart, Compose Kotlin, SwiftUI Swift). Includes `spec.viewmodel` when the target separates view and state.

### `raw-prose` (fallback EC-01)

When the adapter does not cover the pair. Content is structured prose with mandatory sections (identity, layout, fields, messages, events, validations). Each screen in `raw-prose` must have deviation recorded indicating that the coder will need to interpret the prose.

## Entradas e estados especiais

Every spec, in any kind, can include:

- `spec.normalize`: rules accepted compared to golden file (line endings, trailing spaces, ANSI trim, etc.).
- `spec.interpolations`: points where dynamic domain data enters (e.g. `{{titular}}`, `{{saldo}}`). With types and restrictions (max_width, regex, lookup).
- `spec.transitions`: list of events that lead to another screen.
- `spec.legacy_origin`: legacy path in `file:line` or `file:paragraph` form.
- `spec.deviations`: `DEV-XXX` ids that affect the screen.

## Pairs not covered in v1

- Platforms with custom rendering (Canvas HTML5, OpenGL, games): return `EC-01`.
- 3D, AR/VR: fora do escopo (NG-07).
- Voz / conversacional: fora do escopo.
- Plugins descontinuados embedded (Crystal Reports, Flash, ActiveX): tratamento em v2 (OQ-03).

New pairs can be added as rows in this table, along with a descriptive adapter (not code, it is textual heuristics used by the agent to generate the spec).
