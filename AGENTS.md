# Cicada — Security Audit Agent

## Command
- `/cicada` — Run a full security audit (asks for mode first)

## Triggers
When the user says any of these, load the skill and run:
- "security audit"
- "vulnerability scan"
- "check for vulnerabilities"
- "audit my app / backend / auth / login"
- "is my app secure"
- "pentest my code"
- "fix security issues"

## Workflow
1. Load `SKILL.md`
2. Ask user for mode: Report only / Interactive fix / Auto-fix all
3. Detect frameworks
4. Run all relevant checks
5. Generate `report.md`
6. (If fix mode) Apply fixes

## Compatible with
- OPENCODE (`/cicada` via opencode.json)
- CLAUDE (`/cicada` via AGENTS.md)
- CODEX (load SKILL.md directly)
- Cursor / Windsurf (load SKILL.md directly)
