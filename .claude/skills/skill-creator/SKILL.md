---
name: "Skill Creator"
description: "新規スキル作成の対話型ガイド。Agent Skills仕様に準拠したSKILL.mdとエージェント定義を自動生成"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - meta
  - skill-development
  - scaffolding
triggers:
  - "/skill-creator"
  - "スキル作成"
model: opus
tools:
  - Task
  - Read
  - Write
  - Glob
  - Grep
---

# Skill Creator

## Description
新しい Claude Code スキルを対話的に作成するガイドスキル。
Agent Skills 仕様（agentskills.io）に準拠した SKILL.md とエージェント定義を自動生成する。

## Trigger
- `/skill-creator`
- "新しいスキルを作って"
- "スキルを作成したい"

## Workflow

### Phase 1: ヒアリング（対話型）
ユーザーに以下を質問して要件を収集:

1. **スキル名**: どんなスキルを作りたいか（例: "コードレビュー", "デプロイ自動化"）
2. **目的**: 何を解決するスキルか
3. **トリガー**: どんなコマンド/フレーズで起動するか
4. **エージェント構成**: 単一エージェントか複数エージェントか
5. **ツール要件**: Bash, Read, Write, Task 等のどれを使うか
6. **モデル選択**: 速度重視（sonnet）か品質重視（opus）か

### Phase 2: スキル設計
ヒアリング結果から以下を設計:

1. ディレクトリ構造
2. SKILL.md の YAML frontmatter
3. エージェント分割案（複数エージェントの場合）
4. ワークフロー図（Mermaid）

### Phase 3: ファイル生成
設計に基づいてファイルを自動生成:

```
.claude/skills/{skill-name}/
├── SKILL.md              # スキル定義（frontmatter + 説明）
├── agents/               # エージェント定義（必要な場合）
│   ├── orchestrator.md
│   └── {agent-name}.md
├── references/           # リファレンス文書（必要な場合）
└── templates/            # テンプレート（必要な場合）
```

### Phase 4: 検証
生成したスキルの検証:

1. SKILL.md の frontmatter が仕様に準拠しているか
2. トリガーが正しく設定されているか
3. エージェント間の参照が正しいか
4. 必要なツール権限が宣言されているか

## SKILL.md テンプレート

```yaml
---
name: "{スキル名}"
description: "{1行の説明}"
version: "1.0.0"
author: "{作者名}"
tags:
  - {タグ1}
  - {タグ2}
triggers:
  - "/{コマンド名}"
model: opus|sonnet
tools:
  - Task
  - Bash
  - Read
  - Write
---
```

## エージェント定義テンプレート

```yaml
---
name: "{エージェント名}"
description: "{1行の説明}"
model: opus|sonnet
role: "{orchestrator|analyzer|implementer|reviewer|composer}"
inputs:
  - "{入力データの説明}"
outputs:
  - "{出力データの説明}"
---
```

## ベストプラクティス

### スキル設計の原則
1. **単一責任**: 1スキル = 1つの明確な目的
2. **Progressive Disclosure**: Level 1 でメタデータのみ（~100トークン）、Level 2 で全文ロード（<5kトークン）
3. **トークン予算**: スキル説明は合計で約16,000文字以内（コンテキストの~2%）
4. **明確なトリガー**: `/command` 形式のスラッシュコマンドを定義
5. **ツール最小化**: 必要なツールのみ宣言

### エージェント設計の原則
1. **モデル選択**: 分析・実行 → sonnet、設計・判断 → opus
2. **並列化**: 独立タスクは Task ツールで並列実行
3. **品質ゲート**: フェーズ間に検証ステップを設置
4. **エラーハンドリング**: リトライポリシーを明示
5. **コンテキスト分離**: エージェント間はファイルを介してデータ共有

### スキル保存先の優先順位
1. **Enterprise**: 組織全体（管理者設定）
2. **Personal**: `~/.claude/skills/` 全プロジェクト共通
3. **Project**: `.claude/skills/` プロジェクト固有
4. **Plugin**: プラグイン経由（名前空間付き）

## References
- Agent Skills 仕様: https://agentskills.io
- Claude Code スキル公式ドキュメント: https://code.claude.com/docs/en/skills
- Anthropic 公式スキルリポジトリ: https://github.com/anthropics/skills
