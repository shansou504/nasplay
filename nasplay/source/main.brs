Sub Main(args as Dynamic)
    showChannelSGScreen(args)
end sub
sub showChannelSGScreen(args)
    screen=CreateObject("roSGScreen")
    m.port=CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene=screen.CreateScene("MainScene")
    screen.show()
    scene.launchArgs = args
    inputObject=createobject("roInput")
    inputObject.setmessageport(m.port)
    while(true)
        msg=wait(0, m.port)
        msgType=type(msg)
        if msgType="roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roInputEvent"
            inputData = msg.getInfo()
            if inputData.DoesExist("mediaType") and inputData.DoesExist("contentId")
                deeplink = {
                    contentId: inputData.contentID
                    mediaType: inputData.mediaType
                }
                scene.inputArgs = deeplink
            end if
        end if
    end while
end sub
