sub init()
    m.top.functionName="GetContent"    
end sub
function GetContent()
    xfer=CreateObject("roURLTransfer")
    xfer.SetURL(m.top.contenturi)
    rsp=xfer.GetToString()
    m.top.content=rsp
end function