---
name: "Software Architecture"
description: "Clean Architecture、SOLID原則、GoFパターンに基づくソフトウェアアーキテクチャ設計ガイド"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - architecture
  - design-patterns
  - solid
  - clean-architecture
  - ddd
triggers:
  - "/software-architecture"
  - "設計パターン"
model: opus
tools:
  - Task
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Software Architecture

## Description
Clean Architecture、SOLID原則、GoFデザインパターンに基づく
ソフトウェアアーキテクチャ設計ガイドスキル。
実装計画立案時にアーキテクチャパターンの適用を支援する。

## Trigger
- `/software-architecture`
- "アーキテクチャを設計したい"
- "設計パターンを適用したい"
- "Clean Architecture で設計して"

## SOLID 原則

### S - Single Responsibility Principle（単一責任の原則）
- クラス/モジュールは1つの責任のみを持つ
- 変更理由が1つだけであるべき

```typescript
// ❌ 複数の責任
class UserService {
  createUser(data: UserData) { /* ユーザー作成 */ }
  sendEmail(to: string, body: string) { /* メール送信 */ }
  generateReport() { /* レポート生成 */ }
}

// ✅ 単一責任
class UserService {
  constructor(private emailService: EmailService) {}
  createUser(data: UserData) {
    const user = User.create(data);
    this.emailService.sendWelcome(user.email);
    return user;
  }
}
```

### O - Open/Closed Principle（開放閉鎖の原則）
- 拡張に対して開いている、修正に対して閉じている
- 新機能追加時に既存コードを変更しない

```typescript
// ❌ 条件分岐で拡張
function calculateDiscount(type: string, price: number) {
  if (type === 'student') return price * 0.8;
  if (type === 'senior') return price * 0.7;
  // 新しいタイプを追加するたびにこの関数を修正
}

// ✅ Strategy パターンで拡張
interface DiscountStrategy { calculate(price: number): number; }
class StudentDiscount implements DiscountStrategy {
  calculate(price: number) { return price * 0.8; }
}
```

### L - Liskov Substitution Principle（リスコフの置換原則）
- 派生クラスは基底クラスの代わりに使えるべき

### I - Interface Segregation Principle（インターフェース分離の原則）
- クライアントに不要なメソッドへの依存を強制しない

```typescript
// ❌ 太いインターフェース
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

// ✅ 分離されたインターフェース
interface Workable { work(): void; }
interface Feedable { eat(): void; }
interface Restable { sleep(): void; }
```

### D - Dependency Inversion Principle（依存性逆転の原則）
- 上位モジュールは下位モジュールに依存しない。両者とも抽象に依存する。

```typescript
// ❌ 具体に依存
class UserService {
  private db = new PostgresDatabase();
}

// ✅ 抽象に依存
interface Database { query(sql: string): Promise<any>; }
class UserService {
  constructor(private db: Database) {}
}
```

---

## Clean Architecture

### レイヤー構造
```
┌──────────────────────────────────────┐
│          Frameworks & Drivers         │ ← 外部（DB, Web, UI）
│  ┌──────────────────────────────────┐ │
│  │      Interface Adapters          │ │ ← Controller, Gateway, Presenter
│  │  ┌──────────────────────────────┐│ │
│  │  │     Application Business     ││ │ ← Use Cases
│  │  │  ┌──────────────────────────┐││ │
│  │  │  │  Enterprise Business     │││ │ ← Entities
│  │  │  └──────────────────────────┘││ │
│  │  └──────────────────────────────┘│ │
│  └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

**依存性の方向**: 外側 → 内側（内側は外側を知らない）

### ディレクトリ構成（TypeScript）
```
src/
├── domain/                 # Enterprise Business Rules
│   ├── entities/           # ビジネスエンティティ
│   │   └── user.ts
│   ├── value-objects/      # 値オブジェクト
│   │   └── email.ts
│   └── repositories/       # リポジトリインターフェース
│       └── user-repository.ts
├── application/            # Application Business Rules
│   ├── use-cases/          # ユースケース
│   │   ├── create-user.ts
│   │   └── get-user.ts
│   └── dto/                # データ転送オブジェクト
│       └── user-dto.ts
├── infrastructure/         # Frameworks & Drivers
│   ├── database/           # DB実装
│   │   └── postgres-user-repository.ts
│   ├── http/               # HTTPクライアント
│   └── external/           # 外部サービス
└── presentation/           # Interface Adapters
    ├── controllers/        # コントローラー
    │   └── user-controller.ts
    ├── middleware/          # ミドルウェア
    └── routes/             # ルーティング
