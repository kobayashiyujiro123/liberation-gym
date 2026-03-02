---
name: cloudflare
description: Comprehensive Cloudflare platform skill covering Workers, Pages, storage (KV, D1, R2), AI (Workers AI, Vectorize, Agents SDK), networking, security (WAF, DDoS), Durable Objects, MCP servers, Wrangler CLI, web performance, and Sandbox SDK. Use for any Cloudflare development task. Source - cloudflare/skills official partner repository.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Cloudflare Platform Skill

Consolidated skill for building on the Cloudflare platform. Use decision trees below to find the right product. Source: `cloudflare/skills` official partner repository.

**IMPORTANT**: Your knowledge of Cloudflare APIs may be outdated. Prefer retrieval from https://developers.cloudflare.com/ over pre-trained knowledge.

## Quick Decision Trees

### "I need to run code"

```
Need to run code?
├─ Serverless functions at the edge → Workers
├─ Full-stack web app with Git deploys → Pages
├─ Stateful coordination/real-time → Durable Objects
├─ Long-running multi-step jobs → Workflows
├─ Run containers → Containers
├─ Multi-tenant (customers deploy code) → Workers for Platforms
├─ Scheduled tasks (cron) → Cron Triggers
├─ Lightweight edge logic (modify HTTP) → Snippets
├─ Process Worker execution events → Tail Workers
└─ Optimize latency to backend → Smart Placement
```

### "I need to store data"

```
Need storage?
├─ Key-value (config, sessions, cache) → KV
├─ Relational SQL → D1 (SQLite) or Hyperdrive (existing Postgres/MySQL)
├─ Object/file storage (S3-compatible) → R2
├─ Message queue (async processing) → Queues
├─ Vector embeddings (AI/semantic search) → Vectorize
├─ Strongly-consistent per-entity state → Durable Objects (DO storage)
├─ Secrets management → Secrets Store
├─ Streaming ETL to R2 → Pipelines
└─ Persistent cache (long-term) → Cache Reserve
```

### "I need AI/ML"

```
Need AI?
├─ Run inference (LLMs, embeddings, images) → Workers AI
├─ Vector database for RAG/search → Vectorize
├─ Build stateful AI agents → Agents SDK
├─ Gateway for any AI provider (caching, routing) → AI Gateway
└─ AI-powered search widget → AI Search
```

### "I need networking/connectivity"

```
Need networking?
├─ Expose local service to internet → Tunnel
├─ TCP/UDP proxy (non-HTTP) → Spectrum
├─ WebRTC TURN server → TURN
├─ Private network connectivity → Network Interconnect
├─ Optimize routing → Argo Smart Routing
└─ Real-time video/audio → RealtimeKit / Realtime SFU
```

### "I need security"

```
Need security?
├─ Web Application Firewall → WAF
├─ DDoS protection → DDoS
├─ Bot detection/management → Bot Management
├─ API protection → API Shield
└─ CAPTCHA alternative → Turnstile
```

### "I need infrastructure-as-code"

```
Need IaC? → Pulumi, Terraform, or REST API
```

---

## Workers

### Basic Worker

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === '/api/hello') {
      return Response.json({ message: 'Hello World' });
    }
    return new Response('Not Found', { status: 404 });
  },
};
```

### Best Practices

- **Streaming**: Stream large/unknown payloads — never `await response.text()` on unbounded data
- **waitUntil**: Use `ctx.waitUntil()` for post-response work; do not destructure `ctx`
- **Bindings over REST**: Use in-process bindings (KV, R2, D1) — not Cloudflare REST API
- **Secrets**: `wrangler secret put KEY_NAME` — never hardcode in config or source
- **Config**: Use `wrangler.jsonc` (JSON config). Set recent `compatibility_date`
- **Types**: Run `wrangler types` to generate `Env` — never hand-write binding interfaces
- **Observability**: Enable `observability` in config; use structured JSON logging

### Anti-Patterns (NEVER)

| Anti-pattern | Why |
|---|---|
| `await response.text()` on unbounded data | Memory exhaustion (128 MB limit) |
| Hardcoded secrets in source or config | Credential leak via version control |
| `Math.random()` for tokens/IDs | Not cryptographically secure |
| Bare `fetch()` without `await` or `waitUntil` | Floating promise — dropped result |
| Module-level mutable variables for request state | Cross-request data leaks |
| Cloudflare REST API from inside a Worker | Unnecessary network hop |
| `ctx.passThroughOnException()` as error handling | Hides bugs |
| Destructuring `ctx` (`const { waitUntil } = ctx`) | Loses `this` binding |

---

## Durable Objects

Stateful coordination primitives with SQLite storage.

```typescript
import { DurableObject } from "cloudflare:workers";

