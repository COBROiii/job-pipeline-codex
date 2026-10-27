---
name: usage-stop
description: Hard stop at 98% usage. Use whenever a usage-limit warning appears, the user says usage is near or at 98%, or a long run (many jobs, many subagents) is under way. Pause everything, sync to GitHub, report, and stop.
---

# Hard stop at 98% usage

**At 98% usage, pause everything and stop.** The last 2% is kept for syncing to GitHub, so nothing is lost if the limit cuts the session off.

## When it triggers
Codex agents can't read the usage meter themselves, so the user checks it with `/status`. Ask them to check it before a batch of more than 4 jobs, and ask again between batches. Stop if they say **either** the 5-hour limit or the weekly limit is at 98% or more. Also treat any of these as hitting 98%:
- a system or usage-limit message that warns the limit is close, or reached with a grace allowance;
- the user says usage is at or near 98% (or tells you to stop for usage);
- a subagent fails with a rate-limit or session-limit error.

## What to do, in this order
1. **Stop starting work.** No new subagents, scouts, drafts or browser steps. Don't send follow-up messages to running agents.
2. **Never submit anything** while stopping, even if a yes is pending. Leave forms open and unsubmitted.
3. **Sync:** `git add -A`, `git commit -m "session: hard stop at 98% usage (<what was in progress>)"`, `git push`. If the push fails, say so.
4. **Report in a few lines:** what's done, what was in progress (including agents that may still be running, whose edits will be uncommitted), and the next step for each open job.
5. **End the turn.** Don't resume until the user says to continue.

## Staying under it
Work in batches of about 4 jobs, and commit and push between batches.
