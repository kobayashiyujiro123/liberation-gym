-- ============================================================
-- マイカレンダー：書き込みにアイコンを付けられるようにする
--
-- training_logs にアイコン用の列を1つ足すだけ。既存の書き込みは
-- アイコンなし（NULL）のまま残るので、データが消えることはない。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor にそのまま貼って実行
-- ============================================================

ALTER TABLE public.training_logs
  ADD COLUMN IF NOT EXISTS icon text;

-- PostgREST にスキーマを読み直させる
NOTIFY pgrst, 'reload schema';
