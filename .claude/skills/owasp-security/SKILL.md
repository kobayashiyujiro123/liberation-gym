---
name: "OWASP Security"
description: "OWASP Top 10:2025 および ASVS 5.0 に基づくセキュリティ監査・コードレビューチェックリスト"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - security
  - owasp
  - audit
  - code-review
  - vulnerability
triggers:
  - "/owasp-security"
  - "セキュリティ監査"
model: opus
tools:
  - Task
  - Bash
  - Read
  - Grep
  - Glob
---

# OWASP Security

## Description
OWASP Top 10:2025 および Application Security Verification Standard (ASVS) 5.0 に基づく
セキュリティ監査・コードレビュースキル。20+言語に対応したチェックリストを提供する。

## Trigger
- `/owasp-security`
- "セキュリティ監査をして"
- "OWASPチェックをして"
- "脆弱性をチェックして"

## OWASP Top 10:2025

### A01:2025 - Broken Access Control（アクセス制御の不備）

**チェック項目:**
- [ ] 全てのエンドポイントに認証・認可チェックがあるか
- [ ] 水平権限昇格（他ユーザーのリソースアクセス）が防止されているか
- [ ] 垂直権限昇格（管理者機能への不正アクセス）が防止されているか
- [ ] CORS ポリシーが適切に設定されているか
- [ ] ディレクトリリスティングが無効化されているか

**検出パターン:**
```bash
# 認可チェックの欠落を検出
# ルートハンドラーに authenticate/authorize がないパターン
grep -rn "app\.\(get\|post\|put\|delete\|patch\)" --include="*.{ts,js}" | grep -v "auth"
```

---

### A02:2025 - Cryptographic Failures（暗号化の失敗）

**チェック項目:**
- [ ] パスワードは bcrypt/argon2 でハッシュ化されているか
- [ ] 機密データは転送中・保存時に暗号化されているか
- [ ] 弱い暗号アルゴリズム（MD5, SHA1, DES）を使用していないか
- [ ] 暗号鍵がソースコードにハードコードされていないか
- [ ] TLS 1.2 以上を使用しているか

**検出パターン:**
```bash
# 弱い暗号の使用を検出
grep -rn "md5\|sha1\|DES\|RC4" --include="*.{ts,js,py,java,go,rb}"
# ハードコードされた鍵の検出
grep -rn "private_key\|secret_key\|encryption_key" --include="*.{ts,js,py,java,go,rb}"
```

---

### A03:2025 - Injection（インジェクション）

**チェック項目:**
- [ ] SQL パラメータ化クエリを使用しているか
- [ ] ORM の raw クエリに変数を直接埋め込んでいないか
- [ ] OS コマンドインジェクション対策がされているか
- [ ] LDAP/XPath/NoSQL インジェクション対策がされているか
- [ ] テンプレートインジェクション（SSTI）対策がされているか

**言語別パターン:**

```typescript
// TypeScript/JavaScript
// ❌ 脆弱
db.query(`SELECT * FROM users WHERE id = ${userId}`);
exec(`ls ${userInput}`);
// ✅ 安全
db.query('SELECT * FROM users WHERE id = $1', [userId]);
execFile('ls', [sanitizedPath]);
```

```python
# Python
# ❌ 脆弱
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
os.system(f"ls {user_input}")
# ✅ 安全
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
subprocess.run(["ls", sanitized_path], check=True)
```

```go
// Go
// ❌ 脆弱
query := fmt.Sprintf("SELECT * FROM users WHERE id = %s", userID)
exec.Command("sh", "-c", "ls " + userInput)
// ✅ 安全
query := "SELECT * FROM users WHERE id = $1"
db.Query(query, userID)
exec.Command("ls", sanitizedPath)
```

```java
// Java
// ❌ 脆弱
String query = "SELECT * FROM users WHERE id = " + userId;
Runtime.getRuntime().exec("ls " + userInput);
// ✅ 安全
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
ps.setString(1, userId);
ProcessBuilder pb = new ProcessBuilder("ls", sanitizedPath);
```

```ruby
# Ruby
# ❌ 脆弱
User.where("name = '#{params[:name]}'")
system("ls #{params[:path]}")
# ✅ 安全
User.where(name: params[:name])
system("ls", sanitized_path)
```

