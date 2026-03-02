# Commit & PR Standards

TDD・AIDD両スキル共通のコミット・PR規約。
orchestrator、pr-composer が参照する。

> このドキュメントは `.claude/common/` に配置された共通リソースです。

---

## Conventional Commits

> [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) 仕様に準拠。
> `commitlint` / `semantic-release` 等のツールと互換性あり。

### コミットメッセージ形式

**フルフォーマット**（scope・body・footerを含む場合）:
```
{type}({scope}): {description}

{body}

{footer}
```

**短縮形式**（scope・body・footerは省略可能）:
```
{type}: {description} ({context})
```

### Breaking Changes

破壊的変更がある場合は `!` を付与するか、フッターに `BREAKING CHANGE:` を記述:
```
feat!: remove deprecated API endpoint
feat(auth): change token format

BREAKING CHANGE: JWT tokens now use RS256 instead of HS256
```

### Type一覧

| Type | 用途 | 例 |
|---|---|---|
| feat | 新機能追加 | `feat: add user authentication (Issue #42)` |
| fix | バグ修正 | `fix: resolve race condition in order processing (#108)` |
| test | テスト追加・修正 | `test: add login edge case tests (Sprint-1 Task-3)` |
| refactor | リファクタリング | `refactor: extract validation logic (#42)` |
| docs | ドキュメント | `docs: add PRD for event search feature` |
| design | デザイン関連 | `design: define color palette and typography` |
| chore | 設定・ツール | `chore: update ESLint config` |
| style | コードスタイル | `style: fix indentation in auth module` |
| perf | パフォーマンス改善 | `perf: add database index for user lookup` |
| ci | CI/CD変更 | `ci: add E2E test step to GitHub Actions` |

### Context（コンテキスト）

スキルに応じたコンテキスト情報を付与:

| スキル | コンテキスト形式 | 例 |
|---|---|---|
| TDD | `(Issue #{number})` | `test: add auth tests (Issue #42)` |
| AIDD | `(Sprint-{N} Task-{M})` | `feat: implement login form (Sprint-1 Task-3)` |
| 共通 | `(#{number})` | `fix: resolve null pointer (#108)` |

---

## ブランチ命名規則

### TDDスキル
```
feat/issue-{number}-{short-description}
```
例: `feat/issue-42-add-user-authentication`

### AIDDスキル
```
feat/sprint-{N}-{short-description}
```
例: `feat/sprint-1-user-authentication`

### 共通パターン
```
{type}/{short-description}
```
例: `fix/login-redirect-loop`, `refactor/auth-module`

---

## PR（Pull Request）規約

### タイトル形式

| スキル | 形式 | 例 |
|---|---|---|
| TDD | `{type}: {description} (#{issue})` | `feat: Add user authentication (#42)` |
| AIDD | `[Sprint-{N}] {type}: {description}` | `[Sprint-1] feat: Add user authentication` |

- 70文字以内
- 詳細は本文で記述

### PR本文の必須セクション

全てのPRに含めるべき共通セクション:

```markdown
## 概要
<!-- 変更の概要を1-2文で -->

## 関連リンク
<!-- Issue、PRD、Sprint計画等へのリンク -->

## 変更内容
### 新規ファイル
- `path/to/file` - 説明
### 変更ファイル
- `path/to/file` - 変更内容

## テスト結果
- Unit テスト: {passed}/{total} パス
- Integration テスト: {passed}/{total} パス

## レビュー観点
<!-- レビュー時に特に注目してほしいポイント -->
```

### TDD固有セクション
```markdown
## TDD Cycle Results
### RED Phase
- {N} / {total} tests failed as expected
### GREEN Phase
- {N} / {total} tests passed
- Retry count: {N}/3
```

### AIDD固有セクション
```markdown
## AIレビュー結果
- レビュー実施: Yes/No
- 指摘事項: {N}件（対応済み）

## スクリーンショット
<!-- UI変更がある場合は必須 -->

## ロールバック手順
<!-- 問題発生時の戻し方 -->
```

---

## Issue自動クローズ

PR本文に以下のキーワードを含めることで、マージ時にIssueを自動クローズ:

```
Closes #{issue_number}
Fixes #{issue_number}
Resolves #{issue_number}
```

---

## トレーサビリティチェーン

全てのアーティファクトをリンクで繋ぐ:

```
PRD → Sprint → Task → PR → Commit
```

| アーティファクト | 参照方法 |
|---|---|
| PRD | `docs/PRD.md#{section}` |
| Sprint計画 | `docs/plans/sprint-plan.md#sprint-{N}` |
| 実装計画 | `docs/plans/sprint-{N}-implementation.md` |
| ADR | `docs/adr/ADR-{NNN}-{title}.md` |
| PR | PRタイトルにSprint/Issue番号 |
| Commit | メッセージにTask/Issue番号 |

---

## コミットの粒度

### 推奨
- 1コミット = 1論理的な変更
- テスト追加とテスト対象の実装は別コミット（TDD）
- リファクタリングは機能変更と別コミット

### TDDスキルでの標準コミット順序
1. `test: add tests for {feature}` - RED状態のテスト
2. `feat: implement {feature}` - GREEN状態の実装
3. `refactor: clean up {feature}` - リファクタリング（必要な場合）

### AIDDスキルでの標準コミット順序
1. `docs: add PRD / sprint plan` - ドキュメント
2. `design: define design system` - デザイン（該当する場合）
3. `feat: implement {feature} (Sprint-N Task-M)` - 実装
4. `test: add tests for {feature}` - テスト
