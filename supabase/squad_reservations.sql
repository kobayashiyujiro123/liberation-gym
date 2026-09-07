-- ============================================================
-- 最強軍団の予約状況（gym-member.html）用 DB 関数
--
-- 会員ページで「担当コーチが同じ会員グループ（最強軍団）」の予約状況を
-- 会員自身が閲覧できるようにする。profiles / reservations の RLS は
-- 「本人のみ」のままにし、SECURITY DEFINER の関数経由で必要な列だけ返す。
--
-- 適用方法: Supabase ダッシュボード → SQL Editor でこのファイルを実行
-- 取り消し:  DROP FUNCTION public.get_squad_reservations(text, text);
--            DROP FUNCTION public.get_squad_members();
-- ============================================================

-- 呼び出し元と同じ担当コーチ（coach_name）を持つ会員一覧（本人を含む）
-- coach_name は空白（半角・全角）を除去して比較する
CREATE OR REPLACE FUNCTION public.get_squad_members()
RETURNS TABLE (id uuid, name text, gender text, coach_name text)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  WITH me AS (
    SELECT regexp_replace(coalesce(p.coach_name, ''), '[[:space:]　]', '', 'g') AS key
    FROM public.profiles p
    WHERE p.id = auth.uid()
  )
  SELECT p.id, p.name, p.gender, p.coach_name
  FROM public.profiles p, me
  WHERE me.key <> ''
    AND regexp_replace(coalesce(p.coach_name, ''), '[[:space:]　]', '', 'g') = me.key
    AND coalesce(p.role, 'member') NOT IN ('admin', 'coach')
    AND coalesce(p.status, 'active') <> 'withdrawn'
  ORDER BY p.name;
$$;

-- 同じ担当コーチの会員全員の予約（期間指定: 'YYYY-MM-DD' 文字列）
-- ※ 本番の reservations.date は TEXT 型のため、文字列のまま比較する
CREATE OR REPLACE FUNCTION public.get_squad_reservations(p_start text, p_end text)
RETURNS TABLE (
  id uuid, user_id uuid, date text, "time" text, class_name text,
  status text, memo text, coach text, created_at timestamptz,
  member_name text, member_gender text
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT r.id, r.user_id, r.date::text, r.time::text, r.class_name,
         r.status, r.memo, r.coach, r.created_at,
         m.name, m.gender
  FROM public.reservations r
  JOIN public.get_squad_members() m ON m.id = r.user_id
  WHERE r.date::text >= p_start AND r.date::text <= p_end
  ORDER BY r.date::text, r.time::text;
$$;

-- 認証済みユーザーのみ実行可（anon は不可）
REVOKE ALL ON FUNCTION public.get_squad_members() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_squad_reservations(text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_squad_members() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_squad_reservations(text, text) TO authenticated;
