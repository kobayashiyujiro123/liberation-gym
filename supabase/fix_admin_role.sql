-- ============================================================
-- 管理者の権限が「会員」に戻ってしまった件の復旧と再発防止
--
-- 原因: 会員ページのプロフィール取得が一時的に失敗したとき、
--       「行が存在しない」と誤判定して role='member' で上書きしていた。
--       （アプリ側は修正済み。このSQLはデータの復旧と二重の防止策）
--
-- 適用方法: Supabase ダッシュボード → SQL Editor で【手順ごとに】実行
-- ============================================================


-- ── 手順1：現状の確認（読み取りのみ・安全） ─────────────────
-- 管理者・トレーナーと、木村さんの現在の権限を表示する
SELECT id, name, email, role, status
  FROM public.profiles
 WHERE role IN ('admin', 'coach')
    OR name ILIKE '%木村%'
 ORDER BY role, name;


-- ── 手順2：木村さんを管理者に戻す ───────────────────────────
-- ※ 手順1の結果で対象が1人だけであることを確認してから実行してください。
--    同姓の方が複数いる場合は、name の代わりに手順1で確認した id を指定してください。
--    例）WHERE id = 'ここに手順1で確認したUUID'
UPDATE public.profiles
   SET role = 'admin'
 WHERE name ILIKE '%木村%'
   AND role <> 'admin';

-- 戻ったことを確認
SELECT id, name, email, role, status
  FROM public.profiles
 WHERE name ILIKE '%木村%';


-- ============================================================
-- 手順3（任意）：会員が自分の権限を書き換えられないようにする
--
-- role と can_view の変更を、管理者とSQL Editorからのみに制限する。
-- トレーナー招待による「会員 → トレーナー」への変更は、招待レコードが
-- 存在する場合に限り許可するため、招待フローは今までどおり動作する。
--
-- ※ 手順1・手順2を終えてから実行してください。
-- ============================================================
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- role も can_view も変わらないなら何もしない
  IF NEW.role IS NOT DISTINCT FROM OLD.role
     AND NEW.can_view IS NOT DISTINCT FROM OLD.can_view THEN
    RETURN NEW;
  END IF;

  -- SQL Editor / サーバー側からの変更はそのまま通す
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  -- 管理者による変更はそのまま通す
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  -- トレーナー招待による「会員 → トレーナー」だけは許可する
  IF OLD.role = 'member'
     AND NEW.role = 'coach'
     AND NEW.can_view IS NOT DISTINCT FROM OLD.can_view
     AND EXISTS (
           SELECT 1 FROM public.pending_invites pi
            WHERE pi.email = NEW.email
              AND pi.role  = 'coach'
         ) THEN
    RETURN NEW;
  END IF;

  -- それ以外は role / can_view の変更を無効化（元の値に戻す）
  NEW.role     := OLD.role;
  NEW.can_view := OLD.can_view;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_protect_role ON public.profiles;
CREATE TRIGGER profiles_protect_role
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_profile_role();


-- ── 手順3を取り消したい場合 ─────────────────────────────────
-- DROP TRIGGER IF EXISTS profiles_protect_role ON public.profiles;
-- DROP FUNCTION IF EXISTS public.protect_profile_role();
