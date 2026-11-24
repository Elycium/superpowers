# Template: sop-handbook

For standard operating procedures, handbooks, runbooks, playbooks, checklists, policy manuals, onboarding guides and how-to docs written for people.

## Pick this template when

- The source tells a person how to do a job: numbered steps, roles ("the on-call engineer"), approvals, escalation paths.
- It has sections like Purpose, Scope, Responsibilities, Procedure, Exceptions (the usual SOP layout).

## Read the source for

| Look for | Becomes |
|---|---|
| Each named process or numbered procedure | one `procedure` card |
| Who does what (responsibilities, RACI, approvers) | copied into each `procedure` card's Rules; a `role` card only if a role has duties across several procedures |
| Forms, records, tickets, log entries to fill in | `schema` cards |
| Standing rules (compliance, SLAs, limits, "never") | `policy` cards, grouped by topic |
| Escalation, exceptions, "if X goes wrong" | `fallback` cards |
| Checklists used to confirm work | the `Self-check` of the matching procedure card, and an `evaluation` card if the source treats it as a standalone audit |

## Split rules

- One process = one card, even if it is long. Split only where the source starts a new named process.
- A sub-procedure that several processes call ("verify identity") is copied into each caller in full. It also gets its own card if the source gives it its own heading.
- Time limits, amounts and thresholds stay verbatim with units ("within 2 business days", "over $500").

## Locus convention

Use the source's section numbers and step numbers: `@FragA:§4.2 step 3`. Without them, `@FragA:Heading:Refunds` then paragraph `P2`.

## Example

Source fragment B, §4.2 "Refunds": "1. Check the order is under 30 days old. 2. If it is, refund to the original card. 3. Otherwise, offer store credit. Escalate disputes to the team lead."

- `B-procedure-refunds` · Inputs: order date, payment method · Procedure: `? [order age < 30 days] @FragB:§4.2 step 1 -> [Refund to original card] @FragB:§4.2 step 2 | [Offer store credit] @FragB:§4.2 step 3`
- `B-fallback-refund-dispute` · When to run: "customer disputes the refund outcome @FragB:§4.2" · Procedure: "1. Escalate to the team lead. @FragB:§4.2"

## Edge cases

- Narrative "why we do this" paragraphs are noise unless they state a constraint.
- If two sections give different values for the same threshold, keep both in their own cards and add a `question` card naming the clash.
