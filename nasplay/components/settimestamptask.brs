sub init()
    m.top.functionName = "setTimeStamp"
end sub 
sub setTimeStamp()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    response = urlTransfer.GetToString()
end sub 