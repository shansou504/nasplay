sub init()
    m.server = getserver()
    m.top.id = "MainScene"
    m.top.backgroundURI = "pkg:/images/background_1280x720.png"
    m.mediatask = CreateObject("roSGNode", "MediaTask")
    m.mediatask.contenturi = m.server + "/media"
    m.mediatask.ObserveField("content","updatemedia")
    m.mediatask.control = "RUN"
    
    ' MENU SECTION ###
    m.menugroup = CreateObject("roSGNode", "MenuGroup")
    m.menucontent = CreateObject("roSGNode", "MenuContent")
    m.menumarkuplist = m.menugroup.findNode("menuMarkupList")
    m.menumarkuplist.content = m.menucontent
    m.menumarkuplist.ObserveField("itemSelected","showmedia")

    m.top.backgroundURI = "pkg:/images/menu_1280x720.png"
    m.top.appendChild(m.menugroup)
    m.menugroup.setFocus(true)
    m.top.SignalBeacon("AppLaunchComplete")

    m.moviegroup = CreateObject("roSGNode", "MovieGroup")
    m.movietitle = m.moviegroup.findNode("movieTitle")
    m.movierowlist = m.moviegroup.findNode("movieRowList")
    m.movierowlist.ObserveField("rowItemFocused", "updatedetails")
    m.movierowlist.ObserveField("rowItemSelected", "showdetailsgroup")

    m.seriesgroup = CreateObject("roSGNode", "SeriesGroup")
    m.seriesgrouptitle = m.seriesgroup.findNode("seriesGroupTitle")
    m.seriesrowlist = m.seriesgroup.findNode("seriesRowList")
    m.seriesrowlist.ObserveField("rowItemFocused", "updateseasons")
    m.seriesrowlist.ObserveField("rowItemSelected", "showseasons")

    ' MOVIE SECTION
    m.detailsgroup = CreateObject("roSGNode", "DetailsGroup")
    m.detailsbutton = m.detailsgroup.findNode("playbutton")
    m.detailsbutton.ObserveField("buttonSelected", "playbuttonselected")
    m.titlelabel = m.detailsgroup.findNode("titleLabel")
    m.ratinglabel = m.detailsgroup.findNode("ratingLabel")
    m.backdrop = m.detailsgroup.findNode("backdrop")
    m.descriptionlabel = m.detailsgroup.findNode("descriptionLabel")

    ' SHOW SECTION
    m.seasongroup = CreateObject("roSGNode", "SeasonGroup")
    m.seriestitle = m.seasongroup.findNode("seriesTitle")
    m.seriesbackdrop = m.seasongroup.findNode("seriesBackdrop")
    m.seriesdescription = m.seasongroup.findNode("seriesDescription")
    m.seasonlabellist = m.seasongroup.findNode("seasonLabelList")
    m.episodenumber = m.seasongroup.findNode("episodeNumber")
    m.seasonlabellist.ObserveField("itemFocused", "updateepisodes")
    m.seasonlabellist.ObserveField("itemSelected", "showepisodes")
    m.episodemarkuplist = m.seasongroup.findNode("episodeMarkupList")
    m.episodemarkuplist.ObserveField("itemFocused", "updateepisodenumber")
    m.episodemarkuplist.ObserveField("itemSelected", "callplayvideo")

    ' VIDEO PLAYER SECTION
    m.gettimestamptask = CreateObject("roSGNode", "GetTimeStampTask")
    m.gettimestamptask.ObserveField("output", "setretrievedtimestamp")
    m.timer = m.top.findNode("timer")
    m.timer.ObserveField("fire","callsettimestamp")
    m.settimestamptask = CreateObject("roSGNode", "SetTimeStampTask")
    m.videogroup = CreateObject("roSGNode", "VideoGroup")
    m.video = m.videogroup.findNode("video")
    m.video.ObserveField("state", "controlvideoplay")

    ' SCREEN STACK SECTION
    m.screenarray = CreateObject("roArray", 10, true)
end sub

' SERVER SECTION
Function getserver() As Dynamic
     m.savedserver = CreateObject("roRegistrySection", "savedserver")
     if m.savedserver.Exists("address")
         return m.savedserver.Read("address")
     endif
     return "http://localhost:1234/"
End Function

sub showdialog()
    m.keyboarddialog = createObject("roSGNode", "KeyboardDialog")
    m.keyboarddialog.ObserveField("buttonSelected","setserver")
    m.keyboarddialog.title = "Server"
    m.keyboarddialog.buttons = ["Save"]
    m.top.dialog = m.keyboarddialog
end sub

sub setserver()
    m.savedserver.Write("address",m.keyboarddialog.text)
    m.savedserver.flush()
    m.server = getserver()
    m.mediatask.contenturi = m.server + "/media"
    m.mediatask.control = "RUN"
    m.keyboarddialog.close = true
    m.menugroup.setFocus(true)
end sub

