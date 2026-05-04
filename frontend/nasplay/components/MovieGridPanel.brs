sub init()
    m.top.id = "MovieGridPanel"
    m.top.overhangTitle = "Movies"
    m.top.panelSize = "wide"
    m.top.hasNextPanel = true
    m.MoviePosterGrid = m.top.findNode("MoviePosterGrid")
    m.top.grid = m.MoviePosterGrid
    m.MoviePosterGrid.observeField("itemFocused", "OnItemFocused")
    m.MoviePosterGrid.observeField("content", "OnContentChanged")
    m.top.rightLabel.color = "#458588"
end sub

sub OnItemFocused()
    UpdateLabels()
end sub

sub OnContentChanged()
    UpdateLabels()
end sub

sub UpdateLabels()
    if m.MoviePosterGrid.content = invalid then return
    total = m.MoviePosterGrid.content.getChildCount()
    index = m.MoviePosterGrid.itemFocused
    if index >= 0 and total > 0 then
        m.top.rightLabel.text = (index + 1).toStr() + " of " + total.toStr()
        item = m.MoviePosterGrid.content.getChild(index)
        if item <> invalid then
            m.top.overhangTitle = item.Title
        end if
    end if
end sub