export class MyDO extends DurableObject<Env> {
  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env);
    ctx.blockConcurrencyWhile(async () => {
      this.ctx.storage.sql.exec(`
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT NOT NULL
        )
      `);
    });
  }

  async addItem(data: string): Promise<number> {
    const result = this.ctx.storage.sql.exec<{ id: number }>(
      "INSERT INTO items (data) VALUES (?) RETURNING id", data
    );
    return result.one().id;
  }
}
```

### Critical Rules

1. **Model around coordination atoms** — One DO per chat room/game/user, not one global DO
2. **Use `getByName()` for deterministic routing** — Same input = same instance
3. **Use SQLite storage** — Configure `new_sqlite_classes` in migrations
4. **Use RPC methods** — Not fetch() handler (compatibility date >= 2024-04-03)
5. **Persist first, cache second** — Write to storage before updating in-memory state
6. **One alarm per DO** — `setAlarm()` replaces any existing alarm

---

## Agents SDK

Build AI agents on Cloudflare Workers. Fetch current docs from `https://github.com/cloudflare/agents/tree/main/docs` before implementing.

```typescript
import { Agent, routeAgentRequest, callable } from "agents";

type State = { count: number };

export class Counter extends Agent<Env, State> {
  initialState = { count: 0 };

  @callable()
  increment() {
    this.setState({ count: this.state.count + 1 });
    return this.state.count;
  }
}

export default {
  fetch: (req, env) => routeAgentRequest(req, env) ?? new Response("Not found", { status: 404 })
};
```

### Core APIs

| Task | API |
|------|-----|
| Read state | `this.state.count` |
| Write state | `this.setState({ count: 1 })` |
| SQL query | `` this.sql`SELECT * FROM users WHERE id = ${id}` `` |
| Schedule (delay) | `await this.schedule(60, "task", payload)` |
| Schedule (cron) | `await this.schedule("0 * * * *", "task", payload)` |
| RPC method | `@callable() myMethod() { ... }` |
| Streaming RPC | `@callable({ streaming: true }) stream(res) { ... }` |
| Start workflow | `await this.runWorkflow("ProcessingWorkflow", params)` |

### React Client

```typescript
import { useAgent } from "agents/react";

function App() {
  const agent = useAgent({
    agent: "Counter",
    name: "my-instance",
    onStateUpdate: (newState) => setState(newState),
  });
  return <button onClick={() => agent.setState({ count: state.count + 1 })}>Count</button>;
}
```

---

## Building MCP Servers on Cloudflare

```typescript
import { McpAgent } from "agents/mcp";
import { z } from "zod";

export class MyMCP extends McpAgent<Env> {
  server = new Server({ name: "my-mcp", version: "1.0.0" });

  async init() {
    this.server.tool(
      "get_weather",
      { city: z.string() },
      async ({ city }) => ({
        content: [{ type: "text", text: `Weather in ${city}: Sunny` }],
      })
    );
  }
}
```

### Quick Start Templates

```bash
# Public (no auth)
npm create cloudflare@latest -- my-mcp --template=cloudflare/ai/demos/remote-mcp-authless

# With OAuth
npm create cloudflare@latest -- my-mcp --template=cloudflare/ai/demos/remote-mcp-github-oauth
```

---

## Wrangler CLI

### Essential Commands

```bash
npx wrangler init my-worker         # Create project
npx wrangler dev                    # Local dev server
npx wrangler deploy                 # Deploy Worker
npx wrangler types                  # Generate TypeScript types
npx wrangler check                  # Validate configuration
npx wrangler tail                   # Real-time logs
npx wrangler secret put API_KEY     # Set secret
npx wrangler pages deploy ./dist    # Deploy Pages
```

### Storage Management

```bash
npx wrangler kv namespace create MY_KV
npx wrangler d1 create my-database
npx wrangler d1 migrations apply my-database
npx wrangler r2 bucket create my-bucket
npx wrangler vectorize create my-index --dimensions=768 --metric=cosine
```

### wrangler.jsonc Configuration

```jsonc
{
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2025-01-01",
  "observability": { "enabled": true },
  "vars": { "ENVIRONMENT": "production" },
  "kv_namespaces": [{ "binding": "MY_KV", "id": "abc123" }],
  "d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "xyz789" }],
  "r2_buckets": [{ "binding": "STORAGE", "bucket_name": "my-bucket" }],
  "durable_objects": {
    "bindings": [{ "name": "MY_DO", "class_name": "MyDurableObject" }]
  }
}
```

---

## Sandbox SDK

Build secure, isolated code execution environments.

```typescript
import { getSandbox } from '@cloudflare/sandbox';
export { Sandbox } from '@cloudflare/sandbox'; // Required export

const sandbox = getSandbox(env.Sandbox, 'user-123');

// Execute commands
const result = await sandbox.exec('python script.py');

// Code interpreter (recommended for AI)
const ctx = await sandbox.createCodeContext({ language: 'python' });
await sandbox.runCode('data = [1,2,3]', { context: ctx });
const result = await sandbox.runCode('sum(data)', { context: ctx });

// File operations
await sandbox.writeFile('/workspace/app.py', content);
const file = await sandbox.readFile('/workspace/app.py');

// Preview URLs
const { url } = await sandbox.exposePort(8080);
```

---

## Web Performance Auditing

### Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| TTFB | < 800ms | < 1.8s | > 1.8s |
| FCP | < 1.8s | < 3s | > 3s |
| LCP | < 2.5s | < 4s | > 4s |
| INP | < 200ms | < 500ms | > 500ms |
| CLS | < 0.1 | < 0.25 | > 0.25 |

Requires Chrome DevTools MCP server for auditing. Use `navigate_page`, `performance_start_trace`, `performance_analyze_insight` tools.
