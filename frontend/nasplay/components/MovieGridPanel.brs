sub init()
    m.top.id = "MovieGridPanel"
    m.top.panelSize = "wide"
    m.top.hasNextPanel = true
    m.MoviePosterGrid = m.top.findNode("MoviePosterGrid")
    m.top.grid = m.MoviePosterGrid
    m.top.observeField("createNextPanelIndex", "OnCreateNextPanel")
end sub

sub OnCreateNextPanel()
    if m.MoviePosterGrid.content = invalid then return
    total = m.MoviePosterGrid.content.getChildCount()
    index = m.top.createNextPanelIndex
    if index >= 0 and total > 0 then
        m.top.rightLabel.text = (index + 1).toStr() + " of " + total.toStr()
        item = m.MoviePosterGrid.content.getChild(index)
        if item <> invalid then
            m.top.leftLabel.text = item.Title
        end if
    end if
end sub