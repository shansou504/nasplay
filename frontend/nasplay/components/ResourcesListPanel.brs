sub init()
    m.top.id = "ResourcesListPanel"
    m.top.overhangTitle = "Resources"
    m.top.panelSize = "wide"
    m.top.hasNextPanel = false
    m.top.focusable = false
    m.ResourcesMarkupList = m.top.findNode("ResourcesMarkupList")
    m.ResourcesMarkupList.drawFocusFeedback = false
    m.ResourcesMarkupList.drawFocusFeedbackOnTop = false
    m.ResourcesMarkupList.focusBitmapUri = ""
    m.ResourcesMarkupList.focusFootprintBitmapUri = ""
    m.top.list = m.ResourcesMarkupList
end sub