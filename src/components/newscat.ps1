# News category helpers (category label -> URL slug)

function Get-NewsCategories {
  @(
    @{ label = 'お知らせ'; slug = 'notice' },
    @{ label = 'IR'; slug = 'ir' },
    @{ label = 'プレス'; slug = 'press' },
    @{ label = 'サステナビリティ'; slug = 'sustainability' }
  )
}

function Get-NewsFilter([string]$activeSlug) {
  $cur = if ($activeSlug -eq '') { ' aria-current="page"' } else { '' }
  $li = "<li><a href=`"/news/`"$cur>すべて</a></li>"
  foreach ($c in Get-NewsCategories) {
    $cur = if ($c.slug -eq $activeSlug) { ' aria-current="page"' } else { '' }
    $li += "<li><a href=`"/news/category/$($c.slug)/`"$cur>$(Esc $c.label)</a></li>"
  }
  return "<nav aria-label=`"カテゴリで絞り込み`"><ul class=`"filter`">$li</ul></nav>"
}
