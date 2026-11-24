# Template: api-spec

For API references, OpenAPI/Swagger files, SDK docs, data contracts, database schemas, event and webhook specs, config file references.

## Pick this template when

- The source defines endpoints, methods, fields, types, status codes or message formats.
- It reads like a reference: tables of parameters, request/response examples.

## Read the source for

| Look for | Becomes |
|---|---|
| Each object, model, table, event payload | one `schema` card (field table) |
| Each endpoint or operation | one `procedure` card: Inputs = path/query/body params, Procedure = how to call it, Output = the success response shape |
| Multi-call flows (auth, pagination, upload-then-process) | one `procedure` card per flow, with each call as a step |
| Auth, rate limits, versioning, idempotency, size limits | `policy` cards |
| Error codes, retries, backoff | `fallback` cards |
| "Deprecated", "TBD", undocumented fields | `question` cards |

## Split rules

- A procedure card that sends or returns an object copies that object's field table into its Output (standalone rule 2), rather than pointing at the schema card.
- Keep field names, casing, types, enum values, defaults and limits exactly as written.
- Example requests and responses stay verbatim in a fenced block, with their locus.

## Field table format (schema cards and procedure Outputs)

| name | type | required | constraints | locus |
|---|---|---|---|---|
| `amount` | integer | yes | cents, > 0 | @FragA:§Charges.amount |

## Locus convention

OpenAPI: the JSON path, `@FragA:paths./charges.post`. Docs: heading + parameter name, `@FragA:§Create a charge.amount`.

## Example

Source fragment A: "POST /charges — amount (integer, required, in cents), currency (string, ISO 4217). Returns 201 with a Charge. 429 means rate limited; retry after the Retry-After header."

- `A-procedure-create-charge` · Inputs: amount, currency · Output: 201 + Charge · Rules: "amount in cents @FragA:P1"
- `A-fallback-rate-limited` · When to run: "response is 429 @FragA:P1" · Procedure: "1. Wait the number of seconds in Retry-After, then retry. @FragA:P1"

## Edge cases

- A field described only by an example value: type it from the example and say so in `Do not overread`.
- Huge specs: one card per resource, and list skipped resources in the Extract summary rather than dropping them silently.
