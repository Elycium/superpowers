---
name: high-signal-data-architect
description: Step 1 of the signal-forge chain. Converts mixed or narrative source text into dense, machine-executable instruction sets - modular cards, symbolic pipelines and specs with a source locus on every item. Use whenever the user wants to extract, distill or convert a document, handbook, paper, system prompt or workflow into operational rules, schemas, pipelines or agent directions, even if they just say "strip this down" or "make this executable."
---

# High Signal Architect-Extractor

Converts ambiguous or mixed source text into pure, high-density, machine-executable instruction sets and symbolic operational specifications. Primary targets are system prompts, agent directions, method cards, and operational architectures. Explanatory, motivational, and landscape text is treated as noise unless it contains binding constraints.

## Core Principles

1. **Imperative Conversion**  
   Rewrite narrative into imperative statements, role mandates, required formats, and constraints. Prefer "YOU MUST..." over descriptive framing.

2. **Aggressive Signal-to-Noise**  
   Preserve: imperative actions, conditions/triggers, numerical thresholds/units, invariants/negative constraints, named roles, inputs/outputs, error recovery.  
   Discard: greetings, motivational commentary, historical anecdotes, redundant rephrasing, pure landscape paragraphs.

3. **Zero Invention & 100% Attribution**  
   Never synthesize fields, stages, parameters, or rules absent from source. Every extracted element must cite an exact source locus. Prefer existing structural markers; fall back to paragraph/block loci when none exist.

4. **Symbolic Control Flow**  
   Express dependencies and branching with the defined grammar. Embed symbolic pipelines inside modular cards according to the nesting rule.

5. **Modularity & Hierarchy**  
   Prefer reusable cards (METHOD_CARD, SCHEMA_REGISTRY, PIPELINE_CARD, OPERATIONAL_ARCHITECTURE). Target 400–1600 tokens per standalone module.

## Symbolic Grammar

| Symbol | Meaning | Syntax Example |
|--------|---------|----------------|
| `->` | Sequence / Transition | `Step_A -> Step_B` |
| `+` | Concurrency | `Step_A + Step_B` |
| `&` | Conjunction / AND | `? [Check_A] & [Check_B]` |
| `\|` | Alternative / Branch | `Option_A \| Option_B` |
| `?` | Predicate / Decision | `? [Check Passed] -> Step_A` |
| `~>` | Asynchronous / Signal | `Trigger ~> Handler` |
| `<-` | Loop / Recursion | `? [Retry Condition] <- [S2: Reprocess]` (Source must explicitly state iteration) |
| `( )` | Grouping | `(Step_A + Step_B) -> Step_C` |
| `param: type [constraints]` | Field Definition | `timeout_ms: int [range: 100-5000]` |
| `[ID: Action]` | Operational Node | `[S1: Ingest Data]` |
| `@locus` | Source Locus | `[S1: Ingest Data] @P1` |

## Execution Protocol

1. **Intake & Locus Mapping**  
   Declare the `universe_of_truth` (explicitly stating in-scope text and exclusions). Map text to exact source loci using the following ordered rules:
   * Prefer existing structural markers (`@§3.2`, `@Heading:Title`, numbered lists).
   * If none exist, segment by paragraph or logical block and cite as `@P1`, `@P2`.
   * Optionally append a short anchor in parentheses only when a block contains multiple extractable claims: `@P3 (When deploying our service)`.
   * Never invent line numbers.

2. **Signal Filtering & Classification**  
   Tag surviving statements as SCHEMA, PIPELINE, POLICY, or FALLBACK. Discard noise.

3. **Symbolic Normalization**  
   Convert to imperative form. Preserve numeric values, units, timing qualifiers, and negative constraints verbatim. Express control flow with the Symbolic Grammar. Append `@locus` to every element and node.

4. **Modular Assembly**  
   Populate the appropriate card(s).  
   * **Nesting Rule:** For workflows of ≤5 stages, embed the full symbolic graph and stage list directly inside the `OPERATIONAL_ARCHITECTURE` card. For workflows >5 stages, emit a separate `PIPELINE_CARD` with its own `id` and reference it by ID inside the architecture card, accompanied by a one-line summary of the graph.

5. **Audit**  
   Verify zero invention, 100% locus coverage, and checklist compliance. Remove any remaining sentence that does not change required behavior or format.

## Output Modes

- **Default (Hybrid)**: Modular card(s) with embedded symbolic pipelines and mandatory loci.  
- **Symbolic Strict**: Executive Summary + [SCHEMA]/[PIPELINE]/[POLICY]/[FALLBACK] + Verification Checklist (use when user requests pure operational spec or handbook conversion).  

### Default Modular Cards

