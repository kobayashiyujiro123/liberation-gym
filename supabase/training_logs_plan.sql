-- ============================================================
-- マイカレンダー：1日の中で「予定」と「記録」を分けて持てるようにする
--
-- これまでの body は「記録」として扱い、予定用の列と、予定の時刻用の列を足す。
-- 既存の書き込みのうち未来日のものは予定とみなして plan に移す。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor にそのまま貼って実行
-- ※ UPDATE があるため「destructive operations」の警告が出るが、
--   消す処理ではなく、未来日の書き込みを予定欄へ移すだけ。
-- ============================================================

ALTER TABLE public.training_logs
  ADD COLUMN IF NOT EXISTS plan      text,
  ADD COLUMN IF NOT EXISTS plan_time text;

-- 未来日に書かれていたものは「予定」として移動する。
-- 移動後は body が空になるので、2回実行しても二重に動かない。
UPDATE public.training_logs
   SET plan = body,
       body = ''
 WHERE date > CURRENT_DATE
   AND COALESCE(plan, '') = ''
   AND COALESCE(body, '') <> '';

-- PostgREST にスキーマを読み直させる
NOTIFY pgrst, 'reload schema';
