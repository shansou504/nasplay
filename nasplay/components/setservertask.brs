sub init()
    m.top.functionName = "setServer"
end sub 
sub setServer()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    urlTransfer.AddHeader("Content-Type", "application/json")
    response = urlTransfer.PostFromString(m.top.server)
end sub 
