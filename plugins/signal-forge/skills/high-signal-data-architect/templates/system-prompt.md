# Template: system-prompt

For system prompts, agent instructions, custom GPT / project instructions, persona definitions, prompt libraries and `CLAUDE.md`-style rule files.

## Pick this template when

- The source speaks to a model or agent ("You are…", "Always…", "Never…", "Respond in…").
- It defines a persona, tools the agent may call, or an output format the agent must produce.

## Read the source for

| Look for | Becomes |
|---|---|
| Identity, role, audience, tone | one `role` card |
| Each named task or mode the agent performs ("When the user asks for X, do Y") | one `procedure` card per task |
| Output templates, JSON shapes, required sections | one `schema` card per distinct format |
| Hard constraints ("never", "must", limits, banned topics) | `policy` cards, grouped by topic (safety, formatting, scope) |
| Tool or function definitions and when to call them | one `procedure` card per tool, Inputs = the tool's parameters |
| Refusal, error, escalation or "if unsure" instructions | `fallback` cards |
| Contradictions or undefined terms | `question` cards |

## Split rules

- One `role` card per persona. If the source has one persona, there is exactly one.
- A rule that applies to every task goes in a `policy` card, and is ALSO copied into each `procedure` card's Rules where it changes that task's behavior (standalone rule 2).
- Few-shot examples stay verbatim inside the card they illustrate, under Output, with their locus.

## Locus convention

Prompts rarely have headings. Number paragraphs and bullet blocks `@FragA:P1…`. For XML-tagged prompts use the tag: `@FragA:<output_format>`.

## Example

Source fragment A: "You are a support agent for Acme. Reply in under 120 words. If a customer asks for a refund over $500, hand off to a human."

Cards (in source order):

- `A-role-support-agent` · role · Rules: "MUST reply in under 120 words @FragA:P1"
- `A-fallback-refund-over-500` · fallback · When to run: "customer asks for a refund over $500 @FragA:P1"; Procedure: "1. Hand off to a human. @FragA:P1"; Rules repeats the 120-word limit (it still applies to the hand-off message)

## Edge cases

- A prompt that is mostly examples: extract the format as a `schema` card and keep 1–3 examples verbatim inside it.
- Variables like `{{user_name}}` become card Inputs with type `text`.
