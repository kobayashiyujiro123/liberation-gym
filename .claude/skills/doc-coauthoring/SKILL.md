---
name: doc-coauthoring
description: Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks.
tools: Read, Write, Edit, Glob, Grep, Bash, Task
---

# Doc Co-Authoring Workflow

This skill provides a structured workflow for guiding users through collaborative document creation. Act as an active guide, walking users through three stages: Context Gathering, Refinement & Structure, and Reader Testing.

## When to Offer This Workflow

**Trigger conditions:**
- User mentions writing documentation: "write a doc", "draft a proposal", "create a spec", "write up"
- User mentions specific doc types: "PRD", "design doc", "decision doc", "RFC"
- User seems to be starting a substantial writing task

**Initial offer:**
Offer the user a structured workflow for co-authoring the document. Explain the three stages:

1. **Context Gathering**: User provides all relevant context while Claude asks clarifying questions
2. **Refinement & Structure**: Iteratively build each section through brainstorming and editing
3. **Reader Testing**: Test the doc with a fresh Claude (no context) to catch blind spots before others read it

If user declines, work freeform. If user accepts, proceed to Stage 1.

## Stage 1: Context Gathering

**Goal:** Close the gap between what the user knows and what Claude knows, enabling smart guidance later.

### Initial Questions

Start by asking the user for meta-context about the document:

1. What type of document is this? (e.g., technical spec, decision doc, proposal)
2. Who's the primary audience?
3. What's the desired impact when someone reads this?
4. Is there a template or specific format to follow?
5. Any other constraints or context to know?

Inform them they can answer in shorthand or dump information however works best for them.

### Info Dumping

Once initial questions are answered, encourage the user to dump all the context they have:
- Background on the project/problem
- Related team discussions or shared documents
- Why alternative solutions aren't being used
- Organizational context
- Timeline pressures or constraints
- Technical architecture or dependencies
- Stakeholder concerns

Advise them not to worry about organizing it - just get it all out.

**During context gathering:**
- Track what's being learned and what's still unclear
- If user mentions entities/projects that are unknown, ask for clarification
- As context accumulates, ask 5-10 numbered clarifying questions

**Exit condition:**
Sufficient context has been gathered when edge cases and trade-offs can be asked about without needing basics explained.

## Stage 2: Refinement & Structure

**Goal:** Build the document section by section through brainstorming, curation, and iterative refinement.

**For each section:**

### Step 1: Clarifying Questions
Ask 5-10 clarifying questions about what should be included.

### Step 2: Brainstorming
Brainstorm 5-20 things that might be included. Look for:
- Context shared that might have been forgotten
- Angles or considerations not yet mentioned

### Step 3: Curation
Ask which points should be kept, removed, or combined. Request brief justifications.

### Step 4: Gap Check
Ask if there's anything important missing.

### Step 5: Drafting
Draft the section based on selections. Use `Edit` for targeted updates.

### Step 6: Iterative Refinement
Make surgical edits based on feedback. Never reprint the whole doc.

**Quality Checking:**
After 3 consecutive iterations with no substantial changes, ask if anything can be removed.

### Near Completion

As approaching completion (80%+ of sections done):
- Re-read the entire document
- Check for flow, consistency, redundancy, contradictions
- Check for "slop" or generic filler
- Verify every sentence carries weight

## Stage 3: Reader Testing

**Goal:** Test the document with a fresh Claude (no context bleed) to verify it works for readers.

### Step 1: Predict Reader Questions
Generate 5-10 questions that readers would realistically ask.

### Step 2: Test with Sub-Agent
For each question, invoke a sub-agent with just the document content and the question.
Summarize what Reader Claude got right/wrong.

### Step 3: Run Additional Checks
Check for ambiguity, false assumptions, contradictions.

### Step 4: Report and Fix
If issues found, loop back to refinement for problematic sections.

### Exit Condition
When Reader Claude consistently answers questions correctly and doesn't surface new gaps.

## Final Review

1. Recommend a final read-through by the user
2. Suggest double-checking facts, links, and technical details
3. Verify it achieves the desired impact

## Tips for Effective Guidance

**Tone:** Direct and procedural. Don't try to "sell" the approach.

**Handling Deviations:** Always give user agency to adjust the process.

**Quality over Speed:** Each iteration should make meaningful improvements.
