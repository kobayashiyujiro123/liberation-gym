# LSP Integration Guide

エージェントがコード実装・レビュー時にLSP（Language Server Protocol）を活用するためのガイド。
code-implementer、code-reviewer、feature-implementer が参照する。

---

## LSPとは

Language Server Protocol は、IDE/エディタと言語サーバー間の通信を標準化するプロトコル。
Claude Code はLSPサーバーと連携して、型情報・補完・診断結果を取得できる。

---

## 活用場面

### 1. 実装前の型情報確認

コードを書く前に、既存の型定義やインターフェースを確認:

```
# TypeScript: 型定義の確認
- 関数シグネチャの確認
- インターフェース/型エイリアスの確認
- ジェネリクスの制約確認
```

### 2. 実装中の診断活用

コード実装後、LSP診断結果を確認して品質を担保:

```
# 確認すべき診断情報
- 型エラー（Type errors）
- 未使用変数（Unused variables）
- 未解決のインポート（Unresolved imports）
- 非推奨API使用（Deprecated APIs）
```

### 3. リファクタリング支援

LSP機能を活用した安全なリファクタリング:

```
# 利用可能な操作
- シンボルの全参照箇所検索（Find References）
- 定義へのジャンプ（Go to Definition）
- リネーム（Rename Symbol）
- コードアクション（Code Actions / Quick Fix）
```

---

## 言語別LSP活用パターン

### TypeScript / JavaScript

```bash
# tsserver (TypeScript Language Server)
# 主な診断コード
TS2304  # 名前が見つかりません
TS2322  # 型の不一致
TS2345  # 引数の型が不一致
TS7006  # パラメーターに暗黙の any 型
TS6133  # 未使用の変数

# Lint との連携
# ESLint Language Server も併用可能
eslint --fix {file}
```

### Python

```bash
# Pyright / Pylance
# 主な診断
reportMissingImports      # インポート解決失敗
reportGeneralClassIssues  # クラス定義の問題
reportOptionalMemberAccess # Optional へのアクセス
reportUnusedVariable      # 未使用変数

# 型チェック
pyright --outputjson
mypy --json {file}
```

### Go

```bash
# gopls (Go Language Server)
# 主な診断
undeclared name     # 未宣言の変数
cannot use X as Y   # 型の不一致
imported and not used # 未使用インポート

# 静的解析
go vet ./...
staticcheck ./...
```

### Rust

```bash
# rust-analyzer
# 主な診断
E0308  # 型の不一致
E0425  # 未解決の名前
E0433  # 未解決のモジュール

# クリッパー
cargo clippy --message-format json
```

---

## エージェントでの活用手順

### code-implementer / feature-implementer

1. **実装前**: 既存の型定義やインターフェースを Grep/Read で確認
2. **実装中**: 各ファイル変更後に lint/typecheck を実行
3. **実装後**: 全体の lint/typecheck を実行してエラーゼロを確認

```bash
# 実装後の確認コマンド例
# TypeScript
npx tsc --noEmit

# Python
pyright . || mypy .

# Go
go vet ./...

# Rust
cargo check
```

### code-reviewer

1. **レビュー前**: lint/typecheck の結果を先に確認
2. **レビュー中**: 型安全性の観点を特に重視
3. **レビュー後**: 指摘事項に型関連の問題を含める

---

## Claude Code での設定

### .claude/settings.json での lint 自動実行

Hooks 設定で、ファイル変更後に自動で lint/typecheck を実行:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "npx tsc --noEmit 2>&1 | tail -20",
        "timeout": 30000
      }
    ]
  }
}
```

### 言語別設定例

#### TypeScript プロジェクト
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "npx tsc --noEmit && npx eslint --quiet $(git diff --name-only --diff-filter=AM | grep -E '\\.(ts|tsx)$' | head -5)",
        "timeout": 30000
      }
    ]
  }
}
```

#### Python プロジェクト
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "python -m pyright $(git diff --name-only --diff-filter=AM | grep -E '\\.py$' | head -5) 2>&1 | tail -20",
        "timeout": 30000
      }
    ]
  }
}
```

---

## 品質ゲートとの統合

agent-protocol.md の品質ゲートに LSP 診断を統合:

| ゲート | 条件 | ツール |
|---|---|---|
| 型チェック | 型エラーゼロ | tsc / pyright / gopls |
| Lint | Lint エラーゼロ | ESLint / Ruff / golangci-lint |
| 静的解析 | 重大な問題ゼロ | SonarQube / Semgrep |

---

## AIDD 連携

- Phase 5 (Code) で code-implementer が LSP 診断を活用して高品質な実装を行う
- code-reviewer が LSP 診断結果をレビューの入力として使用
- TDD モードでは feature-implementer が型エラーを参考に実装を修正
