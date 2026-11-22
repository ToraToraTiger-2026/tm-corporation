# Tiny local preview server for dist/ (PowerShell only, no extra tools).
# Usage:  powershell -ExecutionPolicy Bypass -File serve.ps1 [-Port 8080] [-BasePath /tm-corporation]
# Use the same -BasePath that you gave to build.ps1. Stop with Ctrl+C.
# NOTE: keep this file ASCII-only.
param(
  [int]$Port = 8080,
  [string]$BasePath = '',
  [string]$Dir = 'dist'
)
$root = Join-Path $PSScriptRoot $Dir
if (-not (Test-Path $root)) { Write-Host "dist not found. Run build.ps1 first." -ForegroundColor Red; exit 1 }
$BasePath = $BasePath.Trim().TrimEnd('/')
$types = @{
  '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='text/javascript; charset=utf-8'
  '.svg'='image/svg+xml'; '.json'='application/json'; '.xml'='application/xml'; '.txt'='text/plain; charset=utf-8'
  '.pdf'='application/pdf'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.webp'='image/webp'
}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host ("Serving {0} at http://localhost:{1}{2}/  (Ctrl+C to stop)" -f $Dir, $Port, $BasePath)
try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    $status = 200
    $file = $null
    if ($BasePath -ne '' -and ($req -eq $BasePath)) {
      $ctx.Response.Redirect("$BasePath/"); $ctx.Response.Close(); continue
    }
    if ($BasePath -ne '' -and -not $req.StartsWith($BasePath + '/')) { $status = 404 }
    else {
      $rel = $req.Substring($BasePath.Length).TrimStart('/')
      $cand = Join-Path $root $rel
      if ($req.EndsWith('/') -or $rel -eq '') { $cand = Join-Path $cand 'index.html' }
      $full = [System.IO.Path]::GetFullPath($cand)
      if ($full.StartsWith([System.IO.Path]::GetFullPath($root)) -and (Test-Path $full -PathType Leaf)) { $file = $full } else { $status = 404 }
    }
    if ($status -eq 404) { $nf = Join-Path $root '404.html'; if (Test-Path $nf) { $file = $nf } }
    $ctx.Response.StatusCode = $status
    if ($file) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $ctx.Response.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { 'application/octet-stream' })
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $ctx.Response.Close()
  }
} finally { $listener.Stop() }
