# Template: research-paper

For papers, preprints, technical reports, whitepapers, benchmark write-ups and methods sections.

## Pick this template when

- The source has an abstract, a method, experiments or results (the usual introduction, methods, results, discussion layout).
- It proposes a technique, algorithm, prompt strategy or evaluation.

## Read the source for

| Look for | Becomes |
|---|---|
| Each method, algorithm or technique you could re-run | one `method` card: Procedure = the algorithm steps, Rules = hyperparameters and settings verbatim |
| Prompts, templates or pseudo-code | inside the matching `method` card, verbatim, under Procedure or Output |
| Datasets, metrics and how results were measured | one `evaluation` card per evaluation setup: Output = metric + the reported number + its locus |
| Stated limits, assumptions, failure cases | `policy` cards (when to not use the method) or `fallback` cards |
| Claims that are not supported by the paper's own results, or open problems | `question` cards |

## Split rules

- Results are not procedures. A reported number goes in an `evaluation` card's Output as "Reported: 71.2% on X @FragA:Table 3". It is never phrased as a guarantee.
- Ablations: one `evaluation` card per ablation table, unless the source treats them as one study.
- Background and related-work sections are noise unless they define a term the method uses. Copy that definition into the method card.

## Locus convention

Section, equation, algorithm, table and figure numbers: `@FragA:§3.2`, `@FragA:Eq. 4`, `@FragA:Alg. 1 line 5`, `@FragA:Table 2`.

## Example

Source fragment C, §3: "We sample k=5 reasoning paths at temperature 0.7 and return the majority answer." Table 2: "GSM8K: 74.4%".

- `C-method-majority-vote-sampling` · Procedure: "1. Sample 5 reasoning paths at temperature 0.7. @FragC:§3  2. Return the most common final answer. @FragC:§3" · Rules: "k = 5; temperature = 0.7 @FragC:§3"
- `C-evaluation-gsm8k` · Output: "Reported accuracy 74.4% @FragC:Table 2" · Do not overread: "The paper does not report results for other k values in §3."

## Edge cases

- Do not convert modest gains into superiority claims (inherited from the extractor's methods module).
- Missing hyperparameters stay `Not specified in source.`
