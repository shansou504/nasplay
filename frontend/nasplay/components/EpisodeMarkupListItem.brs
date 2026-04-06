sub init()
    m.poster = m.top.findNode("EpisodePoster")
    m.title = m.top.findNode("EpisodeTitle")
    m.description = m.top.findNode("EpisodeDescription")
end sub

sub itemContentChanged()
    m.itemcontent = m.top.itemContent
    m.poster.uri = m.itemcontent.FHDPosterUrl
    m.title.text = m.itemcontent.Title
    m.description.text = m.itemcontent.Description
end sub

sub ChangeColor()
    if m.top.itemHasFocus then
        m.title.color = "#000000"
        m.description.color = "#000000"
    else
        m.title.color = "#FFFFFF"
        m.description.color = "#FFFFFF"
    end if
end sub
