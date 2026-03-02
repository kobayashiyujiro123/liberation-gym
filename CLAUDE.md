# AI-Engineer Project

AI駆動開発（AIDD）ワークフローエンジン。Claude Code のスキル・エージェント群による
ソフトウェア開発の全フェーズ自動化・高品質化を実現する。

## プロジェクト概要

このリポジトリは Claude Code 用のスキル定義・エージェント設定・共通リファレンスの集合体。
実行可能なアプリケーションコードは含まない。

## ディレクトリ構成

```
.claude/
├── common/                    # 全スキル共通リファレンス
│   ├── agent-protocol.md      # エージェント間通信プロトコル
│   ├── code-review-checklist.md # コードレビュー基準
│   ├── commit-standards.md    # コミット・PR規約
│   ├── security-baseline.md   # セキュリティ最小基準
│   └── testing-framework.md   # テスト原則・戦略
├── settings.json              # Hooks・権限設定
└── skills/
    ├── aidd-development/      # AIDD統合スキル（20エージェント）
    ├── skill-creator/         # スキル作成ガイド
    ├── webapp-testing/        # Playwright E2Eテスト
    ├── mcp-builder/           # MCPサーバー構築ガイド
    ├── frontend-design/       # フロントエンドデザイン指針
    ├── owasp-security/        # OWASPセキュリティ監査
    ├── software-architecture/ # ソフトウェアアーキテクチャパターン
    ├── web-artifacts-builder/ # React/Tailwind/shadcn HTML成果物構築
    ├── doc-coauthoring/       # 共同文書作成ワークフロー
    ├── internal-comms/        # 社内コミュニケーション文書
    ├── algorithmic-art/       # p5.js ジェネラティブアート
    ├── canvas-design/         # PNG/PDFビジュアルアート
    ├── brand-guidelines/      # Anthropicブランドカラー・タイポグラフィ
    ├── theme-factory/         # 10種プリセットテーマ + カスタムテーマ
    ├── slack-gif-creator/     # Slack向けGIFアニメーション
    ├── claude-md-management/  # CLAUDE.md品質監査・改善
    ├── code-review/           # 5並列エージェント自動PRレビュー
    ├── plugin-dev/            # プラグイン開発ガイド
    ├── cloudflare/            # Workers/DO/Agents/KV/D1/R2/AI
    ├── stripe/                # 決済統合ベストプラクティス
    ├── expo/                  # React Native / Expo開発ガイド
    ├── supabase/              # Postgres最適化・RLS・リアルタイム
    ├── huggingface/           # MLモデル学習・データセット・推論
    └── vercel-nextjs/         # Next.js Cache/PPR/デプロイ最適化
```

## スキル一覧

### オリジナルスキル

| スキル | コマンド | 説明 |
|---|---|---|
| AIDD Development | `/aidd` | AI駆動開発フルワークフロー（Phase 1-6） |
| TDD Shortcut | `/tdd` | GitHub Issue から直接TDD実行（Phase 5 のみ） |

<details>
<summary>AIDD 内部アーキテクチャ（12コアエージェント・6フェーズ）</summary>

| Phase | エージェント | モデル | 役割 |
|---|---|---|---|
| 0. ORCHESTRATION | orchestrator | Opus | 全フェーズ統括 |
| 1. EXPLORE | requirements-interviewer | Opus | 構造化インタビュー |
| | prd-composer | Opus | PRD生成 |
| | flow-visualizer | Sonnet | フロー・状態遷移図 |
| 2. DESIGN | design-system-builder | Sonnet | デザインシステム定義 |
| | ui-prototyper | Opus | ワイヤーフレーム・UIプロトタイプ |
| 3. REVIEW | critical-reviewer | Opus | 市場・機能・技術の3視点レビュー |
| 4. PLAN | sprint-planner | Opus | スプリント分割 |
| | implementation-planner | Opus | 詳細実装計画・ADR |
| 5. CODE | code-implementer | Opus | コード実装 |
| | code-reviewer | Sonnet | 6カテゴリレビュー |
| 6. COMMIT | pr-composer | Sonnet | スプリント完了→PR作成 |

- 詳細は `.claude/skills/aidd-development/SKILL.md` を参照

