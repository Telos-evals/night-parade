# Night Parade — Bundle Design

**Date:** 2026-06-07
**Status:** Design — pending review
**Owner:** Ryan Wilson (Telos)
**Repo (planned):** `github.com/Telos-evals/night-parade`

---

## 1. What this is

Night Parade is the calibration-skill family — a *hyakki yagyō*, one yōkai per failure mode — bundled into a single installable suite. Four skills exist today as independent, MIT-licensed repos:

- **anti-sycophancy** (Hannya) — capitulation, false success, hedging, praise/framing-mirror
- **anti-hallucination** (kitsune-bi) — ungrounded factual claims
- **anti-fictional-frame** (tanuki) — framings that lower rigor on the underlying content
- **anti-dependency** (Jorōgumo) — sentience-adjacency, affect-mirroring, reliance-cultivation, engagement-baiting

Today each installs separately. This project creates one repo, `night-parade`, that installs all four in a single step — as a **Claude Code plugin** (native, discoverable) and via a **portable installer** (any Claude Code setup, no plugin system required). It is the brand home for the suite.

## 2. Strategy: the suite is the funnel, not the product

Night Parade stays **free and open (MIT)**. The reasoning is deliberate, not default:

- The four components are already public under MIT; a paid bundle has no enforcement surface (it is arbitraged by installing the four free repos).
- Open distribution is the credibility and adoption engine. The defensible asset is the evaluation corpus and the reproducible red-team suites — not the skill text. Paywalling the suite would undercut the moat to protect something that isn't the moat.
- The suite is the top-of-funnel for a **separate, hosted commercial layer** (model-agnostic ethics **evaluation / certification** — "harden with the skills, certify with the API"). That layer is where revenue lives. It is **out of scope here** and is surfaced only as a *"coming soon"* signal in the README — no pricing, no available-now language.

Revisit an open-core *"Pro"* tier (team config, telemetry, managed updates, SLAs) only after there is an install base **and** a genuinely gateable enterprise feature. Not at launch.

## 3. Architecture decisions

| Question | Decision |
|---|---|
| Artifact | One public repo that is **both** a Claude Code plugin **and** a single-entry marketplace, plus a portable installer. |
| Skills inclusion | **Git submodules** — each `skills/<name>/` is a submodule pointing at the standalone skill repo (whose root holds `SKILL.md`). The four repos stay canonical and keep shipping independently; the bundle pins SHAs. No vendored copies (drift), no monorepo-absorption (breaks independence). |
| Plugin skill discovery | Claude Code auto-discovers `skills/<name>/SKILL.md`. Skills become `/night-parade:<skill>`. |
| Plugin command discovery | Each skill's slash command lives in the submodule's own `commands/` dir, which is **not** auto-discovered. The plugin manifest maps them explicitly via the `commands` array, surfacing `/night-parade:<command>`. |
| Marketplace | `.claude-plugin/marketplace.json` in the same repo, one plugin entry sourced from this repo. `/plugin marketplace add Telos-evals/night-parade` → `/plugin install night-parade@night-parade`. |
| Portability | A root `install.sh` installs all four cores into `~/.claude/` without the plugin system — keeps the vendor-neutral / non-CC story honest. |
| Versioning | Omit `version` in `plugin.json` (every commit is an update) for now; pin later if release cadence is wanted. |
| License | MIT, matching the four skills. |

## 4. Repo structure

```
night-parade/
├── .claude-plugin/
│   ├── plugin.json              # plugin manifest
│   └── marketplace.json         # single-entry marketplace pointing at this repo
├── skills/                      # four git submodules (each repo root has SKILL.md + commands/)
│   ├── anti-sycophancy/         → github.com/Telos-evals/anti-sycophancy
│   ├── anti-hallucination/      → github.com/Telos-evals/anti-hallucination
│   ├── anti-fictional-frame/    → github.com/Telos-evals/anti-fictional-frame
│   └── anti-dependency/         → github.com/Telos-evals/anti-dependency
├── .gitmodules
├── install.sh                   # portable installer (copies 4 cores into ~/.claude/)
├── README.md                    # brand home, two install paths, "API coming soon"
├── LICENSE                      # MIT
└── docs/
    └── design.md                # this doc
```

## 5. Component specs

### 5.1 `plugin.json` (`.claude-plugin/plugin.json`)

```json
{
  "name": "night-parade",
  "description": "Telos's calibration skill suite — catches sycophancy, hallucination, framing-drift, and dependency-cultivation in an AI agent's own turns.",
  "author": { "name": "Ryan Wilson", "url": "https://github.com/rbwilson" },
  "homepage": "https://github.com/Telos-evals/night-parade",
  "repository": "https://github.com/Telos-evals/night-parade",
  "license": "MIT",
  "keywords": ["calibration", "evaluation", "ai-safety", "skills"],
  "commands": [
    "./skills/anti-sycophancy/commands/",
    "./skills/anti-hallucination/commands/",
    "./skills/anti-fictional-frame/commands/",
    "./skills/anti-dependency/commands/"
  ]
}
```

