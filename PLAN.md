# TDD GitHub Automation Skill - ソリューションアーキテクチャ計画

## 概要

GitHub Issueをトリガーに、TDD（テスト駆動開発）の原則に従って自動的にコードを実装し、
PRを作成するClaude Code Skillシステム。

---

## ディレクトリ構成

```
.claude/
└── skills/
    └── tdd-github-automation/
        ├── SKILL.md                          # メインワークフロー定義
        ├── agents/
        │   ├── issue-analyzer.md             # Issue分析 (sonnet)
        │   ├── test-framework-detector.md    # テストFW検出 (sonnet)
        │   ├── test-designer.md              # テスト設計 (opus)
        │   ├── test-implementer.md           # テスト実装 (opus)
        │   ├── feature-implementer.md        # 機能実装 (opus)
        │   ├── test-runner.md                # テスト実行 (sonnet)
        │   ├── orchestrator.md               # オーケストレーター (opus)
        │   └── pr-composer.md                # PR作成 (sonnet)
        ├── references/
        │   ├── test-framework-patterns.md    # テストFWパターン集
        │   ├── tdd-principles.md             # TDD原則ガイド
        │   └── parallel-strategy.md          # 並列実行戦略
        └── templates/
            ├── pr-template.md                # PRテンプレート
            └── test-report.md                # テストレポートテンプレート
```

---

## フェーズ別実装計画

### Phase 1: 基盤設計（SKILL.md + Orchestrator）

**目的**: ワークフロー全体の定義とエージェント間の連携ロジック

#### SKILL.md（メインエントリーポイント）
- スキルのトリガー条件定義（GitHub Issue URLの入力）
- ワークフローの全体フロー定義
- エージェント呼び出し順序と依存関係
- エラーハンドリングとリカバリー戦略

#### orchestrator.md（opus）
- 全エージェントのライフサイクル管理
- フェーズ間のデータ受け渡し
- 並列実行可能なタスクの判定
- 失敗時のリトライ・フォールバック制御

### Phase 2: 分析系エージェント

#### issue-analyzer.md（sonnet）
- GitHub Issue本文の構造化解析
- 要件の抽出（機能要件 / 非機能要件）
- 受入基準（Acceptance Criteria）の特定
- 影響範囲の推定
- **出力**: 構造化された要件ドキュメント

#### test-framework-detector.md（sonnet）
- リポジトリの既存テストインフラ検出
  - package.json / requirements.txt / pom.xml 等のスキャン
  - 既存テストファイルのパターン分析
  - CI/CD設定からのテストコマンド抽出
- 対応フレームワーク: Jest, Vitest, pytest, JUnit, Go testing, RSpec 等
- **出力**: 検出されたフレームワーク情報 + 推奨設定

### Phase 3: TDD実装系エージェント

#### test-designer.md（opus）
- 要件からテストケースの設計
- テストの分類（Unit / Integration / E2E）
- エッジケースとバウンダリケースの網羅
- テストの優先度付け
- **出力**: テスト設計書（テストケース一覧 + 期待結果）

#### test-implementer.md（opus）
- テスト設計書に基づくテストコードの実装
- 検出されたフレームワークに合わせたコード生成
- モック/スタブの適切な使用
- テストヘルパー/フィクスチャの作成
- **出力**: 実行可能なテストファイル群（最初はすべてFAIL）

#### feature-implementer.md（opus）
- RED状態のテストをGREENにする最小限の実装
- 既存コードベースとの整合性維持
- SOLID原則の遵守
- リファクタリング（GREEN後のREFACTOR段階）
- **出力**: テストを通過する実装コード

### Phase 4: 検証・出力系エージェント

#### test-runner.md（sonnet）
- テストの実行と結果の収集
- カバレッジレポートの生成
- 失敗テストの分析と原因特定
- feature-implementerへのフィードバックループ制御
- **出力**: テスト実行結果レポート

#### pr-composer.md（sonnet）
- PRタイトル・説明文の自動生成
- 変更内容のサマリー作成
- テスト結果の埋め込み
- レビューポイントの明示
- Issue参照の自動リンク
- **出力**: PR作成（gh pr create）

