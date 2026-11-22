# UI helper components used by pages (dot-sourced by build.ps1)

function Get-PersonPhoto([string]$file, [string]$alt) {
  # Photos live in src/assets/people/. Falls back to the silhouette placeholder.
  $name = 'placeholder.svg'
  if ($file -and (Test-Path (Join-Path $Root ('src/assets/people/' + $file)))) { $name = $file }
  return "<img class=`"photo`" src=`"/assets/people/$name`" alt=`"$(Esc $alt)`" width=`"400`" height=`"500`" loading=`"lazy`">"
}

function Get-PageHero([string]$title, [string]$lead, [string]$en) {
  return @"
<section class="page-hero"><div class="container">
  <p class="eyebrow">$(Esc $en)</p>
  <h1>$(Esc $title)</h1>
  $(if ($lead) { "<p class=`"lead`">$(Esc $lead)</p>" })
</div></section>
"@
}

function Get-SvgIcon([string]$name) {
  $paths = @{
    finance = '<path d="M4 26h24M7 22V14M13 22V10M19 22V16M25 22V7" stroke="currentColor" stroke-width="2" fill="none"/>'
    agri    = '<path d="M16 28V14M16 14c0-5 4-8 9-8 0 5-4 8-9 8zM16 18c0-4-3-6-8-6 0 4 3 6 8 6z" stroke="currentColor" stroke-width="2" fill="none"/>'
    web     = '<circle cx="16" cy="16" r="11" stroke="currentColor" stroke-width="2" fill="none"/><path d="M5 16h22M16 5c4 4 4 18 0 22M16 5c-4 4-4 18 0 22" stroke="currentColor" stroke-width="2" fill="none"/>'
    consulting = '<rect x="5" y="7" width="22" height="15" rx="2" stroke="currentColor" stroke-width="2" fill="none"/><path d="M11 27h10M16 22v5M10 17l4-4 3 3 5-5" stroke="currentColor" stroke-width="2" fill="none"/>'
  }
  return "<svg class=`"icon`" width=`"32`" height=`"32`" viewBox=`"0 0 32 32`" aria-hidden=`"true`">$($paths[$name])</svg>"
}
