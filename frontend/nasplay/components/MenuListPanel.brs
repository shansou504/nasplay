sub init()
    m.top.id = "MenuListPanel"
    m.top.panelSize = "narrow"
    m.top.hasNextPanel = true
    m.menuLabelList =  m.top.findNode("MenuLabelList")
    m.top.list =  m.menuLabelList
    m.menuLabelList.setFocus(true)
end sub