- Skills are auto-discovered from `skills/` (the default path) — no `skills` field needed, but it may be set explicitly for clarity.
- The `commands` array is required because the command `.md` files live inside submodule `commands/` dirs, which are not auto-discovered.
- `version` deliberately omitted (commit-SHA versioning) for launch.

### 5.2 `marketplace.json` (`.claude-plugin/marketplace.json`)

```json
{
  "name": "night-parade",
  "owner": { "name": "Telos", "url": "https://github.com/Telos-evals" },
  "description": "The Night Parade calibration skill suite.",
  "plugins": [
    {
      "name": "night-parade",
      "source": { "source": "github", "repo": "Telos-evals/night-parade" },
      "description": "All four calibration skills, installed together.",
      "license": "MIT",
      "category": "ai-safety"
    }
  ]
}
```

The repo is both the marketplace and the plugin it lists (self-referential `source`). Verified during the build by adding the marketplace from a local clone and installing.

### 5.3 Submodules (`.gitmodules`)

```
[submodule "skills/anti-sycophancy"]
	path = skills/anti-sycophancy
	url = https://github.com/Telos-evals/anti-sycophancy.git
[submodule "skills/anti-hallucination"]
	path = skills/anti-hallucination
	url = https://github.com/Telos-evals/anti-hallucination.git
[submodule "skills/anti-fictional-frame"]
	path = skills/anti-fictional-frame
	url = https://github.com/Telos-evals/anti-fictional-frame.git
[submodule "skills/anti-dependency"]
	path = skills/anti-dependency
	url = https://github.com/Telos-evals/anti-dependency.git
```

Each submodule is added with HTTPS URLs (the org's repos are public; HTTPS avoids SSH-key friction, matching how the standalone repos were published).

### 5.4 `install.sh` (portable path)

Idempotent. For each of the four submodule dirs under `skills/`, copy `SKILL.md` (+ any supporting `docs/`) to `~/.claude/skills/<name>/` and each `commands/*.md` to `~/.claude/commands/`. Mirrors the per-skill installers, batched. Final echo points at the optional CLAUDE.md self-check snippets and notes the plugin alternative.

Guard: if submodules are uninitialized (fresh clone without `--recurse-submodules`), the script runs `git submodule update --init --recursive` first, or errors with that instruction.

### 5.5 README (brand home)

- Hyakki-yagyō framing; the four yōkai with one-line descriptions and links to their repos.
- **Two install paths:** (1) plugin — `/plugin marketplace add Telos-evals/night-parade` then `/plugin install night-parade@night-parade`; (2) portable — `git clone --recurse-submodules … && ./install.sh`.
- **"Verify it yourself"** — links to all four red-team suites (the credibility line).
- **"Night Parade API — hosted ethics evaluation, coming soon."** No pricing, no available-now language.
- Per-skill silent-self-check note (optional CLAUDE.md snippets), consistent with the standalone repos.

## 6. Side artifacts (NOT in this public repo)

1. **GTM alignment note** — internal, lives in the Dropbox workspace (it references commercial/roadmap and NDA-adjacent material). One page: Night Parade as the go-to-market front-end for the commercial eval API; the "harden (client-side skills) + certify (server-side eval)" two-loci framing; the wrapped-product locus lesson stated abstractly. Public design.md (this file) deliberately omits all of it.
2. **Linear issue** under "Telos API & Platform": the distribution gap — the plugin/marketplace bundle as the free funnel that feeds the commercial layer's demand gate. Drafted and shown before creation.

## 7. Testing / verification

- **Plugin loads:** add the marketplace from a local clone, install the plugin, confirm all four skills appear as `/night-parade:<skill>` and all four commands as `/night-parade:<command>` in a fresh session.
- **Submodules resolve:** fresh `git clone --recurse-submodules` populates all four `skills/<name>/SKILL.md`.
- **Portable installer:** on a clean `~/.claude/`, `install.sh` places four skills + four commands; idempotent on re-run; bash `-n` syntax-clean.
- **No drift:** submodule SHAs point at the current `main` of each skill repo at bundle-build time.

## 8. Out of scope

- The Layer-2 commercial eval/certification API (tracked separately; gated; not front-run here).
- Any pricing, billing, auth, or tenancy.
- Marketing imagery beyond a single optional hyakki-yagyō header image.
- Monorepo-absorption or retirement of the four standalone repos.

## 9. Open questions

1. **Header image** — generate/commission a hyakki-yagyō banner, or ship text-only at launch? (Cosmetic; default text-only, add later.)
2. **`skills` field explicitness** — set `"skills": "./skills/"` in the manifest, or rely on auto-discovery of the default path? (Default: rely on auto-discovery; add explicitly only if a load issue surfaces in testing.)

## 10. Next steps

1. Review this spec.
2. Implementation plan (writing-plans): scaffold repo, add four submodules, write `plugin.json` / `marketplace.json` / `install.sh` / README / LICENSE, verify plugin + portable installs, publish public, write the internal alignment note, file the Linear issue.
