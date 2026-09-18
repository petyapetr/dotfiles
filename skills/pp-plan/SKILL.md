---
name: pp-plan
description: Write a short plan the user approves before building. Use after context of the change is explored and confirmed, or when the user asks for a plan and the idea is already clear.
disable-model-invocation: true
---

# /pp-plan

Turn confirmed understanding into a short written plan. The user approves it before any building starts.

## When to use

- After context is captured, confirmed. and summarized. It can be a history of chat we are in, or explicitly provided artifact.
- The user asks for a plan and the idea is already clear.

## Steps

1. Use the summary as the basis for the plan. Do not reopen settled questions unless new evidence conflicts with it.
2. Write or update the plan. Use the format in [PLAN-FORMAT.md](./PLAN-FORMAT.md).
3. Use exactly four sections as in the format. No other headings.
4. Show the plan to the user.
5. **Stop and ask** for approval. Do not implement until they approve.
6. If any step feels big, split it or cut it. Do not nest sub-steps.

## Must NOT

- Exceed one page. If longer, split the task into multiple plans.
- Add headings beyond the four sections.
- Start implementing. The plan ends at approval.

## Example interaction

> Agent: *(writes 0000-slug.md, shows it)*
>
> "Here is the plan. Four sections: what we're doing, steps, what we're not doing, how we'll know it works. Approve this before I build?"
>
> User: "Approved."
>
> Agent: *(stops. User can invoke `/pp-build` next.)