# Next.js 15 — App Router & Server Components

## Core Mental Model

Every component is a **Server Component by default** — runs on server, zero JS sent to browser.
Add `"use client"` only when you need interactivity, browser APIs, or React hooks.

```
app/
├── layout.tsx          ← Server Component (shared shell)
├── page.tsx            ← Server Component (route entry)
├── loading.tsx         ← Streaming skeleton
├── error.tsx           ← Error boundary (must be "use client")
└── _components/
    ├── ServerCard.tsx  ← Server Component (data fetching)
    └── LikeButton.tsx  ← "use client" (interactivity)
```

## Data Fetching

```tsx
// Server Component — fetch directly, no useEffect
async function ProductPage({ params }: { params: { id: string } }) {
  const product = await db.product.findUnique({ where: { id: params.id } })
  return <ProductDetail product={product} />
}

// Parallel fetching
async function Dashboard() {
  const [user, orders] = await Promise.all([
    fetchUser(),
    fetchOrders(),
  ])
  return <DashboardView user={user} orders={orders} />
}
```

## Caching Strategy

```tsx
// Static (default) — cached at build time
fetch('https://api.example.com/products')

// Revalidate every N seconds (ISR)
fetch('https://api.example.com/products', { next: { revalidate: 60 } })

// No cache — always fresh
fetch('https://api.example.com/cart', { cache: 'no-store' })
```

## Server Actions (React 19 + Next.js 15)

```tsx
// app/actions.ts
'use server'
export async function createOrder(formData: FormData) {
  const item = formData.get('item') as string
  await db.order.create({ data: { item } })
  revalidatePath('/orders')
}

// app/page.tsx (Server Component)
import { createOrder } from './actions'
export default function Page() {
  return (
    <form action={createOrder}>
      <input name="item" />
      <button type="submit">Order</button>
    </form>
  )
}
```

## React 19 Hooks in Next.js

```tsx
'use client'
import { useActionState, useOptimistic, useFormStatus } from 'react'

// useActionState — replaces useFormState
const [state, formAction, isPending] = useActionState(createOrder, null)

// useOptimistic — instant UI update before server confirms
const [optimisticItems, addOptimistic] = useOptimistic(items)

// useFormStatus — inside form child components
function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Saving...' : 'Save'}</button>
}
```

## Streaming with Suspense

```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<Skeleton />}>
        <SlowDataComponent />  {/* streams in when ready */}
      </Suspense>
    </div>
  )
}
```

## Route Handlers (API Routes)

```tsx
// app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(req: NextRequest) {
  const products = await db.product.findMany()
  return NextResponse.json(products)
}

export async function POST(req: NextRequest) {
  const body = await req.json()
  const product = await db.product.create({ data: body })
  return NextResponse.json(product, { status: 201 })
}
```

## Middleware

```tsx
// middleware.ts (root level)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
}
```

## Folder Structure (Production)

```
app/
├── (auth)/             ← Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── (dashboard)/
│   ├── layout.tsx      ← Dashboard shell
│   └── orders/page.tsx
├── api/
│   └── webhooks/route.ts
└── globals.css

components/
├── ui/                 ← Reusable primitives (Button, Input)
└── features/           ← Feature-specific components

lib/
├── db.ts               ← Prisma/Drizzle client
├── auth.ts             ← Auth helpers
└── utils.ts
```

## Rules
- Server Components fetch data; Client Components handle interaction
- Never import server-only code into Client Components
- Use `next/image` for all images (auto-optimization)
- Use `next/font` for fonts (zero layout shift)
- Prefer `loading.tsx` over manual loading states
