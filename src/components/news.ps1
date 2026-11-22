# News / IR helper components

function Format-Date($d) { ([datetime]$d).ToString('yyyy.MM.dd') }

function Get-SortedNews {
  @($Data['news']) | Sort-Object { [datetime]$_.date } -Descending
}

function Get-NewsList($items) {
  $li = ''
  foreach ($n in $items) {
    $li += "<li><time datetime=`"$($n.date)`">$(Format-Date $n.date)</time><span class=`"tag`">$(Esc $n.category)</span><a href=`"/news/$($n.slug)/`">$(Esc $n.title)</a></li>"
  }
  return "<ul class=`"news-list`">$li</ul>"
}

function Format-Num($n) { ([int]$n).ToString('N0') }

function Format-Pct($now, $prev) {
  $v = ($now - $prev) / $prev * 100
  return ('{0:+0.0;-0.0}%' -f $v)
}