' MENU SECTION
sub showmedia()
    if m.menumarkuplist.itemFocused = 0 AND m.movierowlist.content <> invalid then
        showscreen(m.menugroup, m.menumarkuplist, m.moviegroup, m.movierowlist)
    else if m.menumarkuplist.itemFocused = 1 AND m.seriesrowlist.content <> invalid then
        showscreen(m.menugroup, m.menumarkuplist, m.seriesgroup, m.seriesrowlist)
    else if m.menumarkuplist.itemFocused = 2 then
        showdialog()
    end if
end sub

sub showscreen(previousscreen, previouschildfocus, currentscreen, currentchildfocus)
    m.screenarray.Push({previousscreen: previousscreen, previouschildfocus: previouschildfocus, currentscreen: currentscreen, currentchildfocus: currentchildfocus})
    m.top.appendChild(currentscreen)
    currentchildfocus.setFocus(true)
end sub

sub closescreen(previousscreen, previouschildfocus, currentscreen)
    m.top.removeChild(currentscreen)
    previousscreen.findNode(previouschildfocus.id).setFocus(true)
    m.screenarray.Pop()
end sub

' MEDIA SECTION
sub updatemedia()
    m.movies = ParseJson(m.mediatask.content)
    moviecategories = CreateObject("roArray", 10, true)
    if m.movies <> invalid then
        m.moviecontent = CreateObject("roSGNode", "ContentNode")
        m.moviecontent.setField("id", "moviecontent")
        for i = m.movies.count() - 1 to 0 step -1
            if m.movies[i].ContentType <> "movie" then
                m.movies.Delete(i)
            end if
        end for
        m.movies.SortBy("Categories")
        for each movie in m.movies
            duplicatecategory = false
            for each category in moviecategories
                if category.category = movie.categories then
                    duplicatecategory = true
                end if
            end for
            if not duplicatecategory then
                moviecategories.Push({"category": movie.categories, "movies": [movie]})
            else
                for each category in moviecategories
                    if category.category = movie.categories then
                        category.movies.Push(movie)
                    end if
                end for
            end if
        end for
        for each category in moviecategories
            category.movies.SortBy("Title")
            moviecategory = m.moviecontent.createChild("ContentNode")
            moviecategory.setField("id", "movie_" + category.category)
            moviecategory.setField("title", category.category)
            for each movie in category.movies
                movienode = moviecategory.createChild("ContentNode")
                movienode.setFields(movie)
            end for
        end for
        m.movierowlist.content = m.moviecontent
    end if

    m.series = ParseJson(m.mediatask.content)
    seriescategories = CreateObject("roArray", 10, true)
    if m.series <> invalid then
        m.seriescontent = CreateObject("roSGNode", "ContentNode")
        m.seriescontent.setField("id", "seriescontent")
        for i = m.series.count() - 1 to 0 step -1
            if m.series[i].ContentType <> "series" then
                m.series.Delete(i)
            end if
        end for
        m.series.SortBy("Categories")
        for each series in m.series
            duplicatecategory = false
            for each category in seriescategories
                if series.Categories = category.category then
                    duplicatecategory = true
                end if
            end for
            if not duplicatecategory then
                seriescategories.Push({"category": series.Categories, "series": [series]})
            else
                for each category in seriescategories
                    if series.Categories = category.category then
                        category.series.Push(series)
                    end if
                end for
            end if
        end for
        for each category in seriescategories
            category.series.SortBy("Title")
            seriescategory = m.seriescontent.createChild("ContentNode")
            seriescategory.setField("id", "series_" + series.Categories)
            seriescategory.setField("title", series.Categories)
            for each series in category.series
                seriesnode = seriescategory.createChild("ContentNode")
                seriesnode.setFields(series)
            end for
        end for
        m.seriesrowlist.content = m.seriescontent
    end if
end sub

' MOVIE SECTION
sub updatedetails()
    m.selectedmovie = m.movierowlist.content.getChild(m.movierowlist.itemFocused).getChild(m.movierowlist.rowItemFocused[1])
    m.movietitle.text = m.selectedmovie.title
    m.titlelabel.setField("text", m.selectedmovie.title)
    m.ratinglabel.setField("text", m.selectedmovie.rating)
    m.backdrop.setField("uri", m.selectedmovie.fhdposterurl)
    m.descriptionlabel.setField("text", m.selectedmovie.description)
end sub

sub showdetailsgroup()
    showscreen(m.moviegroup, m.movierowlist, m.detailsgroup, m.detailsbutton)
end sub

' SHOW SECTION
sub updateseasons()
    m.selectedseries = m.seriesrowlist.content.getChild(m.seriesrowlist.itemFocused).getChild(m.seriesrowlist.rowItemFocused[1])
    m.seriesgrouptitle.text = m.selectedseries.title
    m.seriesbackdrop.uri = m.selectedseries.fhdposterurl
    m.seriestitle.text = m.selectedseries.title
    m.seriesdescription.text = m.selectedseries.description
end sub

