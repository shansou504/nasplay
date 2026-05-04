sub init()
    m.poster = m.top.findNode("EpisodePoster")
    m.title = m.top.findNode("EpisodeTitle")
    m.description = m.top.findNode("EpisodeDescription")
    m.title.color = "#d79921"
end sub

sub itemContentChanged()
    m.itemcontent = m.top.itemContent
    m.poster.uri = m.itemcontent.LandscapeUrl
    m.title.text = m.itemcontent.Title
    m.description.text = m.itemcontent.Description
end sub

sub ChangeColor()
    if m.top.itemHasFocus then
        m.title.color = "#282828"
        m.description.color = "#282828"
    else
        m.title.color = "#d79921"
        m.description.color = "#ebdbb2"
    end if
end sub