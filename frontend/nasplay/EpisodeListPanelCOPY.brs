sub init()
    m.top.id = "EpisodeListPanelCOPY"
    m.top.panelSize = "wide"
    m.episodeLabelList =  m.top.findNode("EpisodeMarkupList")
    m.top.list =  m.episodeLabelList
    m.top.list.setFocus(true)
end sub