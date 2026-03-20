sub init()
    m.top.id = "EpisodeContentTask"
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    xfer = createObject("roUrlTransfer")
    xfer.setUrl(m.top.contenturi)
    res = xfer.GetToString()
    m.top.content = res
end sub