# Platform Detection

Heuristics that `reversa-screen-translator` uses to classify the legacy source platform from the contents of `reversa/sdd/inventory.md` and the source code. Use together with `references/adapter-pairs.md` to choose the adapter.

The confidence scale applied by rating:

- 🟢 **CONFIRMED**: at least one strong signature (header, namespace, unique marker) is present.
- 🟡 **INFERRED**: extension and general pattern match, but there is no unique signature.
- 🔴 **GAPS**: missing source code artifact; sorts only by `inventory.md`.
- ⚠️ **AMBIGUO**: two plausible platforms tied (e.g. classic ASP vs ASP.NET WebForms in old projects).

## Tabela de assinaturas

| Source slug | Typical extension | Strong signature | Weak signature |
|---|---|---|---|
| `cobol-ansi-tui` | `.cob`, `.cbl`, `.cpy` | `PROCEDURE DIVISION.` + `DISPLAY`/`ACCEPT` + `\x1B[` sequences, Unicode box-drawing (`╔ ╗ ┌ ┐`) | only `PROCEDURE DIVISION` (without ANSI = COBOL batch) |
| `cobol-screen-section` | `.cob`, `.cbl` | `SCREEN SECTION` + attributes `LINE`, `COLUMN`, `FOREGROUND-COLOR` | `SCREEN SECTION` no details |
| `ncurses-c` | `.c`, `.h` | `#include <ncurses.h>` ou `<curses.h>` + `WINDOW *`, `wprintw`, `mvwaddstr` | `printf` + `\033[` (TUI artesanal) |
| `delphi-vcl` | `.pas`, `.dfm`, `.dpr` | `unit `, `interface`, `TForm`, `TPanel`, `TButton` in `.dfm` | Pure `.pas` without `.dfm` (likely CLI) |
| `delphi-firemonkey` | `.pas`, `.fmx` | `TForm` in file `.fmx` (FireMonkey) | only `.pas` |
| `vb6` | `.frm`, `.bas`, `.cls`, `.vbp` | `VERSION 5.00` in header, `Begin VB.Form`, `Begin VB.CommandButton` | Pure `.bas` (module without UI) |
| `vbnet-winforms` | `.vb` + `Designer.vb` | `Inherits System.Windows.Forms.Form` | only `Module ... Sub Main` (CLI) |
| `csharp-winforms` | `.cs`, `.designer.cs` | `using System.Windows.Forms;` + `partial class ... : Form` | only `using System;` |
| `csharp-wpf` | `.xaml`, `.cs` | `xmlns="http://schemas.microsoft.com/winfx/..."` + `<Window>`, `<Grid>` | only `.cs` without `.xaml` |
| `win32-mfc` | `.cpp`, `.h`, `.rc` | `BEGIN_MESSAGE_MAP`, `CDialog`, `WinMain`, `IDD_*` em `.rc` | `WinMain` solto |
| `win32-raw` | `.cpp`, `.h` | `WinMain` + `RegisterClass`, `CreateWindow`, `WM_*` messages | only `WinMain` |
| `asp-classic` | `.asp`, `.inc` | `<%@ Language=VBScript %>` or `<%@ Language=JScript %>` + `Response.Write` | `.asp` without `<%@` |
| `aspnet-webforms` | `.aspx`, `.aspx.cs`, `.aspx.vb` | `<%@ Page Language="C#"`, `runat="server"`, `<asp:` controls | just simple `.aspx` |
| `jsp` | `.jsp`, `.jspf` | `<%@ page language="java" %>`, `<jsp:`, `<%! %>` | `.jsp` with HTML only |
| `php-server-rendered` | `.php` | `<?php ... ?>` + inline HTML + `mysql_*` or `mysqli_*` | only `.php` in folder `api/` (probably REST API, not UI) |
| `html-legacy-jquery` | `.html`, `.htm`, `.js` | `jQuery`/`$.ajax` + form submissions server-side, without SPA framework | Static HTML (no dynamic JS) |
| `android-xml-java` | `res/layout/*.xml`, `*.java` | `<LinearLayout>`/`<RelativeLayout>`/`<ConstraintLayout>` + `Activity extends`, `setContentView(R.layout...)` | only Java without `res/layout/` |
| `android-xml-kotlin` | `res/layout/*.xml`, `*.kt` | same above + `Activity()` Kotlin + `setContentView(R.layout...)` | just Kotlin without `res/layout/` |
| `android-compose` | `*.kt` | `@Composable`, `setContent { ... }` | without `setContent` |
| `ios-xib-objc` | `.xib`, `.m`, `.h`, `.storyboard` | `UIViewController` + `*.xib` or `*.storyboard` referenced | only `*.m` without XIB |
| `ios-xib-swift` | `.xib`, `.swift`, `.storyboard` | `UIViewController` Swift + XIB/Storyboard | only `*.swift` without XIB |
| `ios-swiftui` | `*.swift` | `View` + `var body: some View`, `App` life cycle | without `var body` |
| `flutter` | `*.dart`, `pubspec.yaml` | `import 'package:flutter/material.dart'` + `StatelessWidget`/`StatefulWidget` | without `material.dart` |
| `react-class` | `*.jsx`, `*.tsx` | `class ... extends React.Component` + `render()` | only `*.tsx` (probably modern) |
| `react-hooks` | `*.jsx`, `*.tsx` | `function ... ({...}) { return <...>; }` + `useState`, `useEffect` | (not legacy, target) |

## Indicadores adicionais

- **Directory structure**:
  - `forms/`, `Forms/` → Delphi, VB6, .NET WinForms.
  - `views/`, `templates/` → MVC server-side (ASP, JSP, PHP).
  - `app/src/main/res/layout/` → Android.
- `Storyboard.storyboard` or `*.xib` in root → legacy iOS.
- `Pages/` in Razor → ASP.NET project.
- **Build files**:
  - `*.dpr` (Delphi), `*.vbp` (VB6), `*.csproj` (.NET), `pom.xml`/`build.gradle` (Java/Android), `Podfile` (iOS), `pubspec.yaml` (Flutter).
- **Version strings in comments or headers**: VB6 tag `VERSION 5.00`; Delphi 7 tag `{$OBJECT}`; .NET with `<TargetFramework>net48</TargetFramework>` indicates legacy WinForms.

## When two platforms tie

- **Classic ASP vs ASP.NET WebForms**: `.asp` files without `.aspx` → classic. `.aspx` + `.asp` in the same project → project migrating, mark ⚠️ AMBIGUOUS and ask.
- **VB6 vs VB.NET**: `.frm` + `.vbp` → VB6. `.vb` + `.designer.vb` + `.vbproj` → VB.NET WinForms.
- **Delphi VCL vs FireMonkey**: `.dfm` → VCL. `.fmx` → FireMonkey. Both in the project → mark ⚠️ AMBIGUOUS.
- **Android Java vs Kotlin**: `.java` + `.kt` in the same project → project in migration; sort by individual file.
- **iOS Storyboard vs XIB**: both supported; treat as a class (`ios-xib-*`). The difference is in the capture detail.

## When nothing matches

Register `EC-01` (platform of unknown origin) and offer the user a "raw" template where it describes the screen in structured prose, with mandatory sections:

- Identidade.
- Layout em ASCII art ou screenshot.
- List of fields/components.
- Mensagens / labels literais.
- Events and transitions.
- Validations.

The agent then generates `target_screens.md` with `spec.kind: raw-prose` and marks in `screen_deviation_log.md` that the screen did not pass through the adapter.
