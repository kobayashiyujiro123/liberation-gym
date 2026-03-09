// ============================================================
// Supabase 設定ファイル
// supabase.com のプロジェクト設定画面から取得してください：
//   Settings → API → Project URL / anon public key
// ============================================================

const SUPABASE_URL  = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON = 'YOUR_ANON_PUBLIC_KEY';

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON, {
  auth: {
    autoRefreshToken:  true,
    persistSession:    true,
    detectSessionInUrl: true,
  }
});
