sub init()
    m.top.functionName = "getTimeStamp"
end sub 
sub getTimeStamp()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    response = urlTransfer.GetToString()
    m.top.output = response
end sub 