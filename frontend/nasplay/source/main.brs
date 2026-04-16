sub Main(args as Dynamic)
    screen=CreateObject("roSGScreen")
    m.port=CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    input=CreateObject("roInput")
    input.setMessagePort(m.port)
    scene=screen.CreateScene("MainScene")
    screen.show()
    if args <> invalid then
        scene.launchArgs = args
    end if
    while(true)
        msg=wait(0, m.port)
        msgType=type(msg)
        if msgType="roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType="roInputEvent"
            if msg.isInput() then
                info = msg.getInfo()
                if info <> invalid then
                    scene.inputArgs = info
                end if
            end if
        end if
    end while
end sub