</details>

<details>
<summary>TDD 内部アーキテクチャ（8サブエージェント・5フェーズ）</summary>

| TDD Phase | エージェント | モデル | 役割 |
|---|---|---|---|
| 0. 制御 | tdd/orchestrator | Opus | TDDサブワークフロー全体制御 |
| 1. 分析（並列） | tdd/issue-analyzer | Sonnet | GitHub Issue → 構造化要件 |
| | tdd/test-framework-detector | Sonnet | テストFW・パターン自動検出 |
| 2. テスト設計 | tdd/test-designer | Opus | テストケース設計（Happy/Boundary/Error/State） |
| 3. RED | tdd/test-implementer | Opus | 失敗するテストコード生成 |
| 4. GREEN | tdd/feature-implementer | Opus | テストを通す最小実装（リトライ×3） |
| | tdd/test-runner | Sonnet | RED/GREEN各フェーズのテスト実行・検証 |
| 5. PR | tdd/pr-composer | Sonnet | TDD結果からPR作成 |

```
Issue URL → 分析(並列) → テスト設計 → RED → GREEN(リトライ×3) → PR
```

- `/tdd {Issue URL}` で直接実行、または `/aidd` の Phase 5 内で TDD モード選択時に起動
- 詳細は `.claude/skills/aidd-development/agents/tdd/` 配下を参照

</details>

### Anthropic公式スキル

| スキル | 説明 | ソース |
|---|---|---|
| Skill Creator | 新規スキル作成の対話型ガイド | `anthropics/skills` |
| Webapp Testing | Playwright によるWebアプリE2Eテスト | `anthropics/skills` |
| MCP Builder | MCPサーバーの設計・構築ガイド | `anthropics/skills` |
| Frontend Design | AI生成UIの品質向上指針 | `anthropics/skills` |
| Web Artifacts Builder | React/Tailwind/shadcn HTML成果物構築 | `anthropics/skills` |
| Doc Co-authoring | 共同文書作成ワークフロー | `anthropics/skills` |
| Internal Comms | 社内コミュニケーション文書 | `anthropics/skills` |
| Algorithmic Art | p5.js ジェネラティブアート | `anthropics/skills` |
| Canvas Design | PNG/PDFビジュアルアート | `anthropics/skills` |
| Brand Guidelines | Anthropicブランドカラー・タイポグラフィ | `anthropics/skills` |
| Theme Factory | 10種プリセットテーマ + カスタムテーマ | `anthropics/skills` |
| Slack GIF Creator | Slack向けGIFアニメーション | `anthropics/skills` |

### Anthropicプラグイン公式

| スキル | 説明 | ソース |
|---|---|---|
| CLAUDE.md Management | CLAUDE.md品質監査・改善 | `anthropics/claude-plugins-official` |
| Code Review | 5並列Sonnetエージェント自動PRレビュー | `anthropics/claude-plugins-official` |
| Plugin Dev | プラグイン開発ガイド | `anthropics/claude-plugins-official` |

### セキュリティ・アーキテクチャ

| スキル | 説明 | ソース |
|---|---|---|
| OWASP Security | OWASP Top 10 セキュリティ監査 | コミュニティベース |
| Software Architecture | Clean Architecture/SOLIDパターン | コミュニティベース |

### パートナー公式スキル

| スキル | 説明 | ソース |
|---|---|---|
| Cloudflare | Workers/DO/Agents/KV/D1/R2/AI/Wrangler | `cloudflare/skills` |
| Stripe | 決済統合ベストプラクティス | `stripe/ai` |
| Expo | React Native / Expo開発ガイド | `expo/skills` |
| Supabase | Postgres最適化・RLS・リアルタイム | `supabase/agent-skills` |
| Hugging Face | MLモデル学習・データセット・推論・MCP | `huggingface/skills` |
| Vercel / Next.js | Cache/PPR/デプロイ最適化 | `vercel/next.js` |

## 開発ルール

### コミット規約
- Conventional Commits 形式: `{type}({scope}): {description}`
- 詳細は `.claude/common/commit-standards.md` 参照

