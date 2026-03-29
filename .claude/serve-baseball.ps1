$root = 'C:\Users\kobay\Downloads\AI-Engineer-claude-plan-solution-architecture-aHZVv 4'
$port = 7002

try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
} catch {
    Write-Error "Failed to start listener: $_"
    exit 1
}

Write-Host "Server started on http://localhost:$port"
[Console]::Out.Flush()

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
    } catch { continue }
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimStart('/')
    if ($path -eq '') { $path = 'baseball-team.html' }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ext = [System.IO.Path]::GetExtension($file).ToLower()
            $ct = switch ($ext) {
                '.html' { 'text/html; charset=utf-8' }
                '.js'   { 'application/javascript' }
                '.css'  { 'text/css' }
                '.jpg'  { 'image/jpeg' }
                '.jpeg' { 'image/jpeg' }
                '.png'  { 'image/png' }
                '.gif'  { 'image/gif' }
                '.svg'  { 'image/svg+xml' }
                '.webp' { 'image/webp' }
                default { 'application/octet-stream' }
            }
            $res.ContentType = $ct
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } catch {}
    } else {
        $res.StatusCode = 404
    }
    try { $res.OutputStream.Close() } catch {}
}
