sub init()
    m.top.functionName="GetContent"    
end sub
function GetContent()
    xfer=CreateObject("roURLTransfer")
    proto = Left(m.top.contenturi, 5)
    if proto = "https"
        xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        xfer.AddHeader("X-Roku-Reserved-Dev-Id", "")
        xfer.InitClientCertificates()
    end if
    xfer.SetURL(m.top.contenturi)
    rsp=xfer.GetToString()
    m.top.content=rsp
end function