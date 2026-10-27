# User guide (Codex)

This folder is a job application assistant that runs inside OpenAI Codex. You give it a job link and it reads the ad, scores how well you fit, drafts your answers in your own voice, has a panel of reviewers check them, and fills the application form in a browser. It never presses Submit until you say yes for that job.

You don't need to know how to code. You type commands into Codex and reply to its questions in plain English. This guide covers how to use the workflow from start to finish. How each part works inside is already written in the `.md` and `.toml` files, and you can ask Codex about any of them.

Using Claude Code instead? Use [job-pipeline-template](https://github.com/COBROiii/job-pipeline-template), the original version.

## What you need

- A ChatGPT plan that includes Codex, and the **Codex CLI**: `npm install -g @openai/codex` (setup: https://learn.chatgpt.com/docs)
- **Node.js** (https://nodejs.org), for Codex itself and for the Playwright browser
- **Google Chrome**, which the Playwright browser uses to read and fill forms
- A **GitHub** account and **git**. On Windows, install Git for Windows to its default folder; the hooks use its Git Bash.
- Python with `openpyxl` (`pip install -r requirements.txt`), for the applied-jobs spreadsheet

## 1. Get your own copy

1. On GitHub, click **Use this template** (or fork). **Make your copy private.** It will hold your CV, transcript and every answer you write.
2. Clone it to your computer:
   ```bash
   git clone https://github.com/<your-username>/job-pipeline-codex.git
   ```
3. Open the folder in a terminal and start Codex:
   ```bash
   cd job-pipeline-codex
   codex
   ```
4. Sign in with your ChatGPT account when asked.
5. **Trust the folder** when Codex asks. Without this it ignores `.codex/`, so the agents, browser and hooks won't load.
6. Type `/hooks` and trust the three hooks (pull at start, push at end, the `/new` reminder). Codex skips hooks you haven't reviewed, and asks again if a hook file changes.

If you use two computers, clone it on both. Each session pulls from GitHub when it starts and pushes when it ends, so both stay in step.

## 2. Make it yours

Every file you need to fill in has `TODO` markers. Fill them in before your first run. The quickest way is to ask Codex: *"Interview me and fill in every TODO in `AGENTS.md`, `config/` and `answer-bank/facts.md`."* It asks you questions and writes the answers down. To check nothing is left, ask *"Which files still have TODOs?"*

| File | What goes in it |
|---|---|
| `AGENTS.md` | Your name, a few lines about you, and your tracks in priority order. Codex reads this at the start of every session. |
| `config/criteria.md` | Your **tracks** (the kinds of job you want, e.g. engineering, consulting), job titles to search for, which job boards to use, locations, a company watchlist, and what to exclude. |
| `answer-bank/facts.md` | The source of truth: dates, grades, numbers, what you're doing now, and claims to avoid. If it's not here or on your CV, Codex won't claim it. |
| `config/profile.md` | Every routine form fact: contact, address, right to work, start date, dietary needs, declarations (convictions, disciplinary) and, if you want, your diversity answers. When a form asks something new, Codex asks you once and adds it here. |
| `cv/` | Your CV as a PDF, plus a `.md` copy (ask Codex to make the `.md` from the PDF). One technical and one general CV work well. `cv/SWAPS.md` says which CV goes with which kind of job. |
| `answer-bank/past-answers.md` | Paste in old application answers you're happy with. The more good ones, the more the drafts sound like you. |
| `answer-bank/stories.md` | Your best stories (a project, a failure, a team moment) and which questions they answer. |
| `answer-bank/cover-letters.md` | Past cover letters, if you have any. |
| `documents/` | Transcript and any other documents forms ask you to upload. |

`applications/tracker.md` and `applications/applied.xlsx` start empty and fill up as you go. You don't need to touch `.agents/` or `.codex/`, which hold the commands, agents, browser setup and hooks.

## 3. Check it works

- Type `/skills`. You should see `find`, `evaluate`, `draft`, `apply` and `apply-lite`.
- Type `/mcp`. You should see `playwright`.
- Type `$evaluate` with nothing after it. It should read your (empty) tracker and report.
- Ask *"Open https://example.com in the browser."* A Chrome window should open. Sign in to the job sites you use in that window now. It keeps its own profile, separate from your normal Chrome, and remembers the sign-ins.

## The workflow

```
  $find  ──►  tracker  ──►  $evaluate <link>  ──►  $draft <link>  ──►  you edit  ──►  $apply <link>  ──►  you say "yes"
 (search)     (list of      (is it worth it?)      (answers +          answers.md      (fills the form,      (sent, logged,
               jobs)                                review panel)                       stops before          answers saved
                                                                                        Submit)               for next time)
```

Commands start with `$` in Codex (Claude Code uses `/`). You can stop after any step and come back days later. Everything is saved in files, so the next command picks up where the last one stopped. If a job already has its ad, fit score, questions or answers saved, Codex reuses them instead of redoing the work, and tells you which steps it skipped.

## The commands

### `$find` — look for jobs
**Type:** `$find` or `$find <track>` (your track IDs from `config/criteria.md`)
**What happens:** searches the job boards in `config/criteria.md` and adds new roles to `applications/tracker.md`. It skips jobs already on the list and never touches LinkedIn.
**You get:** a short table of new roles with deadlines and a rough fit guess. Anything closing within two weeks is flagged.
**Use it:** at the start of a week, or when the tracker is running low.

### `$evaluate` — is this job worth applying for?
**Type:** `$evaluate <job link>`
**What happens:** reads the ad and scores your fit out of 100, with a one-line reason.
**How to read the score:** 75+ is a strong match, so use `$apply`. 60–74 is a decent match, so `$apply-lite` is fine. Under 60 you'll get a warning; you can still go ahead, but these rarely reach interview.

Two other uses:
- `$evaluate` on its own gives a status report: how many jobs at each stage, strong jobs closing soon that you haven't applied for, and anything stuck.
- `$evaluate applications/jobs/<id>` reruns the review panel on answers you've already drafted.

### `$draft` — write the application, don't send it
**Type:** `$draft <job link>` (several links at once is fine). If you already have the questions, paste them after the link and it won't need to open the form.
**What happens:**
1. Saves the full job ad (postings disappear) and scores fit.
2. Picks which CV to use and may suggest a project to swap in. It never edits your CV; you make that change yourself.
3. Opens the form and records every question, word limit and upload. If it has to stop partway (a sign-in, or a question only you can answer), it saves what it has read and marks it partial. Next time it shows you what it's waiting on, then carries on from that page.
4. Drafts your answers from your answer bank, in your voice.
5. Three reviewers check the answers separately, at the same time (an ATS keyword scan, a hiring manager and a technical interviewer). A chair combines them into a verdict (submit, revise or skip) and the three smallest edits that would help most. If the verdict is revise, it rewrites once.

**You get:** `applications/jobs/<id>/answers.md`, ready for you to read and edit. Anything it couldn't verify is marked `[CHECK: …]` for you to answer.
**Use it:** when you want to batch the writing now and fill the forms later.

### `$apply` — the full application
**Type:** `$apply <job link>`
**What happens:**
1. Runs `$draft`, or picks up the draft if you've already made one.
2. Shows you the answers and the review, and takes your edits. It asks "Are these the final answers?" and waits for your yes.
3. Opens the form in the browser, fills your details, pastes the approved answers exactly and uploads your CV.
4. **Stops before Submit**, tells you what's filled and what's blank, and asks you to check the browser window.
5. It asks "Submit <Company> — <Role> now? (yes / no)". Only a clear yes to that question presses Submit, once. Anything else leaves the form unsent.
6. Marks the job `applied`, adds a row to `applications/applied.xlsx`, and saves your final answers to the answer bank so later drafts can reuse them.

**Use it:** for jobs you really want, and for your first 20 or so applications while the answer bank fills up.

### `$apply-lite` — the quick version
**Type:** `$apply-lite <job link>`
**What happens:** the same fill-and-submit steps as `$apply`, but much cheaper. It reuses your closest saved answer for each question, changes only the company-specific parts, and runs a quick checklist instead of the review panel. If a question has no good match it offers to switch to `$apply`.
**Use it:** for high-volume roles, or when you're low on usage. It works best once your answer bank has two or more saved answers for each common question (the tracker header counts them for you).

## What stays with you

These are built in as rules:

- **Submitting.** Nothing is sent unless you say yes when Codex asks "Submit <Company> — <Role> now?" for that specific job. Approving one job never carries over to another.
- **Logins, new accounts and CAPTCHAs.** Codex stops and asks you to do them in the browser window, then carries on.
- **LinkedIn.** No automation at all. Search and use Easy Apply there yourself. To track a LinkedIn job, run `$evaluate <link>`.
- **Your CV file.** Codex suggests changes; you make them.
- **Your details.** Forms are filled only from `config/profile.md`. Anything it doesn't cover, Codex asks you, then saves your answer there.
- **Facts.** Codex never makes up a claim. If something isn't in `answer-bank/facts.md` or your CV, it writes `[CHECK: …]` and asks you.

## Everyday tips

- **Type `/new` between commands.** Each command ends with a reminder. A fresh session keeps Codex focused and uses less of your allowance.
- **Paste the questions when you have them.** `$draft <link>` with the questions pasted after it needs no browser at all.
- **Batch.** Draft several jobs, then fill them all in one go: `$apply <link1> <link2> …`
- **Keep facts current.** New grade, new role, new project? Update `answer-bank/facts.md` first. It overrides older answers.
- **Watch your usage.** Codex can't see your usage meter, so it asks you to check `/status` before big batches. If you're near your limit, tell it. It saves and syncs everything to GitHub before you run out (see `.agents/skills/usage-stop/SKILL.md`).
- **Approvals.** Codex runs in the `workspace-write` sandbox and asks before anything outside this folder. Approve git and job-site commands for the session when it asks.

## Where things live

| Where | What |
|---|---|
| `applications/tracker.md` | Every job, one row each, with its stage: `found` → `scouted` → `drafted` → `ready` → `applied` (or `skipped` / `blocked`) |
| `applications/jobs/<id>/` | One folder per job: the saved ad, questions, fit score, answers, review and a log |
| `applications/applied.xlsx` | Submitted applications only, one sheet per track |
| `answer-bank/` | Everything Codex writes from. Read `answer-bank/README.md` first. |

## Words you'll see

- **Fit score:** how well you match the job, out of 100.
- **Answer score / verdict:** how ready the answers are. 80+ means submit, below that means revise or skip.
- **Review panel:** the three independent reviewers and a chair who check each draft.
- **Answer bank:** your saved facts, stories and past answers. It grows every time you apply.
- **Skill:** a command such as `$apply`. Its steps are in `.agents/skills/<name>/SKILL.md`.
- **Subagent:** a helper with one job (finding jobs, reading forms, writing answers, reviewing), defined in `.codex/agents/`. The commands start them for you.

For browser problems and troubleshooting, see `README.md`.

## Converting the Claude template again

This repo was built from the Claude Code template. If that template gets new features and you want them here, or you want to turn any other copy of it into Codex format, clone it into an empty folder, start `codex` there, and paste the prompt below. Then compare the result with this repo before you copy anything across.

```text
Convert this Claude Code project into an OpenAI Codex project, in place. The folder is a copy of
https://github.com/COBROiii/job-pipeline-template (a job application pipeline). Keep what the
pipeline does exactly the same; change only how it is wired up.

First read every file under .claude/, plus CLAUDE.md, README.md and USER_GUIDE.md. Then check the
current Codex docs for skills, subagents, hooks, MCP and config.toml (https://learn.chatgpt.com/docs).
Where the docs disagree with the steps below, follow the docs and tell me what you changed.

1. CLAUDE.md -> AGENTS.md. Same rules. Replace /<command> with $<command>, /clear with /new,
   .claude/ paths with the new ones below, and "Chrome" with "the Playwright browser". Add a rule:
   read web pages with web search or `curl -sL`; open the browser only for JavaScript pages and forms.
2. .claude/skills/<name>/SKILL.md -> .agents/skills/<name>/SKILL.md. Frontmatter keeps only `name`
   and `description`. Replace `$ARGUMENTS` with "the text after `$<name>` in the user's message" and
   put the old argument-hint on a "Usage:" line. The five commands (find, evaluate, draft, apply,
   apply-lite) had disable-model-invocation, so give each an agents/openai.yaml with
   policy.allow_implicit_invocation: false. Move story-flow, usage-stop and humanizer across too.
3. .claude/agents/<name>.md -> .codex/agents/<name>.toml with name (snake_case: job_seeker,
   form_reader, answer_optimiser, evaluator), description, model, model_reasoning_effort and
   developer_instructions (the old body, as a ''' literal string). Model map: sonnet -> the default
   Codex model; haiku -> the most efficient Codex model. Codex agents have no tool lists, so drop
   them and say in the instructions what each agent must not do. In the skills, "Run <agent>"
   becomes "Spawn <agent>", and "at the same time" becomes "spawn in parallel and wait for all".
4. Tool names: WebFetch -> `curl -sL` or web search; Grep -> `rg`; Claude in Chrome (get_page_text,
   read_page, tabs) -> the Playwright MCP tools (browser_navigate, browser_snapshot, browser_click,
   browser_type, browser_file_upload, browser_tabs).
5. .claude/settings.json -> .codex/config.toml: model, approval_policy = "on-request",
   sandbox_mode = "workspace-write", [sandbox_workspace_write] network_access = true,
   web_search = "live", [agents] max_concurrent_threads_per_session = 3,
   [mcp_servers.playwright] running `npx -y @playwright/mcp@latest --browser chrome`, and a Notion
   MCP entry (url https://mcp.notion.com/mcp) with enabled = false. Drop enabledPlugins and the git
   permission list.
6. Hooks -> .codex/hooks.json, scripts in .codex/hooks/. SessionStart (matcher startup|resume) runs
   sync-pull.sh, SessionEnd runs sync-push.sh, UserPromptSubmit runs clear-nudge.sh. Give each a
   commandWindows that calls "C:\Program Files\Git\bin\bash.exe". Codex has no CLAUDE_PROJECT_DIR,
   so the scripts cd to `git rev-parse --show-toplevel`. Codex transcripts aren't in Claude's format,
   so clear-nudge counts prompts per session_id instead of reading token usage (nudge at 25 prompts,
   then every 10). Delete submit-guard.js and its test folder (Chrome-only and not connected).
7. usage-stop: Codex can't read the usage meter, so ask the user to check /status before batches of
   more than 4 jobs and between batches.
8. answer-bank/, config/, cv/, documents/: "Claude" -> "Codex", .claude/ paths -> new paths,
   Chrome -> the Playwright browser. Don't change anything else in them.
9. Rewrite README.md and USER_GUIDE.md for Codex users: installing the CLI, signing in, trusting the
   folder, reviewing hooks with /hooks, signing in to job sites in the Playwright window, $commands,
   /new between commands.
10. .gitignore: ignore .codex/hooks/.counts/ instead of the .claude/ entries.

Keep every safety rule, in meaning and strength: nothing is submitted without the user's explicit
yes for that specific job; logins, accounts and CAPTCHAs are the user's; no LinkedIn automation;
never invent facts.

When you finish: parse every .toml and .json file, search for leftover "claude", "Chrome",
"WebFetch", "/clear" and "$ARGUMENTS", and list anything you couldn't map. Don't commit or push
until I say so.
```
