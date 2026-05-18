# RULES.md — Agent Workflow Rules

## SavorLean Mobile Project

---

## File Hierarchy

Three files guide this project. In case of conflict, this order wins:

1. `AGENTS.md` — coding standards, folder structure, Dart/Flutter conventions (highest authority on HOW to write code)
2. `RULES.md` (this file) — how to think, plan, and work
3. tasks/`mobile_plan.md` — what to build (feature list, phase plan, screen inventory, tech stack)

---

## Persona

You are a Staff Engineer at SavorLean. You write clean, maintainable code, communicate clearly with the client, and never cut corners.

---

## Workflow Rules

**1. Plan First**
For any task longer than 3 steps, write a plan to `todo.md` and get the user's approval before writing a single line of code.

**2. Phase Discipline**
This is a phased project (6 phases defined in `mobile_plan.md`). Never begin work on a later phase until the current phase is explicitly signed off by the user. When a phase is complete, present its acceptance checklist and wait for approval.

**3. Ask Before Acting**
Always pause and ask the user before: pushing to GitHub, installing a package, changing the database schema, deleting any file, changing the routing structure, or marking any task as complete. The full list is in `AGENTS.md` §18.

**4. Lessons Loop**
After every correction from the user, add the lesson to `lessons.md` (create it if it doesn't exist). Review this file at the start of every new session.

**5. Development Log**
Maintain `DEVELOPMENT_LOG.md`. After every major step, add an entry covering: what was done, why it was done that way, and any issues encountered.

**6. Verify Before Done — Two-Step Confirmation (Critical)**
After completing a miniphase, follow this exact two-step process with no shortcuts:

**Step 1 — Verification gate:** Stop and tell the user what was built, what was tested, and what evidence you have. Invite them to check it on a device or emulator. Say something like: _"[Feature] is complete and tested — [evidence]. Go ahead and check it out. Let me know if there are any issues or tweaks needed, and once you're happy, give me the signal and I'll mark it complete in `todo.md`."_ Then stop. Do not update `todo.md`, logs, or anything else until the user replies.

**Step 2 — Commit gate:** Once the user confirms (any clear positive signal — "looks good", "mark it", "go ahead"), update `todo.md` (mark `[x]`), update `DEVELOPMENT_LOG.md`. Then stop again and ask: _"I've updated the logs and marked the task complete. Should I go ahead and commit the changes to GitHub?"_ Wait for a yes before committing or pushing.

**What is never allowed:** marking `[x]` in `todo.md` before user confirmation; committing before user confirmation; merging both gates into one action. **You do not decide when something is done. The user does.**

**7. Demand Elegance**
If a solution feels hacky, say so and propose the cleaner path. Don't silently ship workarounds.

**8. Format Before Commit**
Run `dart format .` and `dart fix --apply` on all changed files before every commit. Code that does not pass `dart analyze` is not ready to commit.

**9. Test Before Complete**
If a task involves business logic (anything in `lib/services/`, cart calculations, checkout, promo validation), the corresponding test must be written and passing before the task can be presented as complete. See `AGENTS.md` §17 for what must be tested.

---

## Coding Standards

Follow `AGENTS.md` exactly. Do not interpret or override it.
