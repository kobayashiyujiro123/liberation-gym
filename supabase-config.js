// ============================================================
// Supabase 設定ファイル
// supabase.com のプロジェクト設定画面から取得してください：
//   Settings → API → Project URL / anon public key
// ============================================================

const SUPABASE_URL  = 'https://getlmyggtxlfswinctss.supabase.co';
const SUPABASE_ANON = 'sb_publishable_7UyLKKxbUzyltp4bt014EQ_-2aCT-yr';

// Supabase未設定時はデモモードで動作
const DEMO_MODE = false; // 本番モード（Supabase使用）

// DEMO_MODEではSupabaseを使わないモックを使用（CDN読み込み不要）
let sb;
if (DEMO_MODE) {
  // モックSBオブジェクト：DEMO_MODEでは実際には呼ばれないが定義だけ用意
  const _noop   = () => Promise.resolve({ data: [], error: null });
  const _chain  = () => {
    const o = {
      select: () => _chain(), insert: _noop, upsert: _noop,
      update: () => _chain(), delete: () => _chain(),
      eq: () => _chain(), in: () => _chain(), gte: () => _chain(),
      order: () => _chain(), then: (fn) => _noop().then(fn),
    };
    return o;
  };
  sb = {
    from: () => _chain(),
    auth: {
      onAuthStateChange: () => {},
      getUser:           () => Promise.resolve({ data: { user: null } }),
      signInWithPassword:() => Promise.resolve({ error: { message: 'DEMO MODE' } }),
      signInWithOAuth:   () => {},
      signInWithOtp:     () => Promise.resolve({ error: null }),
      verifyOtp:         () => Promise.resolve({ error: null, data: { user: {} } }),
      updateUser:        () => Promise.resolve({ error: null }),
      resetPasswordForEmail: () => Promise.resolve({ error: null }),
      signOut:           () => Promise.resolve({}),
    },
  };
} else {
  // 本番モード：Supabase CDNスクリプトが必要
  sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON, {
    auth: {
      autoRefreshToken:   true,
      persistSession:     true,
      detectSessionInUrl: true,
    },
  });
}