sub showseasons()
    m.seasons = ParseJson(m.mediatask.content)
    m.seasoncontent = CreateObject("roSGNode", "ContentNode")
    m.seasoncontent.setField("id", "seasoncontent")
    if m.seasons <> invalid then
        for i = m.seasons.count() - 1 to 0 step -1
            if m.seasons[i].ContentType <> "season" OR Str(m.seasons[i].SeriesId).Trim() <> m.selectedseries.id then                
                m.seasons.Delete(i)
            end if
        end for
        m.seasons.SortBy("TitleSeason")
        for each season in m.seasons
            seasonnode = m.seasoncontent.createChild("ContentNode")
            seasonnode.setFields(season)
        end for
        m.seasonlabellist.content = m.seasoncontent
    end if
    showscreen(m.seriesgroup, m.seriesrowlist, m.seasongroup, m.seasonLabelList)
end sub

sub updateepisodes()
    m.seasonfocused = m.seasonlabellist.content.getChild(m.seasonlabellist.itemFocused)
    m.episodes = ParseJson(m.mediatask.content)
    m.episodecontent = CreateObject("roSGNode", "ContentNode")
    m.episodecontent.setField("id", "episodescontent")
    if m.episodes <> invalid then
        for i = m.episodes.count() - 1 to 0 step -1
            if m.episodes[i].ContentType <> "episode" OR Str(m.episodes[i].SeasonID).Trim() <> m.seasonfocused.id then
                m.episodes.Delete(i)
            end if
        end for
        m.episodes.SortBy("EpisodeNumber")
        for each episode in m.episodes
            episodenode = m.episodecontent.createChild("ContentNode")
            episodenode.setFields(episode)
            episodenode.setField("EpisodeNumber", Str(episode.EpisodeNumber).trim())
        end for
        m.episodemarkuplist.content = m.episodecontent
    end if
end sub

sub showepisodes()
    m.episodemarkuplist.setFocus(true)
end sub

sub updateepisodenumber()
    m.episodenumber.text = m.episodemarkuplist.content.getChild(m.episodemarkuplist.itemFocused).EpisodeNumber + " of " + Str(m.episodemarkuplist.content.getChildCount()).trim()
    m.episodenumber.visible = true
end sub

' VIDEO PLAYER SECTION
sub playbuttonselected()
    m.screenarray.Push({previousscreen: m.detailsgroup, previouschildfocus: m.detailsbutton, currentscreen: m.videogroup, currentchildfocus: m.video
})
    playvideo(m.selectedmovie)
end sub

sub callplayvideo()
    m.episodeselected = m.episodemarkuplist.content.getChild(m.episodemarkuplist.itemSelected)
    m.screenarray.Push({previousscreen: m.seasongroup, previouschildfocus: m.episodemarkuplist, currentscreen: m.videogroup, currentchildfocus: m.video})
    playvideo(m.episodeselected)
end sub

sub playvideo(node)
    m.video.content = node
    m.gettimestamptask.contenturi = m.server + "/gettimestamp/" + m.video.content.id
    m.gettimestamptask.control = "RUN"
end sub

sub setretrievedtimestamp()
    begin = m.gettimestamptask.output
    if (begin <> invalid) then
        m.video.seek = begin
    end if
    m.video.control = "play"
    m.top.appendChild(m.videogroup)
    m.video.setFocus(true)
    m.timer.control = "start"
end sub

sub controlvideoplay()
    if (m.video.state = "finished") 
        m.video.control = "stop"
        m.timer.control = "stop"
        TimeStamp = Str(0)
        settimestamp(TimeStamp)
        closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
    end if
end sub

sub callsettimestamp()
    settimestamp(Str(m.video.position).trim())
end sub

sub settimestamp(TimeStamp)
    if (m.video.hasFocus()) then
        m.settimestamptask.contenturi = m.server + "/settimestamp/" + m.video.content.id + "/timestamp/" + TimeStamp
        m.settimestamptask.control = "RUN"
    else
        m.timer.control = "stop"
    end if
end sub

' REMOTE CONTROL SECTION
function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if (key = "back") then
            if (m.video.state = "playing" OR m.video.state = "paused" OR m.video.state = "buffering")
                m.video.control = "stop"
                m.timer.control = "stop"
                callsettimestamp()
                closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
            else
                if (m.screenarray.Count() > 0) then
                    if m.episodemarkuplist.hasFocus() then
                        m.seasonlabellist.setFocus(true)
                    else
                        closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
                    end if
                else
                    End
                end if
            end if
            return true
        else if (key = "right") then
            if (m.screenarray.count() < 1) then
                showmedia()
                return true
            else if (m.screenarray.Peek().currentchildfocus.id = "seasonLabelList") then
                showepisodes()
                return true
            end if
        else if (key = "left") then
            if m.episodemarkuplist.hasFocus() then
                m.seasonlabellist.setFocus(true)
            else if NOT m.video.hasFocus() then
                if (m.screenarray.count() > 0) then
                    closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
                end if
            end if
            return true
        end if
        return false
    end if
end function