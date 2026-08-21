#!/usr/bin/env python3
"""
Spec Scorer — Evaluates the quality of a feature specification
Baseado na rubrica em references/evaluation_rubric.md

Uso:
    python scripts/spec_scorer.py --spec path/to/spec.md
    python scripts/spec_scorer.py --spec spec.md --json   # JSON output
"""

import argparse
import json
import re
import sys
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional


# ─── Data structures ────────────────────────────────────────────────────

@dataclass
class DimensionScore:
    name: str
    weight: float          # peso relativo (soma = 1.0)
    raw_score: float       # 0–100 within the dimension
    max_raw: float         # maximum possible
    issues: list[str] = field(default_factory=list)
    positives: list[str] = field(default_factory=list)

    @property
    def weighted_score(self) -> float:
        return (self.raw_score / self.max_raw) * self.weight * 100


@dataclass
class SpecReport:
    file: str
    total_score: float
    classification: str
    dimensions: list[DimensionScore]
    critical_gaps: list[str]
    suggestions: list[str]
    raw_text: str


# ─── Analysis helpers ─────────────────────────────────────────────────────

def load_spec(path: str) -> str:
    p = Path(path)
    if not p.exists():
        print(f"❌ File not found: {path}", file=sys.stderr)
        sys.exit(1)
    return p.read_text(encoding="utf-8")


def has_section(text: str, section_pattern: str) -> bool:
    return bool(re.search(section_pattern, text, re.IGNORECASE | re.MULTILINE))


def section_content(text: str, section_pattern: str) -> str:
    """Extracts section content up to the next section at the same level."""
    match = re.search(section_pattern, text, re.IGNORECASE | re.MULTILINE)
    if not match:
        return ""
    start = match.end()
    next_section = re.search(r'^#{1,2}\s+\d+\.', text[start:], re.MULTILINE)
    end = start + next_section.start() if next_section else len(text)
    return text[start:end].strip()


def count_pattern(text: str, pattern: str) -> int:
    return len(re.findall(pattern, text, re.IGNORECASE | re.MULTILINE))


def has_content(text: str, min_words: int = 10) -> bool:
    words = re.findall(r'\b\w+\b', text)
    return len(words) >= min_words


def count_rf_items(text: str) -> int:
    return count_pattern(text, r'\bRF-\d+\b')


def count_nf_items(text: str) -> int:
    return count_pattern(text, r'\bNG-\d+\b')


def count_ec_items(text: str) -> int:
    return count_pattern(text, r'\bEC-\d+\b')


def count_unfilled_placeholders(text: str) -> int:
    return count_pattern(text, r'\[[A-Z][^\]]{3,60}\]')


def has_numeric_metric(text: str) -> bool:
    # Search for patterns such as "< 200ms", "≥ 25%", "99,9%", "< 2min"
    return bool(re.search(r'[<>≤≥]\s*\d+|=\s*\d+\s*%|\d+\s*(ms|min|h|%|dias?|days?)', text))


def has_vague_terms(text: str) -> list[str]:
    vague = ["rapidamente", "logo", "brevemente", "alguns", "muitos",
             "de forma eficiente", "de forma intuitiva", "fácil de usar",
             "user-friendly", "performático", "ser bonito", "ser rápido",
             "ser bom", "quickly", "easily", "fast", "nice"]
    found = []
    for term in vague:
        if re.search(r'\b' + re.escape(term) + r'\b', text, re.IGNORECASE):
            found.append(term)
    return found


def has_contradictions_signal(text: str) -> bool:
    # Simple heuristic: presence of "mas" / "porém" / "entretanto" after a requirement
    return bool(re.search(r'RF-\d+.*?\b(mas|porém|entretanto|however|but)\b', text,
                           re.IGNORECASE | re.DOTALL))


# ─── Evaluators by dimension ────────────────────────────────────────────────

