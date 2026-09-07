-- ============================================================
-- 予約元（会員ページ / 管理画面）の記録用列を reservations に追加
--
-- 管理画面（gym-schedule.html）の「予約追加」からの予約に source = 'admin' を付け、
-- 予約履歴ページで「管理画面からの予約」を絞り込めるようにする。
-- 会員ページからの予約は既定値 'member' のまま。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor でこのファイルを実行
-- 取り消し:  ALTER TABLE public.reservations DROP COLUMN source;
-- ============================================================

ALTER TABLE public.reservations
  ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'member';

-- 既存データの補正: 会員を選ばず名前入力で追加した予約（user_id なし）は管理画面由来
UPDATE public.reservations
   SET source = 'admin'
 WHERE user_id IS NULL
   AND source = 'member';

-- PostgREST のスキーマキャッシュを更新（列追加を API に反映）
NOTIFY pgrst, 'reload schema';
