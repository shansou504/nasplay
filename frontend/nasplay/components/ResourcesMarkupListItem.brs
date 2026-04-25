sub init()
    m.poster = m.top.findNode("ResourcesPoster")
    m.title = m.top.findNode("ResourcesTitle")
    m.description = m.top.findNode("ResourcesDescription")
end sub

sub itemContentChanged()
    m.itemcontent = m.top.itemContent
    m.poster.uri = m.itemcontent.FHDPosterUrl
    m.title.text = m.itemcontent.Title
    m.description.text = m.itemcontent.Description
end sub