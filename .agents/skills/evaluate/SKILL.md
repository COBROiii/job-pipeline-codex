---
name: evaluate
description: "Fit score for a job link, the full review panel for an application folder, or (no argument) the search-wide report and status. Only when the user types $evaluate."
---

Usage: `$evaluate <job link> | <applications/jobs/<id>> | (blank for report + status)`

Target: the text after `$evaluate` in the user's message.

Follow the rules in `AGENTS.md`. Run `git pull --rebase` first.

- **Job link** → find or add its tracker row, then spawn `evaluator` in mode `fit` for that ID. Show score, grade and the one-line reason.
- **Application folder with `answers.md`** → the full panel: spawn three `evaluator` subagents in parallel and wait for all of them (`review ats <id>`, `review hiring-manager <id>`, `review technical <id>`), then `chair <id>`, saved to `review.md`. Show verdict, score, hard fails and the 3 edits.
- **Blank** → spawn `evaluator` in mode `report`, then from the tracker: counts per status, completed applications, A/B jobs closing within 14 days that aren't applied, `blocked` items, and drafts whose verdict isn't `submit`.

End: commit and push (`evaluate: <summary>`), then "Mode done. Run /new before starting the next one."