---

### A04:2025 - Insecure Design（安全でない設計）

**チェック項目:**
- [ ] 脅威モデリングが実施されているか
- [ ] ビジネスロジックのフロー制御が適切か
- [ ] レート制限が実装されているか
- [ ] 機能悪用（ブルートフォース等）に対する防御があるか

---

### A05:2025 - Security Misconfiguration（セキュリティ設定ミス）

**チェック項目:**
- [ ] デフォルト認証情報が変更されているか
- [ ] 不要な機能・ポート・サービスが無効化されているか
- [ ] エラーメッセージにスタックトレースが含まれていないか
- [ ] セキュリティヘッダーが設定されているか

**推奨ヘッダー:**
```
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

---

### A06:2025 - Vulnerable and Outdated Components（脆弱なコンポーネント）

**チェック項目:**
- [ ] `npm audit` / `pip-audit` / `go vet` で脆弱性がないか
- [ ] 依存関係が最新のセキュリティパッチを適用しているか
- [ ] 使用していない依存が削除されているか
- [ ] Dependabot/Renovate が有効か

---

### A07:2025 - Identification and Authentication Failures（認証の失敗）

**チェック項目:**
- [ ] ブルートフォース対策（アカウントロック/レート制限）があるか
- [ ] セッション固定攻撃対策がされているか
- [ ] セッションタイムアウトが適切か
- [ ] 多要素認証（MFA）がサポートされているか

---

### A08:2025 - Software and Data Integrity Failures（ソフトウェアとデータの完全性）

**チェック項目:**
- [ ] CI/CDパイプラインが保護されているか
- [ ] 依存関係の整合性検証（lock file, checksum）がされているか
- [ ] デシリアライゼーション攻撃対策がされているか
- [ ] コード署名・パッケージ署名を検証しているか

---

### A09:2025 - Security Logging and Monitoring Failures（ロギングと監視の不備）

**チェック項目:**
- [ ] 認証失敗がログに記録されているか
- [ ] アクセス制御の失敗がログに記録されているか
- [ ] ログにPII/シークレットが含まれていないか
- [ ] ログの改ざん防止策があるか

---

### A10:2025 - Server-Side Request Forgery (SSRF)

**チェック項目:**
- [ ] ユーザー入力のURLを直接フェッチしていないか
- [ ] 内部ネットワークへのリクエストがブロックされているか
- [ ] URL スキームのホワイトリストがあるか（http/https のみ）
- [ ] DNS リバインディング対策がされているか

**検出パターン:**
```bash
# SSRF 候補の検出
grep -rn "fetch\|axios\|requests\.get\|http\.Get\|urllib" --include="*.{ts,js,py,go}" | grep -i "url\|uri\|endpoint"
```

---

## Agentic AI 固有のセキュリティ考慮事項

### プロンプトインジェクション対策
- [ ] ユーザー入力とシステムプロンプトが分離されているか
- [ ] LLM出力の後処理で危険なコマンドを検出しているか
- [ ] 外部データソースからのコンテンツをサニタイズしているか

### ツール実行の制限
- [ ] ファイルシステムアクセスが必要最小限に制限されているか
- [ ] ネットワークアクセスが許可リスト制御されているか
- [ ] 実行可能なコマンドが制限されているか

## 監査レポートテンプレート

```markdown
# セキュリティ監査レポート

## 概要
- 監査対象: {プロジェクト名}
- 監査日: {日付}
- 対象範囲: {ファイル/ディレクトリ}

## 発見事項サマリー
| 深刻度 | 件数 |
|---|---|
| Critical | {N} |
| High | {N} |
| Medium | {N} |
| Low | {N} |
| Info | {N} |

## 詳細
### {発見事項タイトル}
- **深刻度**: Critical/High/Medium/Low
- **OWASP分類**: A01-A10
- **ファイル**: {path}:{line}
- **説明**: {問題の説明}
- **影響**: {影響範囲}
- **修正方法**: {具体的な修正手順}
```

## AIDD 連携
- security-baseline.md の詳細版として機能
- code-reviewer エージェントがセキュリティチェック時に参照
- code-implementer エージェントが実装時に安全なパターンを使用

## References
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- OWASP Cheat Sheet Series: https://cheatsheetseries.owasp.org/
