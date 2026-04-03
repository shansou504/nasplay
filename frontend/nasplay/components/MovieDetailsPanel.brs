sub init()
    m.top.id = "MovieDetailsPanel"
    m.top.focusable = true
    m.top.observeField("focusedChild", "PlayButtonFocus")
    m.top.panelSize = "narrow"
    m.top.hasNextPanel = false
    m.moviePoster =  m.top.findNode("MoviePoster")
    m.playButton = m.top.findNode("PlayButton")
    m.playButton.showFocusFootprint = true
end sub

sub UpdatePoster()
    m.posterNode = m.top.content
    m.moviePoster.uri = m.posterNode.FHDPosterUrl
end sub

sub PlayButtonFocus()
    if m.top.hasFocus() then
        m.playButton.setFocus(true)
    end if
end sub