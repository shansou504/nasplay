sub init()
    m.top.id = "SeasonListPanel"
    m.top.overhangTitle = "Seasons"
    m.top.panelSize = "narrow"
    m.top.hasNextPanel = true
    m.seasonLabelList =  m.top.findNode("SeasonLabelList")
    m.top.list =  m.seasonLabelList
end sub