def score_completude(text: str) -> DimensionScore:
    dim = DimensionScore(name="Completude", weight=0.30, raw_score=0, max_raw=30)
    score = 0

    # Essential sections (1–6) are present and contain content
    required_sections = [
        (r'^#{1,2}\s+1[\.\s]+(?:Resum|Summary)', "Section 1 (Summary)"),
        (r'^#{1,2}\s+2[\.\s]+(?:Contexto|Context)', "Section 2 (Context)"),
        (r'^#{1,2}\s+3[\.\s]+Goals', "Section 3 (Goals)"),
        (r'^#{1,2}\s+4[\.\s]+Non.Goals', "Section 4 (Non-Goals)"),
        (r'^#{1,2}\s+5[\.\s]+(?:Usuári|User)', "Section 5 (Users)"),
        (r'^#{1,2}\s+6[\.\s]+(?:Requisitos|Requirements)', "Section 6 (Requirements)"),
    ]
    present = 0
    for pattern, name in required_sections:
        if has_section(text, pattern):
            content = section_content(text, pattern)
            if has_content(content, 8):
                present += 1
                dim.positives.append(f"✅ {name} present and complete")
            else:
                dim.issues.append(f"⚠️ {name} present but with insufficient content")
        else:
            dim.issues.append(f"❌ {name} missing")
    score += (present / len(required_sections)) * 10

    # Requirements with IDs
    rf_count = count_rf_items(text)
    if rf_count >= 5:
        score += 8
        dim.positives.append(f"✅ {rf_count} numbered RF requirements")
    elif rf_count >= 3:
        score += 5
        dim.issues.append(f"⚠️ Only {rf_count} RF requirements — recommended minimum is 5")
    elif rf_count > 0:
        score += 2
        dim.issues.append(f"❌ Too few RF requirements ({rf_count}) — incomplete specification")
    else:
        dim.issues.append("❌ No numbered RF requirements — traceability is impossible")

    # Non-goals
    ng_count = count_nf_items(text)
    if ng_count >= 3:
        score += 7
        dim.positives.append(f"✅ {ng_count} defined non-goals")
    elif ng_count >= 1:
        score += 4
        dim.issues.append(f"⚠️ Only {ng_count} non-goal(s) — add more for clarity")
    else:
        dim.issues.append("❌ Non-goals missing — scope-creep risk")

    # Unfilled placeholders
    placeholders = count_unfilled_placeholders(text)
    if placeholders == 0:
        score += 5
        dim.positives.append("✅ No unfilled [bracket] placeholders")
    else:
        penalty = min(placeholders * 2, 10)
        score = max(0, score - penalty)
        dim.issues.append(f"❌ {placeholders} unfilled placeholder(s) — incomplete specification")

    dim.raw_score = min(score, dim.max_raw)
    return dim


def score_testabilidade(text: str) -> DimensionScore:
    dim = DimensionScore(name="Testabilidade", weight=0.25, raw_score=0, max_raw=25)
    score = 0

    # Concrete verbs — heuristic: absence of vague terms in requirements
    vague = has_vague_terms(text)
    if not vague:
        score += 10
        dim.positives.append("✅ No vague terms in requirements")
    else:
        penalty = min(len(vague) * 3, 10)
        score += max(0, 10 - penalty)
        dim.issues.append(f"⚠️ Vague terms found: {', '.join(vague[:5])}")

    # Fluxo principal (happy path)
    has_happy_path = has_section(text, r'Fluxo Principal|Happy Path|6\.2')
    if has_happy_path:
        # Verifica se tem pelo menos 3 passos numerados
        happy_content = section_content(text, r'Fluxo Principal|Happy Path|6\.2')
        steps = count_pattern(happy_content, r'^\s*\d+\.')
        if steps >= 3:
            score += 8
            dim.positives.append(f"✅ Main flow with {steps} steps")
        else:
            score += 4
            dim.issues.append("⚠️ Main flow is incomplete (< 3 steps)")
    else:
        dim.issues.append("❌ Main flow (happy path) missing — essential for testing")

    # Numeric metrics in goals
    goals_content = section_content(text, r'^#{1,2}\s+3[\.\s]+Goals')
    if has_numeric_metric(goals_content) or has_numeric_metric(text[:2000]):
        score += 7
        dim.positives.append("✅ Numeric success metrics present")
    else:
        dim.issues.append("⚠️ Success metrics lack numeric values — validation is difficult")

    dim.raw_score = min(score, dim.max_raw)
    return dim


