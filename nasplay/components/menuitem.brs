sub init()
    m.top.id="MenuItem"
    m.itemicon=m.top.findNode("itemIcon")
    m.itemlabel=m.top.findNode("itemLabel")
end sub
sub showcontent()
    itemcontent=m.top.itemContent
    m.itemicon.uri=itemcontent.url
    m.itemlabel.text=itemcontent.title
end sub