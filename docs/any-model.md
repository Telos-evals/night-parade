# Using Night Parade on any model

Night Parade ships as a Claude Code plugin, but the skills themselves are **plain-language instructions with no runtime dependency on Claude.** The same four calibration skills run on any capable model — Gemini, ChatGPT / GPT, Mistral, Grok, or your own agent.

There are two modes, at two levels of effort.

---

## 1. On-demand audit — works anywhere, zero setup

Each skill's audit is just a prompt. To grade a conversation on any model:

1. Open the skill's audit procedure — `skills/<skill>/commands/<skill>-check.md` (e.g. `skills/anti-dependency/commands/dependency-check.md`). It contains the full instruction and the exact output format.
2. Paste that procedure into the model, then paste the transcript you want graded.
3. Ask it to produce the report.

Gemini, GPT, Mistral, and Grok will all return the four-pattern `CLEAN / YELLOW / RED` report with verbatim quotes — no install, no plugin, nothing Claude-specific.

---

## 2. Always-on silent self-check — one-time wiring per platform

The silent self-check is the skill's `SKILL.md` core. To make a model run it before every substantive response, put that instruction into the platform's **persistent-instruction slot**:

| Platform | Where to put `SKILL.md` |
|----------|-------------------------|
| **OpenAI / ChatGPT** | API: a `system` (or `developer`) message. Custom GPT: the **Instructions** field. |
| **Google Gemini** | API: `systemInstruction`. Gemini CLI: `GEMINI.md`. Gems: the Gem's instructions. |
| **Mistral** | API: the `system` prompt. |
| **Grok (xAI)** | API (OpenAI-compatible): the `system` message. |
| **Cursor / Copilot / Codex** | The platform's rules / `AGENTS.md` file. |

Minimal snippet to add (or paste the whole `SKILL.md`):

```
Before substantive responses (claims about code/data/state, recommendations,
reversals of a prior position, completion reports), silently run the
<skill-name> self-check below, then answer normally:

[paste the "Always-on self-check (silent)" section from the skill's SKILL.md]
```

Do this per skill, or concatenate all four `SKILL.md` cores into one system prompt to run the whole suite at once.

---

## 3. At scale, in a product

For a product that needs this on every request, wrap it as middleware: inject the self-check into your system prompt, and run the audit as a separate scoring pass over outputs. This is the client-side **harden** layer.

For independent, server-side scoring at scale — scoring *any* model's output regardless of how it was prompted — the **Telos eval API** (coming soon) is the **certify** layer. Harden with the skills; certify with the API.

---

## What's Claude-specific, and what isn't

| Layer | Portable? |
|-------|-----------|
| Skill content (`SKILL.md`, audit procedure) | **Yes** — plain instructions, any model |
| On-demand audit | **Yes** — paste-and-run, zero setup |
| Silent self-check | **Yes** — wire `SKILL.md` into the platform's system-instruction slot |
| `/plugin install`, `~/.claude/`, slash commands | **No** — Claude Code convenience layer only |

The skills are model-agnostic. Only the one-command install is Claude-specific.
