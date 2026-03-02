# Testing Framework

TDD・AIDD両スキル共通のテスト原則・戦略ガイド。
test-designer、test-implementer、code-implementer、code-reviewer が参照する。

> このドキュメントは `.claude/common/` に配置された共通リソースです。

---

## Red-Green-Refactor サイクル

### 1. RED - テストを書く（失敗させる）
- 実装コードを書く前に、必ずテストを先に書く
- テストを実行し、期待通りに**失敗する**ことを確認する
- コンパイルエラーではなく、アサーション失敗であるべき

### 2. GREEN - テストを通す（最小実装）
- テストを通す最小限のコードだけを書く
- 「将来必要になるかもしれない」コードを書かない
- ハードコードでもよい（後でリファクタする）

### 3. REFACTOR - コードを改善する
- テストが通る状態を維持しながら、コードの品質を改善する
- 重複の排除、命名の改善、メソッドの抽出

---

## FIRST原則

| 原則 | 説明 |
|---|---|
| **F**ast | テストは高速に実行できる |
| **I**ndependent | テスト間に依存関係がない |
| **R**epeatable | 何度実行しても同じ結果になる |
| **S**elf-validating | テスト自体が合否を判定する |
| **T**imely | テストは実装前に書く |

---

## Arrange-Act-Assert (AAA) パターン

```typescript
// JavaScript/TypeScript
it('adds two numbers correctly', () => {
  // Arrange
  const calculator = new Calculator();

  // Act
  const result = calculator.add(1, 2);

  // Assert
  expect(result).toBe(3);
});
```

```python
# Python
def test_adds_two_numbers_correctly(self):
    # Arrange
    calculator = Calculator()

    # Act
    result = calculator.add(1, 2)

    # Assert
    assert result == 3
```

```go
// Go
func TestAddsTwoNumbers(t *testing.T) {
    // Arrange
    calc := NewCalculator()

    // Act
    result := calc.Add(1, 2)

    // Assert
    assert.Equal(t, 3, result)
}
```

---

## テストピラミッド

```
    /  E2E  \        少ない（主要フローのみ）
   /Integration\     中程度（API・DB境界）
  /   Unit Tests  \  多い（ビジネスロジック）
```

| レイヤー | 割合 | 対象 | カバレッジ目標 |
|---------|------|------|--------------|
| Unit | 70% | 関数、クラス、モジュール | 80%以上（重要モジュール90%以上） |
| Integration | 20% | API、DB境界、外部サービス連携 | 主要結合点を網羅 |
| E2E | 10% | ユーザーフロー全体 | 主要フローを網羅 |

---

## テストケースの分類

### 正常系（Happy Path）
- 期待通りの入力に対して正しい出力を返す
- 最も基本的な使用シナリオ

### 境界値（Boundary）
- 0, 空文字, null, undefined, 最大値
- 空のコレクション
- 範囲の境界

### 異常系（Error Cases）
- 不正な入力に対するエラーハンドリング
- 例外のスローと適切なエラーメッセージ
- ネットワークエラー、タイムアウト

### 状態テスト（State）
- 状態遷移の検証
- 副作用の検証

---

## テスト優先度

| 優先度 | 説明 |
|---|---|
| **P0（必須）** | 受入基準に直結するテスト |
| **P1（重要）** | 主要なエッジケースのテスト |
| **P2（推奨）** | コーナーケースや防御的テスト |

---

## テスト命名規則

テスト名は「何を」「どういう条件で」「どうなるべきか」を明確に表現する:

```
Good:
  "returns empty array when no users match the filter"
  "throws ValidationError when email format is invalid"
  "redirects to login page when session expires"

Bad:
  "test filter"
  "test error"
  "test redirect"
```

---

## モック/スタブ戦略

### 原則
- モックは最小限に留める
- 外部依存（API、DB、ファイルシステム）のみモック化
- 内部ロジックはモックしない

### いつモックを使うか
| 対象 | モックする | モックしない |
|---|---|---|
| 外部API | Yes | - |
| DB | Integration以外でYes | Integrationテスト |
| ファイルシステム | Yes | - |
| 自作ユーティリティ | - | No |
| 日時 | Yes（再現性確保） | - |

---

## AIが書いたテストを疑う観点

- [ ] テストが**要件（PRD）を満たしているか**
- [ ] **境界条件**をカバーしているか（空、最大値、異常値）
- [ ] **偽陽性**がないか（常にパスするテスト）
- [ ] **偽陰性**がないか（本来失敗すべきケースがパスする）
- [ ] モックが**過剰**でないか（実際の挙動と乖離）
- [ ] テストの**可読性**は十分か
- [ ] 1テスト = 1アサーション を基本としているか

---

## アンチパターン

### 1. テストが実装の詳細に依存する
- **問題**: 内部実装の変更でテストが壊れる
- **回避**: 公開インターフェースに対してテストする

### 2. テスト間の依存関係
- **問題**: テストの実行順序で結果が変わる
- **回避**: 各テストでsetup/teardownを適切に行う

### 3. 過度なモック
- **問題**: モックが多すぎて本当の振る舞いをテストできない
- **回避**: 必要最小限のモックに留める

### 4. フレークテスト（不安定なテスト）
- **問題**: 同じコードで通ったり落ちたりする
- **回避**: 非同期処理、時間依存、外部依存を適切に制御する

### 5. テストコードの重複
- **問題**: 同じセットアップが複数テストに散在
- **回避**: テストヘルパー/フィクスチャを活用する

---

## 共通アサーションパターン

| パターン | JS (Vitest/Jest) | Python (pytest) | Go (testify) |
|---|---|---|---|
| 等値 | `expect(a).toBe(b)` | `assert a == b` | `assert.Equal(t, b, a)` |
| 深い等値 | `expect(a).toEqual(b)` | `assert a == b` | `assert.Equal(t, b, a)` |
| 真偽 | `expect(a).toBeTruthy()` | `assert a` | `assert.True(t, a)` |
| null | `expect(a).toBeNull()` | `assert a is None` | `assert.Nil(t, a)` |
| 例外 | `expect(() => f()).toThrow()` | `pytest.raises(E)` | `assert.Panics(t, f)` |
| 含む | `expect(a).toContain(b)` | `assert b in a` | `assert.Contains(t, a, b)` |