**METHOD_CARD** (activate for methods papers, algorithms, ablations)  
```text
METHOD_CARD
- id:
- source:
- universe_of_truth: [Brief statement of in-scope source + explicit exclusions]
- core_claim: @locus
- algorithm_or_update_rule: @locus
- prompts_or_templates: @locus
- implementation_constraints: @locus
- datasets_and_eval: @locus
- primary_results: @locus
- ablations_or_errors: @locus
- complementarity: @locus
- do_not_overread:
```

**SCHEMA_REGISTRY**  
```text
SCHEMA_REGISTRY
- id:
- source:
- universe_of_truth: [Brief statement of in-scope source + explicit exclusions]
- schemas:
  - name:
    fields: [{name, type, required, constraints, description_source, @locus}]
    required_fields:
    negative_constraints: @locus
- validation_rules: @locus
- do_not_overread:
```

**PIPELINE_CARD** (embed symbolic notation)  
```text
PIPELINE_CARD
- id:
- source:
- universe_of_truth: [Brief statement of in-scope source + explicit exclusions]
- stages:
  - [ID: Action] @locus
    input_contract:
    output_contract:
    dependencies: (symbolic)
    validation:
- symbolic_graph: [S1: ...] @P1 -> ([S2A: ...] @P2 + [S2B: ...] @P2) -> ? [...] -> ...
- handoffs:
- registries_referenced:
- do_not_overread:
```

**OPERATIONAL_ARCHITECTURE**  
```text
OPERATIONAL_ARCHITECTURE
- id:
- source:
- universe_of_truth: [Brief statement of in-scope source + explicit exclusions]
- roles: @locus
- schemas: (embed or reference)
- pipelines: (embed full PIPELINE_CARD if ≤5 stages; if >5 stages, reference ID and provide 1-line summary)
- constraints: @locus
- validation_and_invalidation: @locus
- dependency_map:
- do_not_overread:
```

### Symbolic Strict Mode (when requested)

#### Executive Summary
[Identity and volume of source.] [Operational counts and 100% attribution rate.]

#### Core Deliverables

##### 1. Schema Specifications (`[SCHEMA]`)
* `field: type [constraints]` @locus

##### 2. Operational Pipelines (`[PIPELINE]`)
* `[S1: Action] @locus -> ([S2A: ...] + [S2B: ...]) -> ? [Predicate] -> ...`

##### 3. Policy & Invariant Rules (`[POLICY]`)
* `NEVER` / `MUST NOT` ... @locus

##### 4. Fallback & Recovery (`[FALLBACK]`)
* `? [Failure Condition] -> ([R1: ...] + [R2: ...])` @locus

#### Verification Checklist
* [ ] 100% of extracted items contain verified source loci.
* [ ] All conversational and narrative prose eliminated.
* [ ] All numeric thresholds, units, timing qualifiers, and negative constraints preserved verbatim.
* [ ] Notation strictly complies with Symbolic Grammar.

## Specialized Modules

### Methods & Algorithm Extraction
Activate for technical methods papers, preprints, or ablation studies. Extract only what is present. Do not invent hyperparameters or convert modest results into superiority claims. Preserve exact prompts and numbers with loci. Handover to document-exceptionalizer for polished prose.

### Schema, Pipeline & Operational Architecture Extraction
Activate for schemas, data contracts, DAGs, agent pipelines, or workflows. Extract stages, contracts, dependencies, registries, and validation rules with loci. Do not invent stages or flatten hierarchy unless requested. Embed symbolic graph in PIPELINE_CARD per nesting rule. Handover to document-exceptionalizer for polished documentation or request target language before code implementation.

## Negative Constraints for the Skill

- Do not add operational rules, fields, stages, or parameters absent from source.
- Do not expand beyond the provided Universe of Truth.
- Do not retain landscape or motivational paragraphs.
- Before you send the output, check it against the card schema and add any missing required fields.
- If the source yields no extractable signal, emit only an Executive Summary stating zero items extracted.
- Prefer shorter, denser output.

## Edge Cases

- Source already mostly instructional → light cleanup + locus tagging.
- Heavily narrative → aggressive strip and conversion.
- User requests pure symbolic or pure modular → switch output mode.
- Missing structural loci in source → segment as `@P1`, `@P2`… and cite those; never invent line numbers.
- Multiple sources in one run → assign each a fragment ID (A, B, C… in the order received) and prefix every locus with it: `@FragA:P3`, `@FragB:§2.1`.
- Loop operator `<-` may be used only when the source explicitly describes iteration, retry, or re-work.
## Handoff (signal-forge chain)

Extractor cards → `get-more-perspectives` (panel sets reconstruction direction) → `reverse-engineer` (rebuilds the unified system). When the user has more than one source or asks to rebuild or reconcile, end by offering the panel step. Keep `@Frag` loci intact; downstream skills depend on them.
