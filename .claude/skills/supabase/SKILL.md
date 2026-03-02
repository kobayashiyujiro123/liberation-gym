---
name: supabase
description: Supabase Postgres performance optimization and best practices. Covers query performance, connection management, security with Row Level Security (RLS), schema design, concurrency, data access patterns, monitoring, and advanced features. Use when building on Supabase or optimizing Postgres queries. Source - supabase/agent-skills official partner repository.
tools: Read, Write, Edit, Bash
---

# Supabase Postgres Best Practices

Performance optimization and best practices for Supabase. Source: `supabase/agent-skills` official partner repository.

## 1. Query Performance

### Use Appropriate Indexes

```sql
-- Good: Index on frequently filtered columns
CREATE INDEX idx_users_email ON users (email);

-- Good: Composite index for multi-column queries
CREATE INDEX idx_orders_user_date ON orders (user_id, created_at DESC);

-- Good: Partial index for common filter conditions
CREATE INDEX idx_active_users ON users (email) WHERE is_active = true;

-- Bad: Missing index on foreign key
SELECT * FROM orders WHERE user_id = '123'; -- Full table scan without index
```

### Use EXPLAIN to Analyze

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = '123' ORDER BY created_at DESC LIMIT 10;
```

Look for:
- **Seq Scan** on large tables (needs index)
- **High cost** estimates
- **Rows removed by filter** (index not covering)

### Avoid SELECT *

```sql
-- Bad
SELECT * FROM users WHERE id = '123';

-- Good: Only select needed columns
SELECT id, email, name FROM users WHERE id = '123';
```

## 2. Connection Management

### Use Connection Pooling

Supabase provides PgBouncer built-in:
- **Transaction mode** (port 6543): For serverless/edge functions
- **Session mode** (port 5432): For long-lived connections

```typescript
// Supabase client (auto-managed pooling)
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Direct Postgres (use transaction mode for serverless)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // port 6543
  max: 10,
});
```

### Avoid Connection Leaks

Always close connections in serverless functions. Use `try/finally` patterns.

## 3. Security & Row Level Security (RLS)

### Enable RLS on All Tables

```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own data
CREATE POLICY "Users read own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users update own data"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

### Common RLS Patterns

```sql
-- Admin access
CREATE POLICY "Admin full access"
  ON public.items
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Team-based access
CREATE POLICY "Team members access"
  ON public.projects
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.project_id = projects.id
      AND team_members.user_id = auth.uid()
    )
  );
```

## 4. Schema Design

### Use UUIDs for Primary Keys

```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Use Proper Data Types

| Data | Type | Avoid |
|------|------|-------|
| Timestamps | `TIMESTAMPTZ` | `TIMESTAMP`, `TEXT` |
| Money | `NUMERIC(10,2)` | `FLOAT`, `REAL` |
| JSON data | `JSONB` | `JSON`, `TEXT` |
| Enums | `TEXT CHECK` or custom type | Bare `TEXT` |
| Arrays | Native arrays | Comma-separated `TEXT` |

### Foreign Keys

```sql
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Always index foreign keys
CREATE INDEX idx_orders_user_id ON orders (user_id);
```

## 5. Concurrency & Locking

### Use Optimistic Locking

```sql
-- Add version column
ALTER TABLE items ADD COLUMN version INTEGER DEFAULT 1;

-- Update with version check
UPDATE items
SET name = 'New Name', version = version + 1
WHERE id = '123' AND version = 5;
-- If 0 rows affected, someone else updated first
```

### Avoid Long Transactions

```sql
-- Bad: Lock held for entire transaction
BEGIN;
SELECT * FROM items WHERE id = '123' FOR UPDATE;
-- ... long processing ...
UPDATE items SET status = 'done' WHERE id = '123';
COMMIT;

-- Good: Short transaction
UPDATE items SET status = 'done' WHERE id = '123' AND status = 'pending';
```

## 6. Data Access Patterns

### Supabase Client Best Practices

```typescript
// Filtering
const { data } = await supabase
  .from('items')
  .select('id, name, price')
  .eq('category', 'electronics')
  .order('price', { ascending: true })
  .limit(20);

// Joins
const { data } = await supabase
  .from('orders')
  .select(`
    id, total,
    user:users(name, email),
    items:order_items(quantity, product:products(name, price))
  `)
  .eq('status', 'completed');

// Upsert
const { data } = await supabase
  .from('items')
  .upsert({ id: '123', name: 'Updated', price: 29.99 });
```

### Pagination

```typescript
// Cursor-based (recommended for large datasets)
const { data } = await supabase
  .from('items')
  .select('*')
  .order('created_at', { ascending: false })
  .lt('created_at', lastItemDate)
  .limit(20);
```

## 7. Monitoring & Diagnostics

### Useful Queries

```sql
-- Long-running queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 seconds';

-- Table sizes
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Index usage
SELECT indexrelname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## 8. Advanced Features

### Realtime Subscriptions

```typescript
const channel = supabase
  .channel('orders')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'orders',
    filter: 'user_id=eq.123',
  }, (payload) => {
    console.log('New order:', payload.new);
  })
  .subscribe();
```

### Edge Functions

```typescript
// supabase/functions/hello/index.ts
Deno.serve(async (req) => {
  const { name } = await req.json();
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### Storage

```typescript
// Upload file
const { data } = await supabase.storage
  .from('avatars')
  .upload('user-123/avatar.png', file);

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl('user-123/avatar.png');
```
