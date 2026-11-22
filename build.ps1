# TM Corporation static site generator (PowerShell only, no extra tools required)
# Usage:  powershell -ExecutionPolicy Bypass -File build.ps1 [-BasePath /tm-corporation] [-SiteUrl https://user.github.io]
# NOTE: keep this file ASCII-only (Windows PowerShell 5.1 reads BOM-less files as ANSI).
#       Page / component scripts under src/ are read as UTF-8 explicitly, so they may contain Japanese.
param(
  [string]$BasePath = $env:BASE_PATH,
  [string]$SiteUrl  = $env:SITE_URL,
  [string]$Out      = 'docs'
)
# Link modes:
#   default (no BasePath)  -> RELATIVE links with explicit index.html. Works from file:// (double-click),
#                             from any sub-path (GitHub Pages /repo/) and from a custom domain root.
#   -BasePath /repo        -> ABSOLUTE root links prefixed with the base path (use serve.ps1 -BasePath to preview).
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

# ---- base path normalisation: '' or '/repo' (no trailing slash) ----
if ($null -eq $BasePath) { $BasePath = '' }
$BasePath = $BasePath.Trim().TrimEnd('/')
if ($BasePath -ne '' -and -not $BasePath.StartsWith('/')) { $BasePath = '/' + $BasePath }
if ($null -eq $SiteUrl -or $SiteUrl -eq '') { $SiteUrl = 'https://example.github.io' }
$SiteUrl = $SiteUrl.TrimEnd('/')
$Relative = ($BasePath -eq '')

function Read-Utf8([string]$p) { [System.IO.File]::ReadAllText($p, $Utf8) }
function Write-Utf8([string]$p, [string]$t) {
  $d = Split-Path -Parent $p
  if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force $d | Out-Null }
  [System.IO.File]::WriteAllText($p, $t, $Utf8)
}
function Esc([object]$s) { [System.Net.WebUtility]::HtmlEncode([string]$s) }

# ---- data: every src/data/*.json becomes $Data.<name> ----
$Data = @{}
Get-ChildItem (Join-Path $Root 'src/data') -Filter *.json | ForEach-Object {
  $Data[$_.BaseName] = (Read-Utf8 $_.FullName) | ConvertFrom-Json
}
$Site = $Data['site']

# ---- content collections: src/content/<name>/*.json (sorted by 'order' or 'date') ----
$Content = @{}
Get-ChildItem (Join-Path $Root 'src/content') -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $items = @()
  Get-ChildItem $_.FullName -Filter *.json | Sort-Object Name | ForEach-Object {
    $o = (Read-Utf8 $_.FullName) | ConvertFrom-Json
    $o | Add-Member -NotePropertyName slug -NotePropertyValue $_.BaseName -Force
    $items += $o
  }
  $Content[$_.Name] = $items
}

# ---- components (functions) ----
Get-ChildItem (Join-Path $Root 'src/components') -Filter *.ps1 | Sort-Object Name | ForEach-Object {
  Invoke-Expression (Read-Utf8 $_.FullName)
}

# ---- clean output & copy assets ----
$OutDir = Join-Path $Root $Out
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force $OutDir | Out-Null
Copy-Item (Join-Path $Root 'src/assets') (Join-Path $OutDir 'assets') -Recurse
if (Test-Path (Join-Path $Root 'public')) {
  Get-ChildItem (Join-Path $Root 'public') | ForEach-Object { Copy-Item $_.FullName $OutDir -Recurse }
}

# ---- collect pages ----
$Layout = Read-Utf8 (Join-Path $Root 'src/templates/layout.html')
$Pages = @()
Get-ChildItem (Join-Path $Root 'src/pages') -Filter *.ps1 -Recurse | Sort-Object FullName | ForEach-Object {
  $result = Invoke-Expression (Read-Utf8 $_.FullName)
  foreach ($p in @($result)) { if ($p) { $Pages += $p } }
}

function Add-Base([string]$html, [string]$pagePath) {
  # Authors write root-absolute URLs ("/company/"); rewrite them here.
  if (-not $Relative) {
    return [regex]::Replace($html, '(href|src|action|content)="/(?!/)', ('$1="' + $BasePath + '/'))
  }
  if ($pagePath -eq '/404.html') {
    # 404.html is served at arbitrary URL depths, so it needs absolute URLs (SiteUrl may include the repo path).
    return [regex]::Replace($html, '(href|src|action)="/(?!/)', ('$1="' + $SiteUrl + '/'))
  }
  $depth = @($pagePath.Trim('/') -split '/' | Where-Object { $_ -ne '' }).Count
  $prefix = if ($depth -eq 0) { './' } else { '../' * $depth }
  return [regex]::Replace($html, '(href|src|action)="/(?!/)([^"]*)"', {
    param($mt)
    $rest = $mt.Groups[2].Value
    $frag = ''
    $hi = $rest.IndexOfAny([char[]]@('#', '?'))
    if ($hi -ge 0) { $frag = $rest.Substring($hi); $rest = $rest.Substring(0, $hi) }
    if ($rest -eq '' -or $rest.EndsWith('/')) { $rest = $rest + 'index.html' }
    return $mt.Groups[1].Value + '="' + $prefix + $rest + $frag + '"'
  })
}

