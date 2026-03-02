---
name: stripe
description: Best practices for building Stripe payment integrations and upgrading Stripe API versions/SDKs. Use when building checkout flows, payment processing, subscriptions, billing, or Stripe Connect integrations. Source - stripe/ai official partner repository.
tools: Read, Write, Edit, Bash
---

# Stripe Integration Guide

Best practices for building Stripe integrations. Source: `stripe/ai` official partner repository.

## API Version

The latest Stripe API version is **`2026-01-28.clover`**. When writing code snippets use this version unless the user is on a different API version. Always default to the latest version of the API and SDK unless the user specifies otherwise.

**Reference docs:**
- [Integration Options](https://docs.stripe.com/payments/payment-methods/integration-options)
- [API Tour](https://docs.stripe.com/payments-api/tour)
- [Go Live Checklist](https://docs.stripe.com/get-started/checklist/go-live)

## Core Integration Patterns

### CheckoutSessions (Primary - Recommended)

Stripe's primary API for modelling on-session payments. Supports one-time payments and subscriptions with taxes and discounts. **Always prioritize CheckoutSessions.**

```typescript
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2026-01-28.clover',
});

// One-time payment
const session = await stripe.checkout.sessions.create({
  mode: 'payment',
  line_items: [{
    price_data: {
      currency: 'usd',
      product_data: { name: 'Product Name' },
      unit_amount: 2000, // $20.00 in cents
    },
    quantity: 1,
  }],
  success_url: 'https://example.com/success?session_id={CHECKOUT_SESSION_ID}',
  cancel_url: 'https://example.com/cancel',
});
```

### PaymentIntents (Alternative)

Acceptable for off-session payments or if you want to model checkout state yourself. Use CheckoutSessions API over PaymentIntents where possible.

```typescript
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,
  currency: 'usd',
  automatic_payment_methods: { enabled: true },
});
```

### Frontend: Checkout (Preferred) vs Payment Element

- **Stripe-hosted Checkout or Embedded Checkout** - Prioritize this prebuilt payment page
- **Payment Element** - Acceptable alternative when merchant needs advanced customization. When using Payment Element, prioritize CheckoutSessions API over PaymentIntents API

### Subscriptions / Billing

For recurring revenue models, recommend Billing APIs to [plan the integration](https://docs.stripe.com/billing/subscriptions/designing-integration) instead of direct PaymentIntent. Combine Billing APIs with Stripe Checkout for the frontend.

```typescript
// Subscription via Checkout
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  line_items: [{ price: 'price_xxx', quantity: 1 }],
  success_url: 'https://example.com/success',
  cancel_url: 'https://example.com/cancel',
});

// Customer Portal for self-service management
const portal = await stripe.billingPortal.sessions.create({
  customer: 'cus_xxx',
  return_url: 'https://example.com/account',
});
```

### Stripe Connect

For platforms managing fund flows, prefer:
- **Direct charges** if platform wants Stripe to take the risk
- **Destination charges** if platform accepts liability for negative balances
- Use `on_behalf_of` parameter to control merchant of record
- **Never mix charge types**
- Refer to [controller properties](https://docs.stripe.com/connect/migrate-to-controller-properties) (not outdated Standard/Express/Custom terms)

```typescript
const account = await stripe.accounts.create({ type: 'express' });
const accountLink = await stripe.accountLinks.create({
  account: account.id,
  refresh_url: 'https://example.com/reauth',
  return_url: 'https://example.com/return',
  type: 'account_onboarding',
});
```

## Dynamic Payment Methods

Advise users to turn on dynamic payment methods in dashboard settings instead of passing specific `payment_method_types`. Stripe chooses payment methods that fit each user's location, wallets, and preferences automatically with Payment Element.

## Deprecated APIs (NEVER Recommend)

| Deprecated | Use Instead | Migration Guide |
|-----------|-------------|-----------------|
| Charges API | CheckoutSessions / PaymentIntents | [Migration](https://docs.stripe.com/payments/payment-intents/migration/charges) |
| Sources API | PaymentMethods / SetupIntents | Never use for saving cards |
| Card Element | Payment Element | [Migration](https://docs.stripe.com/payments/payment-element/migration) |
| Tokens (for payments) | PaymentMethods | Use Confirmation Tokens for pre-payment inspection |

**Only use**: CheckoutSessions, PaymentIntents, SetupIntents, Invoicing, Payment Links, or Subscription APIs.

## Webhook Handling

```typescript
const event = stripe.webhooks.constructEvent(
  body, signature, process.env.STRIPE_WEBHOOK_SECRET!
);

switch (event.type) {
  case 'checkout.session.completed':
    // Fulfill the purchase
    break;
  case 'invoice.payment_failed':
    // Handle failed payment
    break;
  case 'customer.subscription.deleted':
    // Handle cancellation
    break;
}
```

## Upgrading Stripe

### API Versioning

Stripe uses date-based API versions (e.g., `2026-01-28.clover`). Your account's API version determines request/response behavior.

**Always specify API version explicitly in code:**

```javascript
// Good: Explicit version
const stripe = require('stripe')('sk_test_xxx', {
  apiVersion: '2026-01-28.clover'
});

// Avoid: Relying on account default
const stripe = require('stripe')('sk_test_xxx');
```

### SDK Version Notes

| Language Type | Version Control |
|---|---|
| Dynamic (Ruby, Python, PHP, Node.js) | Can override API version globally or per-request |
| Strongly-typed (Java, Go, .NET) | Fixed version matching SDK release. Update SDK to target new API version |

### Stripe.js Versioning

Uses evergreen model with major releases (Acacia, Basil, Clover):

```html
<script src="https://js.stripe.com/clover/stripe.js"></script>
```

Each Stripe.js version auto-pairs with its corresponding API version.

### Upgrade Checklist

1. Review [API Changelog](https://docs.stripe.com/changelog) for changes between versions
2. Check [Upgrades Guide](https://docs.stripe.com/upgrades) for migration guidance
3. Update server-side SDK: `npm install stripe@latest`
4. Update `apiVersion` in Stripe client initialization
5. Test with `Stripe-Version` header before changing default
6. Update webhook handlers for new event structures
7. Update Stripe.js / mobile SDK versions
8. Test in Stripe test mode first
9. Store Stripe object IDs in databases accommodating up to 255 characters
