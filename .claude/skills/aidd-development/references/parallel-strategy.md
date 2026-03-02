# Parallel Execution Strategy

エージェント間の並列実行戦略ガイド。
orchestratorが各フェーズの実行計画を立てる際に参照する。

---

## 依存関係グラフ

```
issue-analyzer ─────────────┐
                             ├──→ test-designer ──→ test-implementer ──→ test-runner(RED)
test-framework-detector ────┘                                                │
                                                                             ▼
                                                              feature-implementer ──→ test-runner(GREEN)
                                                                                          │
                                                                                          ▼
                                                                                    pr-composer
```

## 並列実行可能なペア

### Phase 1: 分析フェーズ
```
並列実行可能:
├── issue-analyzer (sonnet)
└── test-framework-detector (sonnet)
```

**理由**: 両エージェントの入力は独立（Issue情報 vs リポジトリ構造）
**実装**: Taskツールで2つのサブエージェントを同時に起動

### Phase 2以降: 順次実行
Phase 2〜5は前のフェーズの出力に依存するため、順次実行が必須。

---

## Task起動パターン

### 並列パターン（Phase 1）
```
orchestratorが1回の応答で2つのTaskを同時に呼び出す:

Task 1: issue-analyzer
  - subagent_type: general-purpose
  - model: sonnet
  - prompt: issue-analyzer.mdの指示に従いIssueを分析

Task 2: test-framework-detector
  - subagent_type: Explore
  - model: sonnet (haiku)
  - prompt: test-framework-detector.mdの指示に従いFWを検出
```

### 順次パターン（Phase 2〜5）
```
各Taskの完了を待ってから次のTaskを起動:

Task → 結果取得 → 次のTask起動 → 結果取得 → ...
```

---

## リソース競合の回避

### ファイルシステム競合
- Phase 3（テスト実装）とPhase 4（機能実装）は同じファイルを
  変更する可能性があるため、必ず順次実行する
- テストファイルと実装ファイルの命名が衝突しないよう注意

### Git競合
- コミットは各Phase完了時にorchestrator側で実行
- 並列Phase（Phase 1）ではファイル変更を行わないため
  Git競合は発生しない

### テスト実行競合
- test-runnerは排他的に実行する（並列実行しない）
- テスト実行中に他のエージェントがファイルを変更しない

---

## エージェント間データフロー

### Phase 1 → Phase 2

```yaml
# issue-analyzerの出力 → test-designerの入力
requirements_doc:
  functional_requirements: [...]
  acceptance_criteria: [...]
  constraints: [...]

# test-framework-detectorの出力 → test-designerの入力
framework_info:
  test_framework: {...}
  test_structure: {...}
  test_utilities: {...}
```

### Phase 2 → Phase 3

```yaml
# test-designerの出力 → test-implementerの入力
test_design_doc:
  test_structure: [...]
  shared_setup: {...}
  dependencies: [...]
```

### Phase 3 → Phase 4

```yaml
# test-implementerの出力 + test-runnerの出力 → feature-implementerの入力
test_files: ["{file_paths}"]
red_results:
  failed_tests: [...]  # 失敗するテストのリスト（実装のガイド）
```

### Phase 4 → Phase 5

```yaml
# 全データ → pr-composerの入力
workflow_context:
  issue: {...}
  requirements: {...}
  test_design: {...}
  test_files: [...]
  implementation_files: [...]
  green_results: {...}
```

---

## パフォーマンス最適化

### モデル選択による最適化
- sonnetエージェント: 高速応答（分析・検出・実行・PR作成）
- opusエージェント: 高品質応答（設計・実装・制御）
- 並列フェーズにsonnetエージェントを配置して応答時間を最短化

### コンテキスト最小化
- 各エージェントには必要最小限のコンテキストのみ渡す
- 大きなファイル内容の全文ではなく、関連部分のみ抽出して渡す
- 前フェーズの出力は構造化YAML形式で要約して渡す

### 早期失敗（Fail Fast）
- Phase 1でIssue取得に失敗 → 即座にワークフロー中断
- Phase 3でテストが実行不可能 → 環境問題として即報告
- Phase 4で3回リトライ失敗 → 部分実装でPR作成に移行

---

## スケーラビリティ考慮

### 大規模Issue対応
- テストケース数が20を超える場合:
  - テストファイルを複数に分割
  - test-implementerを機能単位で複数回呼び出し
  - feature-implementerも対応する単位で実装

### 複数Issue一括処理（将来拡張）
- 各Issueを独立したワークフローとして並列実行可能
- Git競合を避けるため、Issue間の影響範囲を事前に分析
- ブランチを分離して並列処理
