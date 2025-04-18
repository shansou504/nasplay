sub init()
    m.top.id="SeriesItem"
    m.itemposter=m.top.findNode("itemPoster")
end sub
sub showcontent()
    itemcontent=m.top.itemContent
    m.itemposter.uri=itemcontent.HDPosterUrl
end sub
sub showfocus()
    scale = (1 + m.top.focusPercent * 0.08)
    m.itemposter.scale = [scale, scale]
end sub