---
name: "Frontend Design"
description: "AI生成UIの品質向上指針。汎用的なAIスロップを避け、大胆で意図的なデザイン判断を促進"
version: "1.0.0"
author: "AI-Engineer"
tags:
  - design
  - ui
  - ux
  - frontend
  - aesthetics
triggers:
  - "/frontend-design"
  - "デザイン改善"
model: sonnet
tools:
  - Task
  - Read
  - Write
  - Edit
  - Glob
---

# Frontend Design

## Description
AI が生成する UI の品質を向上させるためのデザイン指針スキル。
「AI スロップ」（汎用的で没個性的なデザイン）を避け、
大胆で意図的なデザイン判断を行うよう指示する。

## Trigger
- `/frontend-design`
- "デザインの品質を上げたい"
- "UIをもっと洗練させたい"

## Core Principle

> AIが生成するUIは「安全で無難」になりがちである。
> このスキルは意図的に大胆な判断を促し、個性と品質を両立させる。

## AI スロップの典型パターン（避けるべきもの）

### 1. 汎用的なカラーパレット
```
❌ 避ける:
- 全てに青を使う（#3B82F6 のコピペ）
- 白背景 + グレーボーダーの繰り返し
- グラデーションの多用

✅ 代わりに:
- ブランドに合った独自のカラーシステム
- 意味のある色使い（アクション、警告、情報の区別）
- 背景色のバリエーション（ニュートラルだが単調ではない）
```

### 2. 退屈なレイアウト
```
❌ 避ける:
- 全てが中央揃えの単調なカード配列
- 同じサイズのグリッド繰り返し
- 余白が均一すぎる

✅ 代わりに:
- コンテンツの重要度に応じた視覚的階層
- 非対称レイアウトの活用
- リズム感のある余白設計
```

### 3. 過剰な装飾
```
❌ 避ける:
- 全要素にボーダー + シャドウ + 角丸
- アイコンの過剰使用
- 不要なアニメーション

✅ 代わりに:
- 情報を伝えるために必要な最小限の装飾
- ネガティブスペースの活用
- 意味のあるインタラクション
```

## デザイン判断チェックリスト

### タイポグラフィ
- [ ] フォントファミリーは2種類以内か
- [ ] フォントサイズのスケールが一貫しているか（例: 12, 14, 16, 20, 24, 32）
- [ ] 行間（line-height）は読みやすいか（本文: 1.5-1.75）
- [ ] 見出しの視覚的階層が明確か

### カラー
- [ ] プライマリ・セカンダリ・アクセントが定義されているか
- [ ] コントラスト比が WCAG AA 基準（4.5:1）を満たすか
- [ ] ダークモード対応を考慮しているか
- [ ] 色覚多様性に配慮しているか（色だけに情報を依存しない）

### レイアウト
- [ ] 8px グリッドベースの spacing を使用しているか
- [ ] モバイルファースト設計か
- [ ] コンテンツの最大幅が適切か（本文: 65-75文字/行）
- [ ] ブレークポイントが適切か（sm: 640, md: 768, lg: 1024, xl: 1280）

### インタラクション
- [ ] hover/focus/active 状態が定義されているか
- [ ] フォーカス可視性が確保されているか（キーボード操作）
- [ ] ローディング状態のフィードバックがあるか
- [ ] エラー状態のデザインが明確か

### アクセシビリティ
- [ ] セマンティックHTML を使用しているか
- [ ] ARIA ラベルが適切か
- [ ] キーボード操作が可能か
- [ ] スクリーンリーダー対応か

## Tailwind CSS ベストプラクティス

### デザイントークンの定義
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#faf5ff',
          500: '#8b5cf6',
          900: '#4c1d95',
        },
      },
      fontFamily: {
        display: ['Cal Sans', 'Inter', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
    },
  },
};
```

### コンポーネント設計パターン
```tsx
// 良いパターン: 意図的なデザイン
<button className="
  bg-brand-500 text-white
  px-6 py-3
  font-medium tracking-wide
  rounded-lg
  shadow-lg shadow-brand-500/25
  hover:bg-brand-600 hover:shadow-xl hover:shadow-brand-500/30
  active:scale-[0.98]
  transition-all duration-150
  focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-500
">
  Action Button
</button>
```

## AIDD 連携

### design-system-builder との連携
- このスキルの指針を design-system-builder エージェントが参照
- デザインシステム生成時に AI スロップパターンを回避

### ui-prototyper との連携
- プロトタイプ生成時にこのチェックリストで品質を担保
- 3つ以上のデザインバリエーションを提示して選択させる

## References
- Anthropic frontend-design スキル: https://github.com/anthropics/skills
- Tailwind CSS: https://tailwindcss.com/
- WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/
