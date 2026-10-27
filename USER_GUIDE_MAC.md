# User guide for Mac

This page gets the pipeline running on a Mac. Once it's set up, everything you do inside Codex (the `$find`, `$draft`, `$apply` commands, the review panel, submitting) works the same as on Windows, so for that part read [USER_GUIDE.md](USER_GUIDE.md) from "The workflow" onwards.

All the commands below go in the **Terminal** app (Applications › Utilities › Terminal, or press Cmd+Space and type "Terminal"). Paste one line at a time and press Return.

## What you need

- A Mac on a recent version of macOS
- A ChatGPT plan that includes Codex
- **Google Chrome**, installed in your Applications folder
- A **GitHub** account

## 1. Install the tools

1. **Apple's command line tools** (gives you git):
   ```bash
   xcode-select --install
   ```
   A window pops up; click Install and wait for it to finish. If it says they're already installed, that's fine.

2. **Homebrew**, the usual way to install developer tools on a Mac (skip if `brew --version` already works):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   At the end it prints two or three "Next steps" lines starting with `echo` and `eval`. Run them, or `brew` won't be found.

3. **Node.js, Python, the GitHub CLI and Chrome** (leave `google-chrome` off if you already have Chrome):
   ```bash
   brew install node python gh
   ```
   ```bash
   brew install --cask google-chrome
   ```

4. **Codex**:
   ```bash
   npm install -g @openai/codex
   ```
   (`brew install --cask codex` works too. Use one or the other.)

5. **Sign in to GitHub** so pulls and pushes work without asking for a password:
   ```bash
   gh auth login
   ```
   Pick GitHub.com, HTTPS, and "Login with a web browser".

6. **Tell git who you are**, if you haven't before:
   ```bash
   git config --global user.name "Your Name"
   ```
   ```bash
   git config --global user.email "you@example.com"
   ```

## 2. Get your own copy

1. On GitHub, open this repo and click **Use this template** › **Create a new repository**. **Make it private.** It will hold your CV, transcript and every answer you write.
2. Clone it into your Documents folder:
   ```bash
   cd ~/Documents
   ```
   ```bash
   gh repo clone <your-username>/job-pipeline-codex
   ```
3. Install the spreadsheet library:
   ```bash
   cd ~/Documents/job-pipeline-codex
   ```
   ```bash
   python3 -m pip install --user -r requirements.txt
   ```
   If it says **externally-managed-environment**, run this instead (it only adds one small library):
   ```bash
   python3 -m pip install --user --break-system-packages -r requirements.txt
   ```
4. Start Codex in that folder:
   ```bash
   codex
   ```
5. Sign in with your ChatGPT account when asked.
6. **Trust the folder** when Codex asks. Without this it ignores `.codex/`, so the agents, browser and hooks won't load.
7. Type `/hooks` and trust the three hooks (pull at start, push at end, the `/new` reminder).

From now on, to start a session: open Terminal, run `cd ~/Documents/job-pipeline-codex`, then `codex`.

## 3. Check it works

- `/skills` should list `find`, `evaluate`, `draft`, `apply` and `apply-lite`.
- `/mcp` should list `playwright`.
- `$evaluate` with nothing after it should read your empty tracker and report.
- Ask *"Open https://example.com in the browser."* A Chrome window opens with its own profile, separate from your normal Chrome. The first time, macOS may ask whether Terminal or Node can control Chrome or use the network: click **Allow**. Then sign in to the job sites you use in that window. It remembers the sign-ins.

Then fill in your details: see "Make it yours" in [USER_GUIDE.md](USER_GUIDE.md#2-make-it-yours).

## Mac tips

- **Hidden folders.** `.codex/` and `.agents/` start with a dot, so Finder hides them. Press **Cmd+Shift+.** in Finder to show them (press it again to hide them).
- **Opening files.** To open the folder in Finder: `open ~/Documents/job-pipeline-codex`. The `.md` files open in any text editor (TextEdit works; VS Code is nicer).
- **The spreadsheet.** `applications/applied.xlsx` opens in Excel or Numbers. If you open it in Numbers, close it without saving, so it stays an `.xlsx`. Close it before running `$apply`, or the row can't be added.
- **Uploads.** CVs and documents are uploaded from the folder, so keep them where `cv/SWAPS.md` and `documents/README.md` say. iCloud "Optimise Mac Storage" can offload files from Documents; if an upload fails with "file not found", open the file once in Finder to download it again.
- **Mac and Windows together.** You can clone the same private repo on a Mac and a Windows PC. Each session pulls when it starts and pushes when it ends, and the hooks work on both.
- **Keeping Codex up to date:** `npm install -g @openai/codex@latest` (or `brew upgrade --cask codex`).

## Troubleshooting on a Mac

| Problem | Fix |
|---|---|
| `brew: command not found` | Run the "Next steps" lines Homebrew printed, or close and reopen Terminal |
| `codex: command not found` after npm install | Close and reopen Terminal. If it still fails, use `brew install --cask codex` instead |
| `xcrun: error: invalid active developer path` | Run `xcode-select --install` again (it's often needed after a macOS update) |
| Commands, agents or hooks do nothing | Start `codex` inside the folder, accept the trust prompt, then `/hooks` and trust all three |
| Browser tools missing | Run `node --version` to check Node is installed, restart Codex, then `/mcp` |
| Playwright can't find Chrome | Chrome must be in `/Applications`. Reinstall with `brew install --cask google-chrome` |
| macOS blocks Chrome or Node from opening | System Settings › Privacy & Security: allow it there, then try again |
| `git push` asks for a username or password | Run `gh auth login` and `gh auth setup-git` |
| Saving to `applied.xlsx` fails | Close the file in Excel or Numbers, then tell Codex to try again |
| A model name is rejected | Run `/model` to see yours, then update `model` in `.codex/config.toml` and `.codex/agents/*.toml` |

For everything else, see the troubleshooting table in [README.md](README.md#troubleshooting).
