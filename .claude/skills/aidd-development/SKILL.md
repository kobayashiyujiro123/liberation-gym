---
name: "AIDD Development"
description: "AI駆動開発の完全ワークフロー。要件定義→デザイン→計画→実装→コミットを専門エージェント群で自動化・高品質化"
version: "2.0.0"
author: "AI-Engineer"
tags:
  - development
  - workflow
  - tdd
  - ai-driven
  - full-stack
triggers:
  - "/aidd"
  - "/tdd"
  - "AI開発"
model: opus
tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# AIDD (AI Driven Development) Skill

## Description
AI駆動開発の完全ワークフローを管理する統合スキル。
要件定義 → デザイン → 計画 → 実装 → コミットの全フェーズを
専門エージェント群で自動化・高品質化する。

TDD（テスト駆動開発）を内包しており、Phase 5（Code）の実装戦略として
TDDモードを選択できる。また、GitHub Issue URLを直接指定して
TDDワークフローのみを実行するショートカットも提供する。

## Trigger
以下のいずれかでトリガー:

### AIDD フルワークフロー
- "このプロダクトを開発して" + 要件/アイデア
- "/aidd {アイデアまたはPRD}"
- "AIDD で開発を開始して"
- GitHub Issue URL + "AIDDで実装して"

### TDD ショートカット（Phase 5 のみ直接実行）
- `https://github.com/{owner}/{repo}/issues/{number}`
- "このIssueを実装して" + URL
- "/tdd {Issue URL}"

## Core Principle
> AI駆動開発の成否は「要件定義の質」で8割決まる。
> ツールの使い方より、まず「何を作るか」を明確にすることに時間を使う。

## Workflow

```
Phase 1: Explore（探索・要件定義）── 並列実行可能
├── requirements-interviewer (opus)  → ユーザーへのインタビューで要件を深掘り
├── prd-composer (opus)              → PRDドキュメントの生成
└── flow-visualizer (sonnet)         → ユーザーフロー図・状態遷移図の生成

Phase 2: Design（デザイン）
├── design-system-builder (sonnet)   → デザインシステム（カラー・タイポ・コンポーネント）
└── ui-prototyper (opus)             → UIプロトタイプ・ワイヤーフレーム生成

Phase 3: Review（批判的レビュー）
└── critical-reviewer (opus)         → PRD・デザインの批判的レビュー

Phase 4: Plan（スプリント計画）
├── sprint-planner (opus)            → スプリント分割・タスク分解
└── implementation-planner (opus)    → 各スプリントの詳細実装計画

Phase 5: Code（実装）── スプリント単位で繰り返し
├── [標準モード]
│   ├── code-implementer (opus)      → コード実装
│   ├── code-reviewer (sonnet)       → コードレビュー（別コンテキスト）
│   └── test-runner (sonnet)         → テスト実行・検証
│
└── [TDDモード] ── Issue単体でも直接実行可能
    ├── tdd/orchestrator (opus)          → TDDサブワークフロー制御
    ├── tdd/issue-analyzer (sonnet)      → Issue要件の構造化
    ├── tdd/test-framework-detector (sonnet) → テストFW検出
    ├── tdd/test-designer (opus)         → テストケース設計
    ├── tdd/test-implementer (opus)      → テストコード生成（RED）
    ├── tdd/feature-implementer (opus)   → 最小実装（GREEN）
    ├── tdd/test-runner (sonnet)         → RED/GREEN確認
    └── tdd/pr-composer (sonnet)         → TDD用PR作成

Phase 6: Commit（コミット・PR作成）
└── pr-composer (sonnet)             → PR作成・トレーサビリティ確保
```

### TDD サブワークフロー（Phase 5 内）
```
Issue URL
  │
  ├── 分析（並列） ─┬─ issue-analyzer ──────┐
  │                 └─ test-framework-detector ┤
  │                                            ▼
  ├── テスト設計 ─── test-designer ────────────┤
  │                                            ▼
  ├── RED ───────── test-implementer → test-runner(RED) ──┤
  │                                                        ▼
  ├── GREEN ─────── feature-implementer → test-runner(GREEN) ──┤
  │                                      （失敗時リトライ×3）     ▼
  └── PR ────────── pr-composer → PR作成完了
```

### 全体制御
- orchestrator (opus) が全フェーズを統括
- Explore→Design→Review は要件が固まるまでイテレーション可能
- Plan→Code→Commit はスプリント単位で繰り返し
- TDDモードでは tdd/orchestrator がPhase 5内のサブフローを制御

## Agent Definitions

### AIDD コアエージェント

