sub init()
    m.top.functionName="GetContent"    
end sub
function GetContent()
    m.seriescontent=CreateObject("roSGNode", "ContentNode")
    xfer=CreateObject("roURLTransfer")
    xfer.SetURL(m.top.contenturi + "/categories/contenttype_id/2")
    rspcategory=xfer.GetToString()
    jsoncategory=ParseJson(rspcategory)
    if jsoncategory <> invalid
        for each objcategory in jsoncategory
            m.category=m.seriescontent.createChild("ContentNode")
            m.category.setField("title",objcategory.category)
            xfer.setURL(m.top.contenturi + "/contenttype/series/category/" + objcategory.category)
            rspseriesbycategory=xfer.GetToString()
            jsonseriesbycategory=ParseJson(rspseriesbycategory)
            if jsonseriesbycategory <> invalid
                for each cat in jsonseriesbycategory
                    m.contentNode=m.category.createChild("ContentNode")
                    m.contentNode.setFields(cat)
                end for
            end if
        end for
        m.top.content=m.seriescontent
    end if
end function