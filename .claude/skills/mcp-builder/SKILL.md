---
name: "MCP Builder"
description: "Model Context Protocol (MCP) サーバーの設計・構築ガイド。外部API・サービスとLLMを統合"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - mcp
  - integration
  - api
  - server
triggers:
  - "/mcp-builder"
  - "MCP構築"
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

# MCP Builder

## Description
Model Context Protocol (MCP) サーバーの設計・実装をガイドするスキル。
外部APIやサービスをLLMに統合するためのMCPサーバーを構築する。

## Trigger
- `/mcp-builder`
- "MCPサーバーを作って"
- "外部APIをMCPで統合したい"

## MCP とは

Model Context Protocol (MCP) は、LLMアプリケーションと外部データソース・ツールを
標準化された方法で接続するためのオープンプロトコル。

```
LLM Application (Host)
    ↕ MCP Protocol
MCP Server
    ↕ API/SDK
External Service (DB, API, File System, etc.)
```

## Workflow

### Phase 1: 要件定義
1. 統合対象サービスの特定
2. 必要な操作の洗い出し（CRUD、検索、etc.）
3. 認証方式の確認（OAuth, API Key, Bearer Token）
4. データスキーマの設計

### Phase 2: サーバー設計
1. ツール定義（Tools）の設計
2. リソース定義（Resources）の設計
3. プロンプト定義（Prompts）の設計
4. エラーハンドリング戦略

### Phase 3: 実装
1. MCPサーバーの実装（TypeScript推奨）
2. ツールハンドラーの実装
3. 認証・セキュリティの実装
4. エラーハンドリングの実装

### Phase 4: テスト・設定
1. ローカルテスト
2. Claude Desktop / Claude Code への設定追加
3. 動作確認

## MCP サーバーテンプレート (TypeScript)

### プロジェクト構成
```
mcp-{service-name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts          # エントリポイント
│   ├── server.ts         # MCPサーバー定義
│   ├── tools/            # ツール実装
│   │   └── {tool-name}.ts
│   ├── resources/        # リソース実装
│   │   └── {resource-name}.ts
│   └── utils/            # ユーティリティ
│       ├── auth.ts
│       └── api-client.ts
└── tests/
    └── tools/
        └── {tool-name}.test.ts
```

### 基本サーバー実装
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-mcp-server",
  version: "1.0.0",
});

// ツール定義
server.tool(
  "search_items",
  "指定した条件でアイテムを検索する",
  {
    query: z.string().describe("検索クエリ"),
    limit: z.number().optional().default(10).describe("最大結果数"),
  },
  async ({ query, limit }) => {
    const results = await apiClient.search(query, limit);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(results, null, 2),
        },
      ],
    };
  }
);

// リソース定義
server.resource(
  "item://{id}",
  "アイテムの詳細情報を取得",
  async (uri) => {
    const id = uri.pathname.split("/").pop();
    const item = await apiClient.getItem(id);
    return {
      contents: [
        {
          uri: uri.href,
          mimeType: "application/json",
          text: JSON.stringify(item, null, 2),
        },
      ],
    };
  }
);

// サーバー起動
const transport = new StdioServerTransport();
await server.connect(transport);
```

## Claude Code 設定

### `.claude/mcp.json`
```json
{
  "mcpServers": {
    "my-service": {
      "command": "npx",
      "args": ["-y", "mcp-my-service"],
      "env": {
        "API_KEY": "..."
      }
    }
  }
}
```

## セキュリティ考慮事項

1. **認証情報**: 環境変数で管理、コードにハードコードしない
2. **入力検証**: Zod等でスキーマバリデーション
3. **レート制限**: 外部APIのレート制限を遵守
4. **エラー処理**: 内部エラーの詳細を外部に露出しない
5. **権限最小化**: 必要最小限のAPIスコープを要求

## AIDD 連携
- AIDD ワークフローの Phase 5 で外部サービス連携が必要な場合に参照
- code-implementer がMCPサーバー実装時にこのスキルのパターンを使用

## References
- MCP 公式: https://modelcontextprotocol.io/
- MCP TypeScript SDK: https://github.com/modelcontextprotocol/typescript-sdk
- Anthropic mcp-builder スキル: https://github.com/anthropics/skills
