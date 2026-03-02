# Agent Communication Protocol

TDD・AIDD両スキル共通のエージェント間通信プロトコル。
orchestrator が参照する。

> このドキュメントは `.claude/common/` に配置された共通リソースです。

---

## ワークフローコンテキスト

各エージェント間でデータを受け渡すための標準スキーマ。

### 基本構造

```yaml
workflow_context:
  # メタデータ（共通）
  meta:
    skill: tdd|aidd
    phase: string          # 現在のフェーズ名
    iteration: number      # イテレーション回数
    started_at: string     # 開始時刻
    branch: string         # 作業ブランチ名

  # フェーズ出力（スキル固有）
  outputs:
    phase_name:
      status: success|failure|partial
      data: object         # フェーズ固有のデータ
      files: string[]      # 生成/変更されたファイル
      errors: string[]     # エラー情報（あれば）
```

---

## フェーズ管理パターン

### 順次実行パターン

```
Phase A → Phase B → Phase C
```

各Phaseの出力を次のPhaseの入力として渡す。
前Phaseが失敗した場合は後続Phaseに進まない。

### 並列実行パターン

```
Phase A ──┐
           ├──→ Phase C（A・B両方の結果を入力）
Phase B ──┘
```

独立したPhaseをTaskツールで同時起動。
両方の完了を待機し、結果を統合して次Phaseに渡す。

### イテレーションパターン

```
Phase A → Phase B → Phase C（レビュー）
                        │
                        ├── 合格 → Phase D
                        └── 不合格 → Phase A に戻る（最大N回）
```

レビューフェーズで品質ゲートを設定。
不合格の場合は前フェーズに戻りイテレーション。

---

## エラーハンドリング標準

### リトライポリシー

| エラー種別 | 最大リトライ | 対応 |
|---|---|---|
| エージェント実行失敗 | 2回 | 同じエージェントを再実行 |
| テスト失敗（GREEN未達） | 3回 | 失敗情報を渡して再実装 |
| レビュー不合格 | 3回 | フィードバックを渡して修正 |
| 外部サービスエラー | 2回 | エクスポネンシャルバックオフ |
| 環境エラー | 0回 | ユーザーに報告して中断 |

### リトライ時のデータ受け渡し

```yaml
retry_context:
  attempt: number          # 現在の試行回数
  max_attempts: number     # 最大試行回数
  previous_errors:
    - attempt: number
      error_type: string
      error_message: string
      failed_items: string[]  # 失敗したテスト名等
      feedback: string        # レビュアーからのフィードバック
```

### リトライ上限超過時の対応

1. 部分的な成果物で次フェーズに進む
2. 未完了項目を明記してPRを作成
3. ユーザーに状況を報告し判断を仰ぐ

---

## 品質ゲート

各フェーズの完了条件を定義:

### 共通ゲート

| ゲート | 条件 | 対応 |
|---|---|---|
| テスト全パス | 全テストがPASS | 未達→リトライ |
| lint/typecheck | エラーゼロ | 未達→自動修正を試行 |
| セキュリティ | critical issue ゼロ | 未達→即修正 |

### TDD固有ゲート

| ゲート | 条件 |
|---|---|
| RED確認 | 全テストがFAIL |
| GREEN確認 | 全テストがPASS |

### AIDD固有ゲート

| ゲート | 条件 |
|---|---|
| PRD完成度 | 全セクションが埋まっている |
| レビュー通過 | critical issue ゼロ、major 3件以下 |
| スプリント完了 | 完了条件を全て満たす |

---

## ドキュメント永続化ルール

Planning-with-files原則に基づき、重要な成果物はファイルに永続化する:

```
コンテキストウィンドウ = RAM（揮発性、制限あり）
ファイルシステム = ディスク（永続、無制限）
→ 重要なことはすべてファイルに書き出す
```

### 保存先規約

| 成果物 | 保存先 |
|---|---|
| PRD | `docs/PRD.md` |
| ユーザーフロー図 | `docs/user-flows.md` |
| 状態遷移図 | `docs/state-diagrams.md` |
| デザインシステム | `docs/design-system.md` |
| スプリント計画 | `docs/plans/sprint-plan.md` |
| 実装計画 | `docs/plans/sprint-{N}-implementation.md` |
| ADR | `docs/adr/ADR-{NNN}-{title}.md` |
| レビュー結果 | `docs/review-results.md` |

---

## Taskツール起動パターン

### 並列起動（Phase 1の分析等）
```
orchestratorが1回の応答で複数のTaskを同時に呼び出す:

Task 1: agent-a
  - subagent_type: 適切なタイプ
  - model: sonnet|opus
  - prompt: agent-a.mdの指示に従い処理

Task 2: agent-b
  - subagent_type: 適切なタイプ
  - model: sonnet|opus
  - prompt: agent-b.mdの指示に従い処理
```

### 順次起動（依存のあるPhase）
```
Task → 結果取得 → 次のTask起動 → 結果取得 → ...
```

### モデル選択基準

| 基準 | sonnet | opus |
|---|---|---|
| 分析・検出・実行 | 高速応答が必要 | - |
| 設計・実装・判断 | - | 高品質が必要 |
| レビュー | 定型チェック | 深い分析 |
| PR作成 | テンプレート適用 | - |
