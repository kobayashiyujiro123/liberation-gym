---
name: code-review
description: Automated code review for pull requests using multiple specialized agents with confidence-based scoring. Use when asked to review a PR, code review, or audit pull request changes.
tools: Read, Glob, Grep, Bash, Task
---

# Code Review

Provide comprehensive code review for pull requests using multi-agent parallel analysis with confidence scoring.

## Workflow

### Step 1: Eligibility Check

Use a fast agent to check if the pull request:
- (a) is closed
- (b) is a draft
- (c) doesn't need review (automated PR, trivially simple)
- (d) already has a code review from earlier

If any condition is true, do not proceed.

### Step 2: Gather Context

- Get list of relevant CLAUDE.md files (root + directories modified by the PR)
- View the pull request and create a summary of the change

### Step 3: Parallel Code Review (5 Agents)

Launch 5 parallel agents to independently review:

| Agent | Focus Area |
|-------|-----------|
| **#1 CLAUDE.md Compliance** | Audit changes against CLAUDE.md guidance |
| **#2 Bug Scanner** | Shallow scan for obvious bugs in changed lines only |
| **#3 Historical Context** | Check git blame and history for bugs in context |
| **#4 Previous PR Patterns** | Review past PRs touching same files for relevant comments |
| **#5 Code Comment Compliance** | Verify changes comply with code comments in modified files |

Each agent returns a list of issues with reasons.

### Step 4: Confidence Scoring

For each issue found, score confidence (0-100):

| Score | Meaning |
|-------|---------|
| **0** | False positive, doesn't stand up to scrutiny, pre-existing issue |
| **25** | Might be real, but may be false positive. Stylistic issues not in CLAUDE.md |
| **50** | Verified real issue, but may be a nitpick. Not very important relative to PR |
| **75** | Very likely real, will be hit in practice. Directly mentioned in CLAUDE.md |
| **100** | Definitely real, will happen frequently. Evidence directly confirms |

### Step 5: Filter and Report

- Filter out issues with score < 80
- If no issues meet threshold, report "No issues found"
- Re-check PR eligibility before commenting

### Step 6: Post Review

Comment on the PR with findings:

```markdown
### Code review

Found N issues:

1. <brief description> (CLAUDE.md says "<...>")
   <link to file and line with full sha1>

2. <brief description> (bug due to <file and code snippet>)
   <link to file and line with full sha1>
```

## False Positive Examples (Exclude These)

- Pre-existing issues
- Something that looks like a bug but isn't
- Pedantic nitpicks a senior engineer wouldn't flag
- Issues a linter/typechecker/compiler would catch
- General code quality issues unless required in CLAUDE.md
- Issues silenced by lint ignore comments
- Intentional functionality changes related to the broader change
- Real issues on lines the user didn't modify

## Link Format

```
https://github.com/{owner}/{repo}/blob/{full-sha}/{file}#L{start}-L{end}
```

Requirements:
- Full git SHA (not abbreviated)
- Line range format: `L[start]-L[end]`
- At least 1 line of context before and after

## Commands

```bash
# View PR
gh pr view <number>

# Get PR diff
gh pr diff <number>

# Comment on PR
gh pr comment <number> --body "..."

# List PR files
gh pr diff <number> --name-only
```