def score_clareza(text: str) -> DimensionScore:
    dim = DimensionScore(name="Clareza", weight=0.20, raw_score=0, max_raw=20)
    score = 0

    # Open questions sinalizadas
    open_questions = count_pattern(text, r'⚠️\s*ABERTO:|OQ-\d+')
    ambiguities_hidden = count_pattern(text, r'\?.*\?')  # multiple question marks — sign of uncertainty
    if open_questions > 0:
        score += 6
        dim.positives.append(f"✅ {open_questions} explicitly marked open question(s)")
    elif ambiguities_hidden > 3:
        dim.issues.append("⚠️ Possible unmarked ambiguities (use ⚠️ OPEN: or section 14)")

    # Clear subject in requirements
    rf_section = section_content(text, r'^#{1,2}\s+6[\.\s]+(?:Requisitos|Requirements)')
    subjects = count_pattern(rf_section, r'\b(o sistema|o usuário|a plataforma|the system|the user)\b')
    rf_count = count_rf_items(rf_section)
    if rf_count > 0 and subjects >= rf_count * 0.5:
        score += 6
        dim.positives.append("✅ Requirements have a clear subject (system/user)")
    elif rf_count > 0:
        dim.issues.append("⚠️ Some requirements lack an explicit subject — who does what?")

    # Contradictions
    if has_contradictions_signal(text):
        score = max(0, score - 5)
        dim.issues.append("⚠️ Possible contradiction between requirements — review")

    # Undefined technical language (heuristic)
    vague = has_vague_terms(text)
    if not vague:
        score += 8
        dim.positives.append("✅ Precise language without vague terms")
    else:
        score += max(0, 8 - len(vague) * 2)

    dim.raw_score = min(score, dim.max_raw)
    return dim


def score_escopo(text: str) -> DimensionScore:
    dim = DimensionScore(name="Escopo", weight=0.15, raw_score=0, max_raw=15)
    score = 0

    # Useful non-goals
    ng_section = section_content(text, r'^#{1,2}\s+4[\.\s]+Non.Goals')
    ng_count = count_nf_items(text)
    if ng_count >= 3 and has_content(ng_section, 15):
        score += 7
        dim.positives.append(f"✅ clear and specific non-goals ({ng_count} items)")
    elif ng_count >= 1:
        score += 4
        dim.issues.append("⚠️ Non-goals are present but could be more specific")
    else:
        dim.issues.append("❌ Non-goals missing")

    # Mapped dependencies
    has_deps = has_section(text, r'10[\.\s]+Integra|Dependências|Dependencies')
    if has_deps:
        deps_content = section_content(text, r'10[\.\s]+Integra|Dependências')
        if has_content(deps_content, 5):
            score += 5
            dim.positives.append("✅ Dependencies and integrations mapped")
        else:
            score += 2
            dim.issues.append("⚠️ Dependency section is present but empty")
    else:
        dim.issues.append("⚠️ External dependencies are not mapped (section 10)")

    # Plano de rollout
    has_rollout = has_section(text, r'Rollout|Plano de Lançamento|13[\.\s]+')
    if has_rollout:
        score += 3
        dim.positives.append("✅ Rollout/rollback plan present")
    else:
        dim.issues.append("⚠️ Rollout/rollback plan missing (section 13)")

    dim.raw_score = min(score, dim.max_raw)
    return dim


def score_edge_cases(text: str) -> DimensionScore:
    dim = DimensionScore(name="Edge Cases", weight=0.10, raw_score=0, max_raw=10)
    score = 0

    ec_count = count_ec_items(text)
    ec_section = section_content(text, r'^#{1,2}\s+11[\.\s]+Edge|Edge Cases')

    if ec_count == 0:
        dim.issues.append("❌ CRITICAL: No edge cases defined — the implementation will not know how to handle errors")
        dim.raw_score = 0
        return dim

    if ec_count >= 4:
        score += 5
        dim.positives.append(f"✅ {ec_count} edge cases covered")
    elif ec_count >= 2:
        score += 3
        dim.issues.append(f"⚠️ Only {ec_count} edge case(s) — add external-failure cases and invalid inputs")
    else:
        score += 1
        dim.issues.append(f"❌ Only {ec_count} edge case — far from sufficient")

    # Edge cases with defined behavior
    has_behavior = count_pattern(ec_section, r'\|[^|]{5,}')
    if has_behavior >= ec_count * 2:  # pelo menos trigger + comportamento
        score += 3
        dim.positives.append("✅ Edge cases define expected behavior")
    else:
        dim.issues.append("⚠️ Edge cases lack defined behavior — they are questions, not a specification")

    # Cobertura de falhas externas
    covers_external = bool(re.search(
        r'(timeout|indisponível|fora do ar|falha|erro\s+\d{3}|retry|fallback)',
        ec_section, re.IGNORECASE
    ))
    if covers_external:
        score += 2
        dim.positives.append("✅ Covers external-dependency failures")
    else:
        dim.issues.append("⚠️ Does not cover external-system failures (timeouts, unavailability)")

    dim.raw_score = min(score, dim.max_raw)
    return dim


