# テスト戦略ドキュメント

## 1. テストピラミッド構成

| レイヤー | 割合 | 対象 | ツール |
|---------|------|------|--------|
| Unit | 70% | 関数、クラス、モジュール | [Jest/Vitest/pytest等] |
| Integration | 20% | API、DB境界、外部サービス連携 | [Supertest/pytest + DB等] |
| E2E | 10% | ユーザーフロー全体 | [Playwright/Cypress等] |

---

## 2. 各レイヤーの方針

### Unit テスト
- **対象**: ビジネスロジック、ユーティリティ関数、バリデーション
- **カバレッジ目標**: 80%以上（重要モジュールは90%以上）
- **モック方針**: 外部依存は全てモック化
- **命名規則**: `{function名}__{条件}__{期待結果}`

### Integration テスト
- **対象**:
  - DB操作（CRUD、トランザクション）
  - 外部API呼び出し
  - 認証・認可フロー
- **環境**: テスト用DB（Docker等）を使用
- **モック方針**: 外部APIのみモック、DBは実物

### E2E テスト
- **最小セット（必須）**:
  - [ ] ユーザー登録・ログイン・ログアウト
  - [ ] メインの価値提供フロー
  - [ ] 課金・決済に関わるフロー（該当する場合）
  - [ ] データ作成・更新・削除の基本フロー
- **実行タイミング**: PR作成時、main/developマージ前

---

## 3. テスト環境

| 環境 | 用途 | DB | 外部API |
|------|------|-----|---------|
| local | Unit/Integration | テスト用DB | モック |
| CI | 全テスト | テスト用DB (Docker) | モック |
| staging | E2E | ステージング用DB | サンドボックス |

---

## 4. テストデータ戦略

| 方法 | 用途 |
|------|------|
| Factory/Fixture | Unit/Integrationテストのテストデータ生成 |
| Seed Data | E2Eテスト用の初期データ |
| Cleanup | 各テスト後のデータクリーンアップ |

---

## 5. AIが書いたテストのレビュー観点

- [ ] テストが**要件（PRD）を満たしているか**
- [ ] **境界条件**をカバーしているか（空、最大値、異常値）
- [ ] **偽陽性**がないか（常にパスするテスト）
- [ ] **偽陰性**がないか（本来失敗すべきケースがパスする）
- [ ] モックが**過剰**でないか（実際の挙動と乖離）
- [ ] テストの**可読性**は十分か
- [ ] テスト名が「何を」「どういう条件で」「どうなるべきか」を表現しているか

---

## 6. CI設定

```yaml
# GitHub Actions
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - run: npm ci
    - run: npm run lint
    - run: npm run typecheck
    - run: npm run test:unit
    - run: npm run test:integration
    - run: npm run test:e2e
```

---

## 7. テストコマンド

| コマンド | 用途 |
|----------|------|
| `npm run test` | 全テスト実行 |
| `npm run test:unit` | Unitテストのみ |
| `npm run test:integration` | Integrationテストのみ |
| `npm run test:e2e` | E2Eテストのみ |
| `npm run test:coverage` | カバレッジ付き実行 |
| `npm run test -- --testPathPattern={pattern}` | 特定ファイルのみ |
