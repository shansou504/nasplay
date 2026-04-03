sub init()
    m.top.id = "MovieDetailsPanel"
    m.top.panelSize = "narrow"
    m.top.hasNextPanel = false
    m.moviePoster =  m.top.findNode("MoviePoster")
    m.playButton = m.top.findNode("PlayButton")
    m.playButton.showFocusFootprint = true
    m.playButton.setFocus(true)
end sub

sub UpdatePoster()
    m.posterNode = m.top.content
    m.moviePoster.uri = m.posterNode.FHDPosterUrl
end sub