# ─── Final score and report ─────────────────────────────────────────────────

def classify(score: float) -> str:
    if score >= 90: return "⭐ Excellent — Ready for implementation"
    if score >= 80: return "✅ Good — Ready with minor adjustments"
    if score >= 65: return "⚠️  Adequate — Implementable with risks"
    if score >= 50: return "🔶 Incomplete — Review before implementation"
    return "❌ Insufficient — Return to interview/draft"


def build_report(spec_path: str) -> SpecReport:
    text = load_spec(spec_path)
    dims = [
        score_completude(text),
        score_testabilidade(text),
        score_clareza(text),
        score_escopo(text),
        score_edge_cases(text),
    ]
    total = sum(d.weighted_score for d in dims)

    critical_gaps = [
        issue for d in dims for issue in d.issues
        if issue.startswith("❌")
    ]
    suggestions = [
        issue for d in dims for issue in d.issues
        if issue.startswith("⚠️")
    ]

    return SpecReport(
        file=spec_path,
        total_score=round(total, 1),
        classification=classify(total),
        dimensions=dims,
        critical_gaps=critical_gaps,
        suggestions=suggestions,
        raw_text=text,
    )


# ─── Output ──────────────────────────────────────────────────────────────────

def print_report(report: SpecReport):
    print(f"\n{'='*60}")
    print(f"  SPEC QUALITY REPORT")
    print(f"  File: {report.file}")
    print(f"{'='*60}")
    print(f"\n  SCORE TOTAL: {report.total_score}/100  —  {report.classification}\n")

    print("  BREAKDOWN BY DIMENSION:")
    print(f"  {'Dimension':<20} {'Score':<10} {'Weight':<8} {'Contribution'}")
    print(f"  {'-'*50}")
    for d in report.dimensions:
        pct = round(d.raw_score / d.max_raw * 100)
        contrib = round(d.weighted_score, 1)
        print(f"  {d.name:<20} {pct:>3}%{'':<5} {int(d.weight*100):>3}%{'':<3} {contrib:>5}/pt")

    if report.critical_gaps:
        print(f"\n  ❌ CRITICAL GAPS ({len(report.critical_gaps)}):")
        for g in report.critical_gaps:
            print(f"     {g}")

    if report.suggestions:
        print(f"\n  ⚠️  RECOMMENDED IMPROVEMENTS ({len(report.suggestions)}):")
        for s in report.suggestions[:8]:  # top 8
            print(f"     {s}")
        if len(report.suggestions) > 8:
            print(f"     ... and {len(report.suggestions) - 8} more suggestion(s)")

    positives = [p for d in report.dimensions for p in d.positives]
    if positives:
        print(f"\n  ✅ STRENGTHS:")
        for p in positives[:5]:
            print(f"     {p}")

    print(f"\n{'='*60}\n")


def print_json(report: SpecReport):
    output = {
        "file": report.file,
        "total_score": report.total_score,
        "classification": report.classification,
        "dimensions": [
            {
                "name": d.name,
                "score_pct": round(d.raw_score / d.max_raw * 100),
                "weighted_contribution": round(d.weighted_score, 1),
                "issues": d.issues,
                "positives": d.positives,
            }
            for d in report.dimensions
        ],
        "critical_gaps": report.critical_gaps,
        "suggestions": report.suggestions,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))


# ─── Entry point ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Evaluates the quality of a feature specification (0–100)"
    )
    parser.add_argument("--spec", required=True, help="Path to the specification .md file")
    parser.add_argument("--json", action="store_true", help="Output in JSON format")

    args = parser.parse_args()
    report = build_report(args.spec)

    if args.json:
        print_json(report)
    else:
        print_report(report)

    # Non-zero exit code when score < 65 (for CI/CD use)
    sys.exit(0 if report.total_score >= 65 else 1)


if __name__ == "__main__":
    main()
