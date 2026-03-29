$root = 'C:\Users\kobay\Downloads\AI-Engineer-claude-plan-solution-architecture-aHZVv 4'
$port = if ($env:PORT) { [int]$env:PORT } else { 5500 }

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://+:$port/")
try {
    $listener.Start()
} catch {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

Write-Host "Server started on http://localhost:$port"
[Console]::Out.Flush()

$stdin = [Console]::In
$stdinTask = $null

while ($listener.IsListening) {
    $ctxTask = $listener.GetContextAsync()
    while (-not $ctxTask.IsCompleted) {
        Start-Sleep -Milliseconds 50
    }
    if ($ctxTask.IsFaulted) { break }
    $ctx = $ctxTask.Result
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
