# News / IR helper components

function Format-Date($d) { ([datetime]$d).ToString('yyyy.MM.dd') }

function Get-SortedNews {
  @($Data['news']) | Sort-Object { [datetime]$_.date } -Descending
}

# The wrapper div is the hook for dyn-render.js (it regenerates the list for the viewing date).
# The markup built here (from src/data/news.json) is the no-JS fallback.
function Get-NewsList($items, [string]$cat = '', [int]$limit = 0) {
  $li = ''
  foreach ($n in $items) {
    $li += "<li><time datetime=`"$($n.date)`">$(Format-Date $n.date)</time><span class=`"tag`">$(Esc $n.category)</span><a href=`"/news/$($n.slug)/`">$(Esc $n.title)</a></li>"
  }
  $inner = if ($li) { "<ul class=`"news-list`">$li</ul>" } else { '<p>該当するニュースはありません。</p>' }
  return "<div data-dyn=`"news`" data-cat=`"$(Esc $cat)`" data-limit=`"$limit`">$inner</div>"
}

function Format-Num($n) { ([int]$n).ToString('N0') }

function Format-Pct($now, $prev) {
  $v = ($now - $prev) / $prev * 100
  return ('{0:+0.0;-0.0}%' -f $v)
}
