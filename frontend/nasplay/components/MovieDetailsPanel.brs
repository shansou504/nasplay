sub init()
    m.top.id = "MovieDetailsPanel"
    m.top.focusable = true
    m.top.observeField("focusedChild", "PlayButtonFocus")
    m.top.panelSize = "narrow"
    m.top.hasNextPanel = false
    m.titleLabel = m.top.findNode("Title")
    m.ratingReleaseDate = m.top.findNode("RatingReleaseDate")
    m.moviePoster = m.top.findNode("MoviePoster")
    m.description = m.top.findNode("Description")
    m.playButton = m.top.findNode("PlayButton")
    m.playButton.showFocusFootprint = true
end sub

sub UpdatePoster()
    m.posterNode = m.top.content
    m.moviePoster.uri = m.posterNode.FHDPosterUrl
    m.titleLabel.text = m.posterNode.Title
    m.description.text = m.posterNode.Description
    info = ""
    if m.posterNode.Rating <> "" then info = "Rated: " + m.posterNode.Rating
    if m.posterNode.ReleaseDate <> "" then
        if info <> "" then info = info + "  |  "
        info = info + m.posterNode.ReleaseDate
    end if
    m.ratingReleaseDate.text = info
    ' Position play button below description
    descRect = m.description.boundingRect()
    m.playButton.translation = [0, descRect.y + descRect.height + 15]
end sub

sub PlayButtonFocus()
    if m.top.hasFocus() then
        m.playButton.setFocus(true)
    end if
end sub