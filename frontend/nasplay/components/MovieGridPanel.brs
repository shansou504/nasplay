sub init()
    m.top.id = "MovieGridPanel"
    m.top.panelSize = "wide"
    m.top.overhangTitle = "Movies"
    m.top.hasNextPanel = true
    m.MoviePosterGrid = m.top.findNode("MoviePosterGrid")
    m.top.grid = m.MoviePosterGrid
end sub