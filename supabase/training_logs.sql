-- ============================================================
-- マイカレンダー：会員の練習記録・予定
--
-- 本人のみが読み書きできる（コーチ・管理者からも見えない）。
-- 予約テーブルには一切触れないため、予約機能への影響はない。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor にそのまま貼って実行
-- ============================================================

CREATE TABLE IF NOT EXISTS public.training_logs (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date       date        NOT NULL,
  body       text        NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT training_logs_user_date_key UNIQUE (user_id, date)
);

CREATE INDEX IF NOT EXISTS training_logs_user_date_idx
  ON public.training_logs (user_id, date DESC);

-- updated_at の自動更新
CREATE OR REPLACE FUNCTION public.touch_training_logs()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS training_logs_touch ON public.training_logs;
CREATE TRIGGER training_logs_touch
  BEFORE UPDATE ON public.training_logs
  FOR EACH ROW EXECUTE FUNCTION public.touch_training_logs();

-- ── RLS：自分の記録だけ ─────────────────────────────────────
ALTER TABLE public.training_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS training_logs_select_own ON public.training_logs;
CREATE POLICY training_logs_select_own ON public.training_logs
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS training_logs_insert_own ON public.training_logs;
CREATE POLICY training_logs_insert_own ON public.training_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS training_logs_update_own ON public.training_logs;
CREATE POLICY training_logs_update_own ON public.training_logs
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS training_logs_delete_own ON public.training_logs;
CREATE POLICY training_logs_delete_own ON public.training_logs
  FOR DELETE USING (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.training_logs TO authenticated;

-- PostgREST にスキーマを読み直させる
NOTIFY pgrst, 'reload schema';
