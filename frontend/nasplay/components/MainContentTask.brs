sub init()
    m.top.id = "MainContentTask"
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    xfer = createObject("roUrlTransfer")
    xfer.setUrl(m.top.contenturi)
    res = xfer.GetToString()
    m.top.content = res
end sub