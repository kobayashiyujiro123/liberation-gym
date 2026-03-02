# Security Baseline

TDD・AIDD両スキル共通のセキュリティ最小基準。
code-implementer、feature-implementer、code-reviewer が参照する。

> このドキュメントは `.claude/common/` に配置された共通リソースです。
> TDD・AIDDの両スキルから参照されます。

---

## 1. シークレット管理

- [ ] APIキー、パスワードは**絶対にコードにハードコードしない**
- [ ] 環境変数または Secret Manager を使用
- [ ] `.env` ファイルは `.gitignore` に追加
- [ ] CI/CDのシークレットは暗号化して保存
- [ ] ログにシークレットを出力しない

### 検出パターン
```bash
# 以下のパターンがソースコードに存在しないことを確認
grep -r "password\s*=" --include="*.{ts,js,py}" src/
grep -r "api_key\s*=" --include="*.{ts,js,py}" src/
grep -r "secret\s*=" --include="*.{ts,js,py}" src/
grep -r "Bearer " --include="*.{ts,js,py}" src/
```

---

## 2. 入力検証（OWASP Top 10 対応）

- [ ] ユーザー入力は全てサニタイズ/バリデーション
- [ ] SQLインジェクション対策（パラメータ化クエリ）
- [ ] XSS対策（エスケープ処理）
- [ ] コマンドインジェクション対策
- [ ] パストラバーサル対策

### 言語別パターン

#### JavaScript/TypeScript
```typescript
// Bad - SQLインジェクション
const query = `SELECT * FROM users WHERE id = ${userId}`;
// Good
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);

// Bad - XSS
element.innerHTML = userInput;
// Good
element.textContent = userInput;
// or
element.innerHTML = DOMPurify.sanitize(userInput);
```

#### Python
```python
# Bad
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
# Good
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

#### Go
```go
// Bad
query := fmt.Sprintf("SELECT * FROM users WHERE id = %s", userID)
// Good
query := "SELECT * FROM users WHERE id = $1"
rows, err := db.Query(query, userID)
```

---

## 3. 認証・認可

- [ ] パスワードはハッシュ化して保存（bcrypt等）
- [ ] セッション管理は信頼できるライブラリを使用
- [ ] CSRF対策を実装
- [ ] 認証が必要なエンドポイントに認証チェック
- [ ] 認可チェック（ユーザーAがユーザーBのデータにアクセスできない）

```typescript
// Bad - 認可チェックなし
app.get('/api/users/:id', async (req, res) => {
  const user = await db.getUser(req.params.id);
  res.json(user);
});

// Good - 認可チェックあり
app.get('/api/users/:id', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const user = await db.getUser(req.params.id);
  res.json(user);
});
```

---

## 4. データ保護

- [ ] 機密データ（PII）をログに出力しない
- [ ] エラーメッセージに内部情報を含めない
- [ ] HTTPS/TLSを使用
- [ ] 適切なCORSポリシー設定

```typescript
// Bad - 内部情報の露出
catch (error) {
  res.status(500).json({ error: error.stack });
}

// Good - 安全なエラーレスポンス
catch (error) {
  logger.error('Database query failed', { error: error.message });
  res.status(500).json({ error: 'Internal server error' });
}
```

---

## 5. 依存関係管理

- [ ] `npm audit` / `pip-audit` を定期実行
- [ ] Dependabotまたは同等のツールを有効化
- [ ] 重大な脆弱性は72時間以内に対応
- [ ] 使用しない依存は削除

---

## 6. 権限最小化

- [ ] DBユーザーは必要最小限の権限のみ付与
- [ ] APIキーはスコープを限定
- [ ] サービスアカウントは用途別に分離
- [ ] RLS（Row Level Security）ポリシーの適用（Supabase等）

```sql
-- Supabase RLS パターン
CREATE POLICY "Users can only see their own data"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only update their own data"
  ON profiles FOR UPDATE
  USING (auth.uid() = user_id);
```

---

## 7. ログ・監視

- [ ] 認証失敗、権限エラーはログに記録
- [ ] 異常なアクセスパターンを検出
- [ ] ログにパスワード・トークン・PIIを含めない

---

## Permission設定テンプレート

```json
{
  "permissions": {
    "deny": [
      "Read(./.env*)",
      "Read(./secrets/**)",
      "Write(./package-lock.json)",
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Bash(wget *)"
    ],
    "ask": [
      "Bash(git push*)",
      "Bash(npm publish)",
      "Write(./migrations/**)"
    ]
  }
}
```
