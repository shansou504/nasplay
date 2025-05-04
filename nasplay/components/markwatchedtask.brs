sub init()
    m.top.functionName = "markWatched"
end sub 
sub markWatched()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    response = urlTransfer.GetToString()
end sub 