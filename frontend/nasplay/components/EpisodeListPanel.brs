sub init()
    m.top.id = "EpisodeListPanel"
    m.top.panelSize = "wide"
    m.top.hasNextPanel = false
    m.episodeMarkupList = m.top.findNode("EpisodeMarkupList")
    m.top.list = m.episodeMarkupList
    m.episodeMarkupList.observeField("itemFocused", "UpdateLabels")
    m.episodeMarkupList.observeField("content", "UpdateLabels")
end sub

sub UpdateLabels()
    if m.episodeMarkupList.content = invalid then return
    total = m.episodeMarkupList.content.getChildCount()
    index = m.episodeMarkupList.itemFocused
    if index >= 0 and total > 0 then
        item = m.episodeMarkupList.content.getChild(index)
        if item <> invalid then
            m.top.rightLabel.text = "Episode " + item.EpisodeNumber + " of " + total.toStr()
        end if
    end if
end sub