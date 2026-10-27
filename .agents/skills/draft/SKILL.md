---
name: draft
description: "Read a job ad, score fit, pick the CV, read the form, draft answers and run the review panel, without filling the form. Saves everything so $apply can submit later. Only when the user types $draft."
---

Usage: `$draft <job link> [<job link> ...] (optionally paste the questions after a link)`

Job links (and any pasted questions): the text after `$draft` in the user's message.

Follow the rules in `AGENTS.md`. Run `git pull --rebase` first; if it conflicts, stop and tell the user. Subagents (in `.codex/agents/`): `evaluator`, `form_reader`, `answer_optimiser`; start each with a message naming the mode, job ID and link. Don't read the answer bank yourself; the subagents do.

For each link, in order:

## 1. Job ad and fit
- Find the job in `applications/tracker.md` (same link, or same company + title + location). If none, add a row (status `found`). Job ID = `company-role`, lowercase, hyphens, ~40 chars.
- **Check local files first; never redo a step whose file exists.** The repo (just pulled) is the store. In `applications/jobs/<id>/`: `posting.md` → don't re-read the ad · `fit.md` → don't re-run fit · `questions.md` with `Status: COMPLETE` → skip step 3 · `answers.md` → skip to step 5 (or past it if `review.md` exists). Say which steps you're skipping and why. Redo one only if the user asks or the file says it's stale.
- Read the ad (`curl -sL`; the Playwright browser only if it needs JavaScript) and save the full text, dates and URL to `applications/jobs/<id>/posting.md`. Postings disappear, so capture all of it.
- Spawn `evaluator` in mode `fit` for this ID. **Thresholds (fit /100):** 75+ (A) → suggest `$apply`. 60–74 → suggest `$apply-lite`. **Under 60 → heavy warning, never a block:** tell the user "⚠ Fit <n>/100 is below your 60 minimum: <reason>. Roles this weak rarely reach interview and cost the same usage. Apply anyway? (yes / no)" and wait. Same warning for any hard ineligibility (wrong graduation year, experience bar). On yes, carry on and note "applied below fit minimum" in Notes.

## 2. CV
Pick the CV for this job's track from `cv/SWAPS.md` and write it in the tracker's CV column. Suggest which skill to list first and whether a project from `answer-bank/cv-points.md` should be swapped in (fetch the live Notion page first if `cv/SWAPS.md` names one and the connector is available). Suggest only; never edit a CV.

## 3. Questions
- If the user pasted the questions, save them to `questions.md` and skip the browser.
- If `questions.md` exists with `Status: PARTIAL` or `BLOCKED`, show the user what it's waiting on (its `ASK USER` items and the blocker) before opening the browser. Once they answer, run `form_reader` in **resume** mode: "Resume <id>: questions.md already covers <steps>; start at <first unread step> and add to the file, don't rewrite it."
- Otherwise spawn `form_reader` for this ID and link. Run form readers one at a time (one browser). If it returns `blocked` (login wall, CAPTCHA), tell the user what to do and move to the next link.
- Set status `scouted`.

## 4. Draft
Spawn `answer_optimiser` for this ID. Status `drafted`.

## 5. Review panel
1. Spawn three `evaluator` subagents **in parallel** and wait for all three, modes `review ats <id>`, `review hiring-manager <id>`, `review technical <id>`.
2. Then spawn `evaluator` in mode `chair <id>`.
3. If the verdict is `revise`, spawn `answer_optimiser` again once ("Revise answers.md using review.md: fix every hard fail and apply the 3 edits; keep everything else") and run `chair <id>` again. One revision only; after that the user decides.

## Report
Per job: fit score, verdict and score, hard fails left, the 3 edits, CV + swap suggestion, any `[CHECK: …]`, and the path `applications/jobs/<id>/answers.md`. Tell them `$apply <link>` picks this draft up.

End: commit and push (`draft: <short summary>`), then "Mode done. Run /new before starting the next one."
