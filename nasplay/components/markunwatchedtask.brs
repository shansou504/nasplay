sub init()
    m.top.functionName = "markUnwatched"
end sub 
sub markUnwatched()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    response = urlTransfer.GetToString()
end sub 