---
name: web-artifacts-builder
description: Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui). Use for complex artifacts requiring state management, routing, or shadcn/ui components - not for simple single-file HTML/JSX artifacts.
tools: Read, Write, Bash, Edit
---

# Web Artifacts Builder

To build powerful frontend claude.ai artifacts, follow these steps:
1. Initialize the frontend repo
2. Develop your artifact by editing the generated code
3. Bundle all code into a single HTML file
4. Display artifact to user
5. (Optional) Test the artifact

**Stack**: React 18 + TypeScript + Vite + Parcel (bundling) + Tailwind CSS + shadcn/ui

## Design & Style Guidelines

VERY IMPORTANT: To avoid what is often referred to as "AI slop", avoid using excessive centered layouts, purple gradients, uniform rounded corners, and Inter font.

## Quick Start

### Step 1: Initialize Project

Create a new React project with the following configuration:

```bash
npx create-vite <project-name> --template react-ts
cd <project-name>
npm install
npm install tailwindcss @tailwindcss/vite
npm install @radix-ui/react-* class-variance-authority clsx tailwind-merge lucide-react
```

This creates a fully configured project with:
- React + TypeScript (via Vite)
- Tailwind CSS with shadcn/ui theming system
- Path aliases (`@/`) configured
- shadcn/ui components
- All Radix UI dependencies included
- Parcel configured for bundling
- Node 18+ compatibility

### Step 2: Develop Your Artifact

To build the artifact, edit the generated files. See **Common Development Tasks** below for guidance.

### Step 3: Bundle to Single HTML File

To bundle the React app into a single HTML artifact:

```bash
npx parcel build index.html --no-source-maps
npx html-inline dist/index.html -o bundle.html
```

This creates `bundle.html` - a self-contained artifact with all JavaScript, CSS, and dependencies inlined.

**What the script does**:
- Installs bundling dependencies (parcel, @parcel/config-default, parcel-resolver-tspaths, html-inline)
- Creates `.parcelrc` config with path alias support
- Builds with Parcel (no source maps)
- Inlines all assets into single HTML using html-inline

### Step 4: Share Artifact with User

Share the bundled HTML file in conversation with the user so they can view it as an artifact.

### Step 5: Testing/Visualizing the Artifact (Optional)

To test/visualize the artifact, use available tools (including other Skills or built-in tools like Playwright or Puppeteer). Avoid testing the artifact upfront as it adds latency. Test later, after presenting the artifact, if requested or if issues arise.

## Reference

- **shadcn/ui components**: https://ui.shadcn.com/docs/components

## Key Principles

- **Single HTML output**: Everything bundles into one self-contained HTML file
- **Modern stack**: React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui
- **No AI slop**: Avoid centered layouts, purple gradients, uniform rounded corners
- **Instant preview**: Works immediately in claude.ai artifacts or any browser
- **Seeded randomness**: Use deterministic seeds for reproducible results
