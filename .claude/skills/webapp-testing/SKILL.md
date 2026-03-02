---
name: "Webapp Testing"
description: "Playwright によるWebアプリケーションのE2Eテスト実行・UIバリデーション・デバッグ自動化"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - testing
  - e2e
  - playwright
  - ui-validation
  - debugging
triggers:
  - "/webapp-testing"
  - "E2Eテスト"
model: sonnet
tools:
  - Task
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Webapp Testing

## Description
Playwright を使ってローカルWebアプリケーションをテスト・検証するスキル。
UIの視覚的バリデーション、機能テスト、アクセシビリティチェックを自動化する。

## Trigger
- `/webapp-testing`
- "Webアプリをテストして"
- "E2Eテストを実行して"
- "UIを検証して"

## Prerequisites
- Node.js がインストールされていること
- テスト対象のWebアプリがローカルで起動可能であること

## Workflow

### Phase 1: 環境検出
1. プロジェクトの技術スタックを検出（React, Vue, Next.js, etc.）
2. 既存のテスト設定を確認（playwright.config.ts 等）
3. Playwright がインストールされていなければセットアップ案内

### Phase 2: テスト設計
1. テスト対象ページ・機能の特定
2. テストシナリオの設計:
   - ユーザーフロー（ログイン、フォーム送信等）
   - レスポンシブデザイン確認
   - エラー状態の確認
   - アクセシビリティチェック

### Phase 3: テスト実装・実行
1. テストファイルの生成
2. テストの実行
3. 結果の収集・分析

### Phase 4: レポート
1. テスト結果のサマリー
2. 失敗したテストの詳細分析
3. スクリーンショット/トレースの確認
4. 修正提案

## テストパターン

### 基本的なページテスト
```typescript
import { test, expect } from '@playwright/test';

test('homepage loads correctly', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Expected Title/);
  await expect(page.locator('h1')).toBeVisible();
});
```

### フォーム操作テスト
```typescript
test('login form works', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

### レスポンシブテスト
```typescript
test('mobile layout', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 667 });
  await page.goto('/');
  await expect(page.locator('.mobile-menu')).toBeVisible();
  await expect(page.locator('.desktop-nav')).toBeHidden();
});
```

### アクセシビリティテスト
```typescript
import AxeBuilder from '@axe-core/playwright';

test('no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Playwright 設定テンプレート

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 12'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## AIDD 連携
- Phase 5 (Code) の TDD モードと併用可能
- code-implementer が生成したUIコンポーネントの視覚的検証に使用
- test-runner エージェントが E2E テスト結果を収集・分析

## References
- Playwright 公式: https://playwright.dev/
- Anthropic webapp-testing スキル: https://github.com/anthropics/skills
