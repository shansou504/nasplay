sub init()
    m.poster = m.top.findNode("EpisodePoster")
    m.title = m.top.findNode("EpisodeTitle")
    m.description = m.top.findNode("EpisodeDescription")
    m.episodenumber = m.top.findNode("EpisodeNumber")
end sub
sub itemContentChanged()
    m.itemcontent = m.top.itemContent
    m.poster.uri = m.itemcontent.FHDPosterUrl
    m.title.text = m.itemcontent.Title
    m.description.text = m.itemcontent.Description
    m.episodenumber.text = m.itemcontent.EpisodeNumber
end sub