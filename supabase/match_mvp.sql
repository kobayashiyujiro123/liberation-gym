-- ============================================================
-- 大会MVP（選手名・選出理由）用の列を matches に追加
--
-- 管理画面（gym-schedule.html）の試合結果 登録／編集でMVPを設定でき、
-- 会員ページ（gym-member.html）の試合結果にも表示される。
-- 理由は任意入力。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor でこのファイルを実行
-- 取り消し:  ALTER TABLE public.matches DROP COLUMN mvp_name, DROP COLUMN mvp_reason;
-- ============================================================

ALTER TABLE public.matches
  ADD COLUMN IF NOT EXISTS mvp_name   TEXT,
  ADD COLUMN IF NOT EXISTS mvp_reason TEXT;

-- PostgREST のスキーマキャッシュを更新（列追加を API に反映）
NOTIFY pgrst, 'reload schema';
