$root = 'C:\Users\kobay\Downloads\AI-Engineer-claude-plan-solution-architecture-aHZVv 4'
$port = $env:PORT
if (-not $port) { $port = 6545 }

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server started on http://localhost:$port"
[Console]::Out.Flush()

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
    } catch { continue }
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimStart('/')
    if ($path -eq '') { $path = 'gym-schedule.html' }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ext = [System.IO.Path]::GetExtension($file).ToLower()
            $ct = switch ($ext) {
                '.html' { 'text/html; charset=utf-8' }
                '.js'   { 'application/javascript' }
                '.css'  { 'text/css' }
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
