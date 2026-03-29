sub init()
    m.top.functionName = "SetTimestamp"
end sub

sub SetTimestamp()
    urlTransfer = createObject("roUrlTransfer")
    urlTransfer.setUrl(m.top.contenturi)
    urlTransfer.AddHeader("Content-Type", "application/json")
    urlTransfer.PostFromString(m.top.content)
end sub
