# Job application pipeline (Codex)

A job application assistant for OpenAI Codex. It finds roles, scores how well you fit, drafts answers in your own voice from your past applications, has an independent panel review them, and fills the form in a browser. It never submits without your explicit yes.

This is the Codex version of [job-pipeline-template](https://github.com/COBROiii/job-pipeline-template), which runs in Claude Code. The workflow and rules are the same; only the wiring differs.

**New here? Start with [USER_GUIDE.md](USER_GUIDE.md):** setup, making it yours, and what each command does.

> **Keep your copy private.** Once you fill it in, it holds your CV, contact details, diversity answers and every application you write.

## How it fits together

```
 $find [track]      job_seeker (job boards + company watchlist in config/criteria.md) ──► applications/tracker.md
 $evaluate <link>   evaluator: fit score /100 + one-line reason ──► jobs/<id>/fit.md
 $draft <link>      ad + fit ► CV pick + swap ► form_reader (efficient model) ► answer_optimiser ► review panel
                    review panel = ATS · hiring manager · technical interviewer (independent, in parallel) ► chair:
                    submit / revise / skip + the 3 smallest edits (one revision round)
 $apply <link>      $draft (or picks up the saved draft) ► your edits ► fill form in the browser ► stops before
                    Submit ► "Submit <Company> now? (yes/no)" ► your yes ► tracker, applied.xlsx, answer bank
 $apply-lite <link> one-line fit, reuses tagged answer-bank answers, quick checklist, same fill/submit steps
 $evaluate          (blank) search-wide report + status
```

The evaluator never writes answers, only judges them. Agents hand work over through files, so you can stop at any point and pick up later.

## What's where

| Path | What |
|---|---|
| `AGENTS.md` | The rules Codex reads at the start of every session |
| `.agents/skills/` | The five commands (`$find` …) plus `story-flow`, `usage-stop` and `humanizer` |
| `.codex/agents/` | The four subagents, one TOML file each |
| `.codex/config.toml` | Model, sandbox, web search, the Playwright browser and optional Notion |
| `.codex/hooks.json`, `.codex/hooks/` | Pull from GitHub at start, push at end, nudge to `/new` in long sessions |

## The browser
Forms are read and filled through the [Playwright MCP server](https://github.com/microsoft/playwright-mcp), set up in `.codex/config.toml`. The first time a command needs it, a Chrome window opens with its own profile. Sign in to job sites in that window yourself; the profile keeps your sign-ins for next time. Codex stops and hands back to you on any login page or CAPTCHA.

## Keeping it good
- **Answer bank:** `$apply` saves every submitted answer to `answer-bank/past-answers.md`. That's how the drafts get better over time.
- **Facts:** when something changes (new role, new numbers, new project), update `answer-bank/facts.md` first. It overrides older answers.
- **Notion (optional):** if your CV points live in Notion, set `enabled = true` under `[mcp_servers.notion]` in `.codex/config.toml`, then run `codex mcp login notion`.
- **Project swaps:** the optimiser may suggest swapping a project on your CV and drafts the bullets from your CV points. Make the change in your CV yourself, export it, and save it as `applications/jobs/<id>/cv.pdf`; that job then uses it instead of the default.

## Which command, and keeping usage down
- Use `$apply` for your first ~20 applications to build up the answer bank. After that, `$apply` for roles you really want or unusual questions, and `$apply-lite` for mass-apply roles or when usage is short. The tracker header counts tagged answers per question type; `$apply` tells you when each has 2+, which means lite is ready.
- Paste the questions after the link in `$draft` when you have them; then no browser is needed.
- Run `/new` between applications.
- Batch: draft several first, then fill them all in one go (`$apply <link1> <link2> …` picks up the drafts).
- LinkedIn is manual only: search and Easy Apply there yourself, then add the job with `$evaluate <link>` if you want it tracked.

## Troubleshooting
| Problem | Fix |
|---|---|
| Commands, agents or hooks do nothing | Codex only loads `.codex/` for trusted folders. Start `codex` inside the folder and accept the trust prompt, then run `/hooks` and trust the three hooks |
| `$find` isn't recognised | Run `/skills` to check the skills loaded; make sure you started `codex` inside this folder |
| Browser tools missing | Install Node.js, restart Codex, run `/mcp` and check `playwright` is listed |
| Browser stops responding mid-form | A pop-up dialog may be blocking it; dismiss it and tell Codex to continue |
| A site asks you to create an account | Create it yourself in the Playwright window, sign in, then tell Codex to continue |
| `git push` asks for approval every time | Approve it for the session when Codex asks, or check `network_access = true` in `.codex/config.toml` |
| Hooks fail on Windows | Install Git for Windows to its default folder (`C:\Program Files\Git`); otherwise edit `commandWindows` in `.codex/hooks.json` to your `bash.exe` path |
| Commit fails with "Author identity unknown" | Run `git config --global user.name "<your name>"` and `git config --global user.email "<your email>"` |
| A model name is rejected | Model names change. Run `/model` to see yours, then update `model` in `.codex/config.toml` and `.codex/agents/*.toml` |

## Credits
- `.agents/skills/humanizer/` is [Humanizer](https://github.com/blader/humanizer) by Siqi Chen (MIT licence; see its `LICENSE`).
- Ideas: hiring-panel CV review (https://www.instagram.com/reel/DeVIz_uS06F/) · LLM Council, independent reviewers plus a chair (https://www.instagram.com/reel/De1KdfXuIK3/)
- Codex docs: [skills](https://learn.chatgpt.com/docs/build-skills) · [subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) · [hooks](https://learn.chatgpt.com/docs/hooks) · [MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli) · [config reference](https://learn.chatgpt.com/docs/config-file/config-reference)