| Agent | Model | Phase | File |
|---|---|---|---|
| orchestrator | opus | 全体 | agents/orchestrator.md |
| requirements-interviewer | opus | Explore | agents/requirements-interviewer.md |
| prd-composer | opus | Explore | agents/prd-composer.md |
| flow-visualizer | sonnet | Explore | agents/flow-visualizer.md |
| design-system-builder | sonnet | Design | agents/design-system-builder.md |
| ui-prototyper | opus | Design | agents/ui-prototyper.md |
| critical-reviewer | opus | Review | agents/critical-reviewer.md |
| sprint-planner | opus | Plan | agents/sprint-planner.md |
| implementation-planner | opus | Plan | agents/implementation-planner.md |
| code-implementer | opus | Code | agents/code-implementer.md |
| code-reviewer | sonnet | Code | agents/code-reviewer.md |
| pr-composer | sonnet | Commit | agents/pr-composer.md |

### TDD サブエージェント（Phase 5: Code 内）

| Agent | Model | TDD Phase | File |
|---|---|---|---|
| tdd/orchestrator | opus | 全体制御 | agents/tdd/orchestrator.md |
| tdd/issue-analyzer | sonnet | 分析 | agents/tdd/issue-analyzer.md |
| tdd/test-framework-detector | sonnet | 分析 | agents/tdd/test-framework-detector.md |
| tdd/test-designer | opus | テスト設計 | agents/tdd/test-designer.md |
| tdd/test-implementer | opus | RED | agents/tdd/test-implementer.md |
| tdd/feature-implementer | opus | GREEN | agents/tdd/feature-implementer.md |
| tdd/test-runner | sonnet | RED/GREEN確認 | agents/tdd/test-runner.md |
| tdd/pr-composer | sonnet | PR作成 | agents/tdd/pr-composer.md |

## References
- references/aidd-principles.md - AIDD原則とベストプラクティス
- references/prompt-patterns.md - 効果的なプロンプトパターン集
- references/tdd-principles.md - TDD原則・Red-Green-Refactor
- references/test-framework-patterns.md - 言語別テストパターン集
- references/parallel-strategy.md - 並列実行戦略ガイド
- references/lsp-integration.md - LSP連携ガイド（型チェック・lint自動実行）
- references/security-checklist.md - セキュリティリダイレクト（→ common/security-baseline.md + owasp-security に統合）

## Common References (共通レイヤー)
- ../../common/security-baseline.md - セキュリティ最小基準
- ../../common/testing-framework.md - テスト原則・戦略ガイド
- ../../common/commit-standards.md - コミット・PR規約
- ../../common/agent-protocol.md - エージェント間通信プロトコル
- ../../common/code-review-checklist.md - コードレビュー基準

## Templates
- templates/prd-template.md - PRDテンプレート
- templates/sprint-plan-template.md - スプリント計画テンプレート
- templates/adr-template.md - ADR（設計判断記録）テンプレート
- templates/pr-template.md - PR本文テンプレート（AIDD用）
- templates/tdd-pr-template.md - PR本文テンプレート（TDD用）
- templates/test-strategy-template.md - テスト戦略テンプレート
- templates/test-report.md - テストレポートテンプレート
- templates/design-review-checklist.md - デザインレビューチェックリスト

## Configuration

### 思考深度キーワード
| キーワード | 思考深度 | 使用場面 |
|---|---|---|
| think | 標準 | 一般的な設計判断 |
| think hard | 深い | 複雑なアーキテクチャ決定 |
| think harder | より深い | 難しいバグの原因分析 |
| ultrathink | 最大 | 重大な設計変更、移行計画 |

### スプリント設定
- 1スプリント: 3-5日（実稼働1日2-3時間想定）
- 1タスク: 30分〜2時間で完了可能な粒度
- タスクは独立してテスト・コミット可能な単位

### コミット規則
- 要件定義: `docs: {description}`
- デザイン: `design: {description}`
- 機能実装: `feat: {description} (Sprint-N Task-M)`
- テスト追加: `test: {description} (Issue #{number})`
- バグ修正: `fix: {description}`
- リファクタ: `refactor: {description}`

### TDD リトライ設定
- テスト失敗時の最大リトライ回数: 3
- リトライ間のクールダウン: なし（即座に再実装）

### TDD ブランチ命名規則
- パターン: `feat/issue-{number}-{short-description}`
- 例: `feat/issue-42-add-user-authentication`

### トレーサビリティ
```
PRD → Sprint → Task → PR → Commit
全てをリンクで繋ぐ
```

### 軌道修正ツール
| 操作 | 効果 |
|---|---|
| Esc | 中断（コンテキスト保持） |
| Esc x 2 | 履歴に戻る |
| /clear | コンテキストをリセット |
| /rewind | 会話を巻き戻す |
