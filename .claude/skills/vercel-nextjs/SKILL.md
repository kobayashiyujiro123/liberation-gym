---
name: vercel-nextjs
description: Vercel / Next.js development guide covering cache components, Partial Prerendering (PPR), deployment optimization, and documentation updates. Use when building Next.js applications or deploying to Vercel. Source - vercel/next.js official partner repository.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Vercel / Next.js Development Guide

Best practices for Next.js development and Vercel deployment. Source: `vercel/next.js` official partner repository.

## Cache Components & Partial Prerendering (PPR)

### `'use cache'` Directive

Mark components or functions as cacheable:

```typescript
// Cached component
async function CachedProducts() {
  'use cache';
  const products = await db.query('SELECT * FROM products');
  return <ProductList products={products} />;
}

// Cached function
async function getUser(id: string) {
  'use cache';
  return await db.users.findUnique({ where: { id } });
}
```

### Cache Lifetime Control

```typescript
import { cacheLife } from 'next/cache';

async function DashboardStats() {
  'use cache';
  cacheLife('minutes'); // Revalidate every few minutes

  const stats = await fetchStats();
  return <StatsCard stats={stats} />;
}
```

**Cache profiles:**
- `'seconds'` - Very short cache
- `'minutes'` - Short cache (default)
- `'hours'` - Medium cache
- `'days'` - Long cache
- `'weeks'` - Very long cache
- `'max'` - Indefinite cache

### Cache Tags & Revalidation

```typescript
import { cacheTag } from 'next/cache';

async function ProductDetails({ id }: { id: string }) {
  'use cache';
  cacheTag(`product-${id}`);

  const product = await db.products.findUnique({ where: { id } });
  return <Product product={product} />;
}

// Server Action to revalidate
'use server';
import { revalidateTag } from 'next/cache';

async function updateProduct(id: string, data: ProductData) {
  await db.products.update({ where: { id }, data });
  revalidateTag(`product-${id}`);
}
```

### Partial Prerendering (PPR)

Combine static and dynamic content in a single route:

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    ppr: true,
  },
};

// page.tsx
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      {/* Static shell - prerendered at build time */}
      <Header />
      <Sidebar />

      {/* Dynamic content - streamed on request */}
      <Suspense fallback={<Loading />}>
        <DynamicContent />
      </Suspense>
    </div>
  );
}
```

---

## App Router Patterns

### Server Components (Default)

```typescript
// app/page.tsx - Server Component by default
export default async function Page() {
  const data = await fetch('https://api.example.com/data');
  return <div>{JSON.stringify(data)}</div>;
}
```

### Client Components

```typescript
'use client';

import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Server Actions

```typescript
// app/actions.ts
'use server';

export async function createItem(formData: FormData) {
  const name = formData.get('name') as string;
  await db.items.create({ data: { name } });
  revalidatePath('/items');
}
```

### Route Handlers

```typescript
// app/api/items/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  const items = await db.items.findMany();
  return NextResponse.json(items);
}

export async function POST(request: Request) {
  const body = await request.json();
  const item = await db.items.create({ data: body });
  return NextResponse.json(item, { status: 201 });
}
```

---

## Deployment Optimization

### Image Optimization

```typescript
import Image from 'next/image';

export default function Avatar() {
  return (
    <Image
      src="/avatar.jpg"
      alt="User avatar"
      width={64}
      height={64}
      priority // For above-the-fold images
    />
  );
}
```

### Metadata

```typescript
// app/layout.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: { default: 'My App', template: '%s | My App' },
  description: 'My application description',
  openGraph: { images: ['/og-image.png'] },
};
```

### Environment Variables

```bash
# .env.local (not committed)
DATABASE_URL=postgres://...
NEXT_PUBLIC_API_URL=https://api.example.com  # Available client-side
```

### Vercel Configuration

```json
// vercel.json
{
  "framework": "nextjs",
  "buildCommand": "next build",
  "regions": ["iad1"],
  "crons": [{
    "path": "/api/cron",
    "schedule": "0 * * * *"
  }]
}
```

---

## Best Practices

### Performance
- Use Server Components by default
- Only use `'use client'` when needed (interactivity)
- Leverage `'use cache'` for expensive data fetches
- Use `<Suspense>` boundaries for streaming
- Optimize images with `next/image`

### Data Fetching
- Fetch data in Server Components (no client waterfalls)
- Use parallel data fetching with `Promise.all()`
- Implement proper loading states with `loading.tsx`
- Use error boundaries with `error.tsx`

### Security
- Never expose secrets in Client Components
- Use Server Actions for mutations
- Validate all inputs server-side
- Set proper CORS headers in API routes
