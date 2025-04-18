sub init()
    m.top.id="EpisodeItem"
    m.itembackground=m.top.findNode("episodeBackground")
    m.itemicon=m.top.findNode("episodeItemPoster")
    m.itemlabel=m.top.findNode("episodeItemTitle")
    m.itemdescription=m.top.findNode("episodeItemDescription")
end sub
sub showcontent()
    itemcontent=m.top.itemContent
    m.itemicon.uri=itemcontent.fhdposterurl
    m.itemlabel.text=itemcontent.title
    m.itemdescription.text=itemcontent.description
end sub