foreach ($p in $Pages) {
  $path = $p.path
  $crumbs = ''
  if ($p.crumbs) { $crumbs = Get-Breadcrumb $p.crumbs $p.title }
  $headerNav = Get-HeaderNav $path
  $canonical = $SiteUrl + $BasePath + $path
  $ogImage = $SiteUrl + $BasePath + '/assets/images/og-default.png'
  $robots = ''
  if ($p.noindex) { $robots = '<meta name="robots" content="noindex">' }
  $fullTitle = if ($path -eq '/') { $Site.company.name } else { $p.title + ' | ' + $Site.company.name }
  $html = $Layout
  $map = [ordered]@{
    '{{title}}'       = (Esc $fullTitle)
    '{{description}}' = (Esc $p.description)
    '{{canonical}}'   = $canonical
    '{{ogimage}}'     = $ogImage
    '{{robots}}'      = $robots
    '{{header}}'      = $headerNav
    '{{breadcrumb}}'  = $crumbs
    '{{footer}}'      = (Get-Footer)
    '{{bodyclass}}'   = $(if ($p.bodyclass) { $p.bodyclass } else { '' })
    '{{content}}'     = $p.body
  }
  foreach ($k in $map.Keys) { $html = $html.Replace($k, [string]$map[$k]) }
  $html = Add-Base $html $path
  $target = if ($path -eq '/') { Join-Path $OutDir 'index.html' } else { Join-Path $OutDir (($path.Trim('/') -replace '/', '\') + '\index.html') }
  if ($path -eq '/404.html') { $target = Join-Path $OutDir '404.html' }
  Write-Utf8 $target $html
}

# ---- .nojekyll (serve files as-is on GitHub Pages) ----
Write-Utf8 (Join-Path $OutDir '.nojekyll') ''

# ---- sitemap.xml / robots.txt ----
$urls = $Pages | Where-Object { -not $_.noindex -and $_.path -ne '/404.html' } | ForEach-Object { '  <url><loc>' + $SiteUrl + $BasePath + $_.path + '</loc></url>' }
Write-Utf8 (Join-Path $OutDir 'sitemap.xml') ("<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n" + ($urls -join "`n") + "`n</urlset>`n")
Write-Utf8 (Join-Path $OutDir 'robots.txt') ("User-agent: *`nAllow: /`nSitemap: " + $SiteUrl + $BasePath + "/sitemap.xml`n")

# ---- link check (internal href/src must exist in output) ----
$broken = @()
Get-ChildItem $OutDir -Filter *.html -Recurse | ForEach-Object {
  $file = $_
  $text = Read-Utf8 $file.FullName
  foreach ($m in [regex]::Matches($text, '(?:href|src)="([^"]+)"')) {
    $u = $m.Groups[1].Value
    if ($u -match '^(https?:|mailto:|tel:|#|data:)') { continue }
    $u = ($u -split '[#?]')[0]
    if ($u -eq '') { continue }
    if ($Relative) {
      if ($u.StartsWith('/')) { $broken += ($file.FullName.Substring($OutDir.Length) + ' -> (absolute in relative mode) ' + $u); continue }
      $cand = [System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $u))
      if (-not (Test-Path $cand -PathType Leaf) -or -not $cand.StartsWith($OutDir)) { $broken += ($file.FullName.Substring($OutDir.Length) + ' -> ' + $m.Groups[1].Value) }
      continue
    }
    if ($BasePath -ne '') {
      if (-not $u.StartsWith($BasePath + '/') -and $u -ne $BasePath) { $broken += ($file.FullName.Substring($OutDir.Length) + ' -> (outside base) ' + $u); continue }
      $u = $u.Substring($BasePath.Length)
    }
    if (-not $u.StartsWith('/')) { $broken += ($file.FullName.Substring($OutDir.Length) + ' -> (relative) ' + $u); continue }
    $rel = $u.TrimStart('/') -replace '/', '\'
    $cand = Join-Path $OutDir $rel
    $ok = $false
    if ($u.EndsWith('/') -or $rel -eq '') { $ok = Test-Path (Join-Path $cand 'index.html') }
    else { $ok = Test-Path $cand -PathType Leaf }
    if (-not $ok) { $broken += ($file.FullName.Substring($OutDir.Length) + ' -> ' + $m.Groups[1].Value) }
  }
}
Write-Host ("Built {0} pages -> {1}  (base='{2}')" -f $Pages.Count, $Out, $BasePath)
if ($broken.Count -gt 0) {
  Write-Host ("BROKEN LINKS: {0}" -f $broken.Count) -ForegroundColor Yellow
  $broken | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" }
  if ($env:STRICT_LINKS -eq '1') { exit 1 }
} else { Write-Host 'Link check: OK' -ForegroundColor Green }