```

### ディレクトリ構成（Go）
```
internal/
├── domain/
│   ├── entity/
│   │   └── user.go
│   └── repository/
│       └── user_repository.go     # interface
├── usecase/
│   ├── create_user.go
│   └── get_user.go
├── infrastructure/
│   ├── persistence/
│   │   └── postgres_user_repo.go  # implementation
│   └── external/
└── presentation/
    ├── handler/
    │   └── user_handler.go
    └── router/
```

### ディレクトリ構成（Python）
```
src/
├── domain/
│   ├── entities/
│   │   └── user.py
│   └── repositories/
│       └── user_repository.py     # ABC
├── application/
│   ├── use_cases/
│   │   ├── create_user.py
│   │   └── get_user.py
│   └── dto/
├── infrastructure/
│   ├── persistence/
│   │   └── sqlalchemy_user_repo.py
│   └── external/
└── presentation/
    ├── api/
    │   └── user_router.py
    └── schemas/
```

---

## 頻出デザインパターン

### 生成パターン
| パターン | 使用場面 | 例 |
|---|---|---|
| Factory Method | オブジェクト生成の委譲 | `UserFactory.create(type)` |
| Builder | 複雑なオブジェクトの段階的構築 | `QueryBuilder.select().where().build()` |
| Singleton | グローバル状態の管理 | DB接続プール, ロガー |

### 構造パターン
| パターン | 使用場面 | 例 |
|---|---|---|
| Adapter | 互換性のないインターフェースの統合 | 外部APIラッパー |
| Decorator | 既存機能への動的な責任追加 | ロギング, キャッシュ |
| Repository | データアクセスの抽象化 | `UserRepository.findById()` |

### 振る舞いパターン
| パターン | 使用場面 | 例 |
|---|---|---|
| Strategy | アルゴリズムの切り替え | 認証方式, ソート |
| Observer | イベント駆動の通知 | イベントバス |
| Command | 操作のオブジェクト化 | CQRS, Undo/Redo |

---

## アーキテクチャ判断フローチャート

```
プロジェクト規模は？
├── 小規模（数画面、単一DB）
│   → シンプルなMVC/レイヤードアーキテクチャ
│   → 過度な抽象化は避ける
│
├── 中規模（複数機能、チーム開発）
│   → Clean Architecture のレイヤー構造
│   → DI コンテナの導入
│   → リポジトリパターン
│
└── 大規模（マイクロサービス、複数チーム）
    → DDD（ドメイン駆動設計）
    → CQRS / Event Sourcing
    → API Gateway パターン
```

## アンチパターン

### 1. 過剰な抽象化（Premature Abstraction）
- **問題**: 1箇所でしか使わないのにインターフェースを定義
- **判断基準**: 2箇所以上で使う、またはテスト時にモックが必要な場合のみ抽象化

### 2. Big Ball of Mud
- **問題**: 依存関係が全方向に広がり、変更が困難
- **対策**: レイヤー間の依存方向を厳密に管理

### 3. Golden Hammer
- **問題**: お気に入りのパターンを何にでも適用
- **対策**: 問題に合ったパターンを選択。パターンなしが正解なこともある

### 4. Anemic Domain Model
- **問題**: Entity がただのデータコンテナで、ロジックが全て Service に集中
- **対策**: Entity にビジネスルールを持たせる

## AIDD 連携
- implementation-planner エージェントが設計判断時に参照
- code-implementer エージェントがパターン適用時に参照
- aidd-principles.md の「コーディング原則」を補完

## References
- Robert C. Martin "Clean Architecture"
- Erich Gamma et al. "Design Patterns: Elements of Reusable Object-Oriented Software"
- Martin Fowler "Patterns of Enterprise Application Architecture"
