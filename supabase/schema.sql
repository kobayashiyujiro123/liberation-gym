-- ============================================================
-- ジム管理SPA — Supabase Schema + RLS
-- Supabase の SQL Editor にそのまま貼り付けて実行してください
-- ============================================================

-- ── 1. profiles ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id             UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name           TEXT NOT NULL DEFAULT '',
  role           TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin','member')),
  email          TEXT,
  gender         TEXT,
  birth_date     DATE,
  style          TEXT,
  weight         NUMERIC,
  target_weight  NUMERIC,
  wins           INT DEFAULT 0,
  losses         INT DEFAULT 0,
  draws          INT DEFAULT 0,
  status         TEXT DEFAULT 'active' CHECK (status IN ('active','suspended','withdrawn')),
  memo           TEXT DEFAULT '',
  tel            TEXT DEFAULT '',
  start_date     DATE,
  left_date      DATE,
  total_visits   INT DEFAULT 0,
  year_visits    INT DEFAULT 0,
  month_visits   INT DEFAULT 0,
  coach_name     TEXT DEFAULT '',
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- 新規ユーザー登録時に profiles を自動作成するトリガー
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email,'@',1))
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── 2. schedule_slots ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.schedule_slots (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date        DATE NOT NULL,
  time        TEXT NOT NULL,
  class_name  TEXT NOT NULL DEFAULT '練習',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(date, time)
);

-- ── 3. day_notes ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.day_notes (
  date  DATE PRIMARY KEY,
  note  TEXT NOT NULL
);

-- ── 4. gym_holidays ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gym_holidays (
  date  DATE PRIMARY KEY
);

-- ── 5. gym_settings ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gym_settings (
  key    TEXT PRIMARY KEY,
  value  TEXT NOT NULL
);

-- デフォルト営業時間
INSERT INTO public.gym_settings (key, value) VALUES
  ('bi-weekday-start',  '9時'),
  ('bi-weekday-end',    '21時'),
  ('bi-weekend-start',  '10時'),
  ('bi-weekend-end',    '20時'),
  ('bi-holiday-start',  '10時'),
  ('bi-holiday-end',    '18時')
ON CONFLICT (key) DO NOTHING;

-- ── 6. reservations ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reservations (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  date        DATE NOT NULL,
  time        TEXT NOT NULL,
  class_name  TEXT NOT NULL,
  status      TEXT DEFAULT 'confirmed' CHECK (status IN ('confirmed','cancelled')),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── 7. notices ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notices (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title      TEXT NOT NULL,
  content    TEXT NOT NULL,
  date       DATE NOT NULL DEFAULT CURRENT_DATE,
  visible    BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 8. coaches ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.coaches (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  specialty   TEXT DEFAULT '',
  experience  TEXT DEFAULT '',
  email       TEXT DEFAULT '',
  tel         TEXT DEFAULT '',
  status      TEXT DEFAULT 'active' CHECK (status IN ('active','on_leave','resigned')),
  joined_at   DATE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RLS の有効化
-- ============================================================
ALTER TABLE public.profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.day_notes      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_holidays   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_settings   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notices        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coaches        ENABLE ROW LEVEL SECURITY;

-- ── 管理者判定ヘルパー ──────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- ── profiles ポリシー ───────────────────────────────────────
CREATE POLICY "profiles: 自分は読み書き可"
  ON public.profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles: admin は全件読み書き可"
  ON public.profiles FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── schedule_slots ポリシー ────────────────────────────────
CREATE POLICY "schedule_slots: 認証済みは読み可"
  ON public.schedule_slots FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "schedule_slots: admin は全操作可"
  ON public.schedule_slots FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── day_notes ポリシー ─────────────────────────────────────
CREATE POLICY "day_notes: 認証済みは読み可"
  ON public.day_notes FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "day_notes: admin は全操作可"
  ON public.day_notes FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── gym_holidays ポリシー ──────────────────────────────────
CREATE POLICY "gym_holidays: 認証済みは読み可"
  ON public.gym_holidays FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "gym_holidays: admin は全操作可"
  ON public.gym_holidays FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── gym_settings ポリシー ──────────────────────────────────
CREATE POLICY "gym_settings: 認証済みは読み可"
  ON public.gym_settings FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "gym_settings: admin は全操作可"
  ON public.gym_settings FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── reservations ポリシー ──────────────────────────────────
CREATE POLICY "reservations: 自分のみ読み書き可"
  ON public.reservations FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "reservations: admin は全件読み・更新可"
  ON public.reservations FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── notices ポリシー ───────────────────────────────────────
CREATE POLICY "notices: visible=true は認証済みが読み可"
  ON public.notices FOR SELECT
  USING (auth.role() = 'authenticated' AND visible = true);

CREATE POLICY "notices: admin は全操作可"
  ON public.notices FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ── coaches ポリシー ───────────────────────────────────────
CREATE POLICY "coaches: 認証済みは読み可"
  ON public.coaches FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "coaches: admin は全操作可"
  ON public.coaches FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());
