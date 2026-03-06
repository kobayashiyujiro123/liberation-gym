$root = 'C:\Users\kobay\Downloads\AI-Engineer-claude-plan-solution-architecture-aHZVv 4'
$port = if ($env:PORT) { [int]$env:PORT } else { 8080 }
$logFile = "$env:TEMP\gym-serve.log"

"[$(Get-Date)] Starting server on port $port" | Out-File $logFile -Append

try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    "[$(Get-Date)] Listener started on localhost:$port" | Out-File $logFile -Append
} catch {
    "[$(Get-Date)] localhost failed: $_" | Out-File $logFile -Append
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://127.0.0.1:$port/")
        $listener.Start()
        "[$(Get-Date)] Listener started on 127.0.0.1:$port" | Out-File $logFile -Append
    } catch {
        "[$(Get-Date)] 127.0.0.1 also failed: $_" | Out-File $logFile -Append
        exit 1
    }
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