### セキュリティ
- `.env*` ファイルは絶対にコミットしない
- シークレットは環境変数で管理
- 詳細は `.claude/common/security-baseline.md` 参照

### テスト
- Red-Green-Refactor サイクルを遵守
- テストピラミッド: Unit 70%, Integration 20%, E2E 10%
- 詳細は `.claude/common/testing-framework.md` 参照

### コードレビュー
- 別コンテキストでのレビューを必須化
- AI生成コードの典型的問題パターンを常にチェック
- 詳細は `.claude/common/code-review-checklist.md` 参照

## Hooks設定

プロジェクトレベルのHooks設定は `.claude/settings.json` で管理。
以下の自動品質チェックが有効:

- **PostToolUse (Write/Edit後)**: lint・型チェック自動実行
- **Stop (セッション終了時)**: 品質ゲート確認

## 外部スキル連携

Anthropic公式プラグインとの連携を推奨:
- `document-skills@anthropic-agent-skills` (docx/pdf/pptx/xlsx)
- `example-skills@anthropic-agent-skills` (各種サンプル)

追加パートナースキル（未取り込み）:
- Trail of Bits (`trailofbits/skills`) - 55+セキュリティ監査スキル
- Sentry - エラー監視
- Google Labs - 実験的ツール
- Remotion - プログラマティック動画生成

## ワークフロー・オーケストレーション

### 1. 計画ノードのデフォルト
- 非自明なタスク（3ステップ以上、またはアーキテクチャ上の判断を伴うもの）には必ずプランモードに入る
- 何かがうまくいかなくなったら、即座に止まって再計画する ── 無理に押し進めない
- 検証ステップにもプランモードを活用する（構築時だけでなく）
- 曖昧さを減らすために、事前に詳細な仕様を書く

### 2. サブエージェント戦略
- メインのコンテキストウィンドウをクリーンに保つために、サブエージェントを積極的に活用する
- 調査・探索・並列分析はサブエージェントにオフロードする
- 複雑な問題には、サブエージェント経由でより多くの計算リソースを投入する
- 集中した実行のために、1つのサブエージェントにつき1つのタスク

### 3. 自己改善ループ
- ユーザーから修正を受けたら必ず tasks/lessons.md にそのパターンを記録する
- 同じミスを防ぐためのルールを自分自身に書く
- ミス率が下がるまで、これらの教訓を徹底的にイテレーションする
- セッション開始時に、該当プロジェクトに関連する教訓を見直す

### 4. 完了前の検証
- 動作を証明せずにタスクを完了としてマークしない
- 必要に応じて、mainブランチと自分の変更の挙動差分を確認する
- 「シニアエンジニアがこれを承認するか？」と自問する
- テストを実行し、ログを確認し、正しさを実証する

### 5. エレガンスを追求する（バランスを持って）
- 非自明な変更には：一度立ち止まり「もっとエレガントな方法はないか？」と問う
- 修正が場当たり的に感じたら：「今知っていること全てを踏まえて、エレガントな解決策を実装する」
- シンプルで明白な修正にはこれをスキップする ── 過剰設計しない
- 提示する前に、自分自身の作業に疑問を投げかける

### 6. 自律的なバグ修正
- バグ報告を受けたら：ただ修正する。手取り足取り聞かない
- ログ、エラー、失敗するテストを示し ── そして解決する
- ユーザー側のコンテキストスイッチをゼロにする
- 失敗するCIテストも指示なしに自分で修正しに行く

## タスク管理

1. **まず計画**: tasks/todo.md にチェック可能な項目で計画を書く
2. **計画を確認**: 実装開始前にチェックインする
3. **進捗を追跡**: 完了したら随時チェックを入れる
4. **変更を説明**: 各ステップでハイレベルな要約を示す
5. **結果を文書化**: tasks/todo.md にレビューセクションを追加する
6. **教訓を記録**: 修正を受けた後に tasks/lessons.md を更新する

## 基本原則

- **シンプルさ第一**: すべての変更を可能な限りシンプルにする。影響するコードは最小限に。
- **怠惰の禁止**: 根本原因を見つける。一時的な修正はしない。シニア開発者の基準で。
- **最小限の影響**: 変更は必要な箇所のみに留める。バグを持ち込まない。
