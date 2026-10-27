---
name: apply-lite
description: "Low-usage application cycle for mass-apply roles. Reuses the closest answer-bank answers with light edits and a quick checklist instead of the review panel. Only when the user types $apply-lite."
---

Usage: `$apply-lite <job link> [<job link> ...] (optionally paste the questions after a link)`

Job links (and any pasted questions): the text after `$apply-lite` in the user's message.

Follow the rules in `AGENTS.md`. Run `git pull --rebase` first. Keep context small: do this yourself, without subagents, and don't read other applications.

For each link:
0. **Check local files first.** If `applications/jobs/<id>/` already has `posting.md`, `questions.md` (`Status: COMPLETE`) or `answers.md`, reuse them and skip those steps; say which. A PARTIAL or BLOCKED `questions.md`: show the user what it's waiting on, then read only the unread steps.
1. **Fit, one line.** Read the ad once (`curl -sL`), save it to `applications/jobs/<id>/posting.md`, add/find the tracker row. Score fit with the evaluator's fit table in your head and write `<score> <grade>` in the tracker. Under 60/100 (or any hard ineligibility): give the heavy warning from `.agents/skills/draft/SKILL.md` step 1 and wait; never skip it. 75+ is worth suggesting `$apply` instead.
2. **Questions.** Use pasted questions if given. Otherwise read the form once with `browser_snapshot` (no screenshots). Login wall or CAPTCHA: stop and ask the user. Save to `questions.md`.
3. **CV.** The CV for this track from `cv/SWAPS.md`. No swap suggestions unless the fit line names a gap a swap would close.
4. **Answers.** For each question, Search `answer-bank/past-answers.md` with `rg` for the matching `**[<type>]**` tag (and `answer-bank/stories.md` for the story). Take the closest answer and change only what this company/role needs: company name, one specific employer detail, word limit. Read `answer-bank/facts.md` once to check nothing is stale. Save to `answers.md`.
   - If a question has no good match, mark it `[NO MATCH]` and offer to switch this job to `$apply`.
5. **Quick check.** Run the checklist from the evaluator's quick mode yourself (keywords, limits, company name, one example per answer, nothing they can't defend) and fix what fails.
6. Show the user the drafts and the checklist, take their edits, then do `$apply` steps 6–8 (`.agents/skills/apply/SKILL.md`): final answers yes → fill in the browser → stop before Submit → their yes → tracker, applied.xlsx and answer bank.

End: commit and push (`apply-lite: <summary>`), then "Mode done. Run /new before starting the next one."
