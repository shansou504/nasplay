sub init()
    m.top.id = "SeriesGridPanel"
    m.top.panelSize = "wide"
    m.top.hasNextPanel = true
    m.SeriesPosterGrid = m.top.findNode("SeriesPosterGrid")
    m.top.grid = m.SeriesPosterGrid
    m.SeriesPosterGrid.observeField("itemFocused", "OnItemFocused")
    m.SeriesPosterGrid.observeField("content", "OnContentChanged")
end sub

sub OnItemFocused()
    UpdateLabels()
end sub

sub OnContentChanged()
    UpdateLabels()
end sub

sub UpdateLabels()
    if m.SeriesPosterGrid.content <> invalid then
        total = m.SeriesPosterGrid.content.getChildCount()
        index = m.SeriesPosterGrid.itemFocused
        if index >= 0 and total > 0 then
            m.top.rightLabel.text = (index + 1).toStr() + " of " + total.toStr()
        end if
    end if
end sub
