# Template: meeting-notes

For meeting notes, call transcripts, decision logs, Slack or email threads, retros, whiteboard photos and brainstorm dumps.

## Pick this template when

- The source records people talking: names, "we agreed", "@alex will", "TODO", dates, open questions.
- It has no stable structure, or a loose one (agenda, notes, action items).

## Read the source for

| Look for | Becomes |
|---|---|
| Each decision ("agreed", "decided", "going with") | one `decision` card: Purpose = the decision, Rules = what it now binds, rationale if stated |
| Each action item (who + what, maybe when) | one `action` card: Rules carries owner and due date verbatim if given |
| A process the group described or agreed to follow | `procedure` card |
| Requirements or constraints stated as fact | `policy` cards |
| Unresolved questions, disagreements, "parking lot" | `question` cards (never answer them) |

## Split rules

- One decision per card, one action per card. A bullet with two owners is two cards.
- A decision that is later reversed in the same source: card the final state and note the reversal, with both loci, under Do not overread.
- Opinions that were not agreed are not decisions. If they matter, they become `question` cards.
- Owner names and dates are copied exactly; do not convert "next Friday" into a date.

## Locus convention

Timestamps for transcripts (`@FragA:t=00:14:32`), speaker turns (`@FragA:turn 12`), otherwise paragraphs or bullets (`@FragA:P7`). For a photo of a whiteboard, number visual blocks top-left to bottom-right (`@FragC:P1`).

## Example

Source fragment D: "Decided: ship the beta to 10 customers first. Sam to draft the invite email by Thu. Still unclear who owns support during beta."

- `D-decision-beta-10-customers` · Purpose: "Ship the beta to 10 customers first. @FragD:P1"
- `D-action-draft-invite-email` · Rules: "Owner: Sam. Due: Thu. @FragD:P1" · Output: "A draft invite email."
- `D-question-beta-support-owner` · Purpose: "Who owns support during the beta? @FragD:P1"

## Edge cases

- Transcripts with crosstalk: attribute only what the source attributes; otherwise "Owner: Not specified in source."
- Duplicate action items across notes: keep the first, add the second locus to it.
