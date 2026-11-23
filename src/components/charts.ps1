# Chart components (build-time inline SVG, no JS)

function Get-BarChart($labels, $values, [string]$unit, [string]$desc) {
  $w = 600; $h = 280; $padL = 16; $padR = 16; $padT = 28; $padB = 40
  $max = ($values | Measure-Object -Maximum).Maximum
  $step = [math]::Pow(10, [math]::Floor([math]::Log10($max)))
  $top = [math]::Ceiling($max / $step) * $step
  $n = $values.Count
  $slot = ($w - $padL - $padR) / $n
  $bw = [math]::Floor($slot * 0.55)
  $plotH = $h - $padT - $padB
  $svg = "<svg class=`"chart`" viewBox=`"0 0 $w $h`" role=`"img`" aria-label=`"$(Esc $desc)`"><line x1=`"$padL`" y1=`"$($h - $padB)`" x2=`"$($w - $padR)`" y2=`"$($h - $padB)`" stroke=`"#8A97AB`"/>"
  for ($i = 0; $i -lt $n; $i++) {
    $bh = [math]::Round($values[$i] / $top * $plotH, 1)
    $x = [math]::Round($padL + $slot * $i + ($slot - $bw) / 2, 1)
    $y = [math]::Round($h - $padB - $bh, 1)
    $fill = if ($i -eq $n - 1) { '#0B3D91' } else { '#6FA3E8' }
    $cx = [math]::Round($x + $bw / 2, 1)
    $svg += "<rect x=`"$x`" y=`"$y`" width=`"$bw`" height=`"$bh`" fill=`"$fill`" rx=`"2`"/>"
    $svg += "<text x=`"$cx`" y=`"$($y - 6)`" text-anchor=`"middle`" font-size=`"14`" font-weight=`"700`" fill=`"#1A2433`">$(Format-Num $values[$i])</text>"
    $svg += "<text x=`"$cx`" y=`"$($h - $padB + 22)`" text-anchor=`"middle`" font-size=`"13`" fill=`"#4A5568`">$(Esc $labels[$i])</text>"
  }
  $svg += "</svg>"
  return $svg
}

function Get-ShareBars($items) {
  # $items: objects with name, sales, class
  $total = 0; foreach ($i in $items) { $total += $i.sales }
  $rows = ''
  foreach ($i in $items) {
    $pct = [math]::Round($i.sales / $total * 100, 1)
    $rows += "<div class=`"share-row`"><span class=`"share-name`">$(Esc $i.name)</span><span class=`"share-track`" aria-hidden=`"true`"><span class=`"share-bar $($i.class)`" style=`"width:$pct%`"></span></span><span class=`"share-val`">$(Format-Num $i.sales)億円(${pct}%)</span></div>"
  }
  return "<div class=`"share`" data-dyn=`"fin-seg`">$rows</div>"
}