---

## モデル選択戦略

| エージェント | モデル | 選択理由 |
|---|---|---|
| issue-analyzer | sonnet | テキスト解析は構造化タスク、高速処理を優先 |
| test-framework-detector | sonnet | パターンマッチング主体、速度重視 |
| test-designer | opus | 要件→テスト設計は高度な推論が必要 |
| test-implementer | opus | 正確なコード生成に高品質モデルが必要 |
| feature-implementer | opus | 複雑な実装ロジック、既存コードとの整合性 |
| test-runner | sonnet | コマンド実行と結果解析、速度重視 |
| orchestrator | opus | 全体制御の判断に高度な推論が必要 |
| pr-composer | sonnet | テンプレートベースの文書生成、速度重視 |

**コスト最適化**: opus（高推論）を本当に必要な箇所のみに使用し、
sonnet（高速・低コスト）で処理できるタスクはsonnetに任せる。

---

## ワークフロー（実行順序）

```
[GitHub Issue URL入力]
        │
        ▼
┌─────────────────────┐
│   orchestrator      │ ← 全体制御
│      (opus)         │
└────────┬────────────┘
         │
    ┌────┴────┐ (並列実行可能)
    ▼         ▼
┌────────┐ ┌──────────────────┐
│ issue  │ │ test-framework   │
│analyzer│ │ detector         │
│(sonnet)│ │ (sonnet)         │
└───┬────┘ └────────┬─────────┘
    │               │
    └───────┬───────┘
            ▼
    ┌───────────────┐
    │ test-designer │
    │    (opus)     │
    └───────┬───────┘
            ▼
    ┌────────────────┐
    │test-implementer│
    │    (opus)      │
    └───────┬────────┘
            ▼
    ┌───────────────┐
    │  test-runner   │ ← RED確認
    │   (sonnet)     │
    └───────┬────────┘
            ▼
  ┌──────────────────┐
  │feature-implementer│
  │     (opus)        │
  └────────┬──────────┘
           ▼
    ┌───────────────┐
    │  test-runner   │ ← GREEN確認
    │   (sonnet)     │◄──── 失敗時はfeature-implementerに戻る
    └───────┬────────┘      (最大3回リトライ)
            ▼
    ┌───────────────┐
    │  pr-composer  │
    │   (sonnet)    │
    └───────┬───────┘
            ▼
    [PR作成完了]
```

---

## リファレンスドキュメント

### test-framework-patterns.md
- 各言語/フレームワークのテストパターン集
- ファイル命名規則、ディレクトリ構造の慣例
- よく使うアサーション・マッチャーのリファレンス

### tdd-principles.md
- Red-Green-Refactorサイクルの詳細定義
- テストファースト原則の実践ガイドライン
- アンチパターンと回避策

### parallel-strategy.md
- 並列実行可能なフェーズの定義
- リソース競合の回避策
- 依存関係グラフの管理方法

---

## テンプレート

### pr-template.md
- Issue参照セクション
- 変更概要セクション
- TDDサイクル結果セクション
- テストカバレッジセクション
- レビュー観点セクション

### test-report.md
- テスト実行結果サマリー
- カバレッジ情報
- 失敗テスト詳細
- パフォーマンス指標

---

## 実装優先順位

1. **SKILL.md** - エントリーポイント（これがないとスキルとして動作しない）
2. **orchestrator.md** - 全体制御（各エージェントを統合するコア）
3. **issue-analyzer.md** - 最初の入力処理
4. **test-framework-detector.md** - 環境検出（issue-analyzerと並列）
5. **references/tdd-principles.md** - TDD原則（設計系エージェントの参照元）
6. **test-designer.md** - テスト設計
7. **test-implementer.md** - テスト実装
8. **test-runner.md** - テスト実行
9. **feature-implementer.md** - 機能実装
10. **references/test-framework-patterns.md** - FWパターン集
11. **references/parallel-strategy.md** - 並列戦略
12. **pr-composer.md** - PR作成
13. **templates/pr-template.md** - PRテンプレート
14. **templates/test-report.md** - レポートテンプレート
