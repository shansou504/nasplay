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
    m.markwatchedtask = CreateObject("roSGNode", "MarkWatchedTask")
    m.markunwatchedtask = CreateObject("roSGNode", "MarkUnwatchedTask")
    m.videogroup = CreateObject("roSGNode", "VideoGroup")
    m.video = m.videogroup.findNode("video")
    m.video.ObserveField("state", "controlvideoplay")

    ' SCREEN STACK SECTION
    m.screenarray = CreateObject("roArray", 10, true)

    ' DEEP LINK SECTION
    m.deepLinkHandled = false
    m.deepLinkEpisodeSeriesId = invalid
    m.deepLinkEpisodeSeasonId = invalid
    m.deepLinkEpisodeEpisodeId = invalid
    m.seasonHandled = false
    m.episodeHandled = false
    m.lastWatchedEpisode = invalid
    m.lastWatchedSeason = invalid
    m.nextInSeason = false
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
    m.keyboarddialog = createObject("roSGNode", "StandardKeyboardDialog")
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
        if m.movies.count() > 0 then
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
        end if
        m.movierowlist.content = m.moviecontent
    end if

    m.series = ParseJson(m.mediatask.content)
    seriescategories = CreateObject("roArray", 10, true)
    if m.series <> invalid then
        m.seriescontent = CreateObject("roSGNode", "ContentNode")
        m.seriescontent.setField("id", "seriescontent")
        if m.series.count() > 0 then
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
        end if
        m.seriesrowlist.content = m.seriescontent
    end if
    if m.deepLinkLaunchArgs <> invalid and m.deepLinkLaunchArgs.contentId <> invalid and m.deepLinkLaunchArgs.mediaType <> invalid then
        m.deepLinkLaunchInitiated = true
        OnInputDeepLinking(invalid)
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
    if m.deepLinkHandled then
        m.top.deepLinkHandled = true
        m.deepLinkHandled = false
    end if
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
    if m.deepLinkHandled then
        showseasons()
    end if
end sub

sub showseasons()
    m.seasons = ParseJson(m.mediatask.content)
    m.seasoncontent = CreateObject("roSGNode", "ContentNode")
    m.seasoncontent.setField("id", "seasoncontent")
    if m.seasons <> invalid then
        if m.seasons.count() > 0
            for i = m.seasons.count() - 1 to 0 step -1
                if m.seasons[i].ContentType <> "season" OR Str(m.seasons[i].SeriesId).Trim() <> m.selectedseries.id then                
                    m.seasons.Delete(i)
                end if
            end for
        end if
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
    m.nextInSeason = false
    if m.deepLinkHandled then
        seasons = m.seasonlabellist.content.getChildren(-1, 0)
        if m.deepLinkEpisodeSeasonId = invalid then 'handle series deep link
            episodes = ParseJson(m.mediatask.content)
            episodes.SortBy("EpisodeNumber")
            episodearray = CreateObject("roArray", 600, true)
            for each season in seasons
                for each episode in episodes
                    if episode.ContentType = "episode" and episode.SeasonID <> invalid and Str(episode.SeasonID).trim() = season.id and episode.Watched = 1 then
                        episodearray.Push(episode)
                    end if
                end for
            end for
            lastWatchedSeasonID = invalid
            if episodearray.count() > 0
                m.lastWatchedEpisode = episodearray.Peek()
                lastWatchedSeasonID = Str(episodearray.Peek().SeasonID).trim()
            end if
            if lastWatchedSeasonID <> invalid then
                for i = 0 to seasons.count() - 1
                    if seasons[i].ID = lastWatchedSeasonID then
                        m.lastWatchedSeason = m.seasonlabellist.content.getChild(i)
                        if m.lastWatchedEpisode.EpisodeNumber + 1 <= m.lastWatchedSeason.NumEpisodes then
                            m.nextInSeason = true   
                            m.seasonlabellist.jumpToItem = i
                            exit for
                        else if i < seasons.count() - 1 then
                            m.seasonlabellist.jumpToItem = i + 1
                            exit for
                        else
                            'This is probably not the best time to mark unwatched. It should probably happen after
                            'finishing the video like when we mark watched, but we don't have any of the logic to
                            'identify if it's the last episode of the series there. One issue, regardless of where
                            'we mark or unmark is we're not refreshing the mediatask.content after marking/unmarking
                            'so if a user tries to deep link multpile times after marking/unmarking this logic won't
                            'run correctly because the media we've store locally is out of sync with the database.
                            m.markunwatchedtask.contenturi = m.server + "/markunwatched/" + Str(m.lastWatchedEpisode.SeriesID).trim()
                            markunwatched()
                            m.seasonlabellist.jumpToItem = 0
                            exit for
                        end if
                    end if
                end for
            else
                m.seasonlabellist.jumpToItem = 0
            end if
            m.seasonHandled = true
        else 'handle episode deep link
            for i=0 to seasons.count() - 1
                if seasons[i].id = m.deepLinkEpisodeSeasonId
                    m.seasonHandled = true
                    m.seasonlabellist.jumpToItem = i
                    exit for
                end if
            end for
        end if
    end if
    m.seasonfocused = m.seasonlabellist.content.getChild(m.seasonlabellist.itemFocused)
    m.episodes = ParseJson(m.mediatask.content)
    m.episodecontent = CreateObject("roSGNode", "ContentNode")
    m.episodecontent.setField("id", "episodescontent")
    if m.episodes <> invalid then
        if m.episodes.count() > 0
            for i = m.episodes.count() - 1 to 0 step -1
                if m.episodes[i].ContentType <> "episode" OR Str(m.episodes[i].SeasonID).Trim() <> m.seasonfocused.id then
                    m.episodes.Delete(i)
                end if
            end for
        end if
        m.episodes.SortBy("EpisodeNumber")
        for each episode in m.episodes
            episodenode = m.episodecontent.createChild("ContentNode")
            episodenode.setFields(episode)
            episodenode.setField("EpisodeNumber", Str(episode.EpisodeNumber).trim())
        end for
        m.episodemarkuplist.content = m.episodecontent
    end if
    if m.seasonHandled then
        m.seasonHandled = false
        showepisodes()
    end if
end sub

sub showepisodes()
    m.episodemarkuplist.setFocus(true)
end sub

sub updateepisodenumber()
    m.episodenumber.text = m.episodemarkuplist.content.getChild(m.episodemarkuplist.itemFocused).EpisodeNumber + " of " + Str(m.episodemarkuplist.content.getChildCount()).trim()
    m.episodenumber.visible = true
    m.episodeHandled = false
    if m.deepLinkHandled then
        episodes = m.episodemarkuplist.content.getChildren(-1, 0)
        if m.deepLinkEpisodeEpisodeId <> invalid then
            for i=0 to episodes.count() - 1
                if episodes[i].id = m.deepLinkEpisodeEpisodeId then
                    m.episodeHandled = true
                    m.episodemarkuplist.jumpToItem = i
                    exit for
                end if
            end for
        else if m.lastWatchedEpisode <> invalid
            if m.nextInSeason then
                for i=0 to episodes.count() - 1
                    if episodes[i].id = Str(m.lastWatchedEpisode.ID).trim() then
                        m.episodeHandled = true
                        m.episodemarkuplist.jumpToItem = i + 1
                        exit for
                    end if
                end for
            end if
        end if
        if not m.episodeHandled then
            m.episodemarkuplist.jumpToItem = 0
        end if
        m.top.episodeHandled = true
        m.deepLinkHandled = false
    end if
end sub

' VIDEO PLAYER SECTION
sub playbuttonselected()
    m.screenarray.Push({previousscreen: m.detailsgroup, previouschildfocus: m.detailsbutton, currentscreen: m.videogroup, currentchildfocus: m.video
})
    playvideo(m.selectedmovie)
end sub

sub callplayvideo()
    m.episodeselected = m.episodemarkuplist.content.getChild(m.episodemarkuplist.itemFocused)
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
        markwatched()
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

sub markwatched()
    m.markwatchedtask.contenturi = m.server + "/markwatched/" + m.video.content.id
    m.markwatchedtask.control = "RUN"
end sub

sub markunwatched()
    m.markunwatchedtask.control = "RUN"
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

' DEEP LINK SECTION
sub InitDeepLinkLaunch()
    m.deepLinkLaunchArgs = m.top.launchArgs
    m.deepLinkLaunchInitiated = false
end sub

sub OnInputDeepLinking(event as Object)
    m.deepLinkHandled = false
    if event = invalid and m.deepLinkLaunchInitiated then
        m.deepLinkLaunchInitiated = false
        args = {contentId: m.deepLinkLaunchArgs.contentId, mediaType: m.deepLinkLaunchArgs.mediaType}
    else
        args = event.getData()
    end if
    if args <> invalid AND args.contentId <> invalid AND args.mediaType <> invalid then
        contentId = args.contentId
        mediaType = args.mediaType
        if mediaType = "movie"
            while m.screenarray.count() > 0
                closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
            end while
            showscreen(m.menugroup, m.menumarkuplist, m.moviegroup, m.movierowlist)
            rowarray = m.movierowlist.content.getChildren(-1, 0)
            for i=0 to m.movierowlist.content.getChildCount() - 1
                itemarray = rowarray[i].getChildren(-1, 0)
                found = false
                for j=0 to itemarray.count() - 1
                    if itemarray[j].id = contentId then
                        found = true
                        m.deepLinkHandled = true
                        m.movierowlist.jumpToRowItem = [i,j]
                        exit for
                    else
                        j++
                    end if
                end for
                if found then
                    exit for
                else
                    i++
                end if
            end for
        else if mediaType = "episode" or mediaType = "series" then
            m.media = ParseJson(m.mediatask.content)
            for each episode in m.media
                if Str(episode.id).trim() = contentId then
                    if mediaType = "episode" then
                        m.deepLinkEpisodeSeriesId = Str(episode.seriesid).trim()
                        m.deepLinkEpisodeSeasonId = Str(episode.seasonid).trim()
                        m.deepLinkEpisodeEpisodeId = Str(episode.id).trim()
                        exit for
                    else if mediaType = "series" then
                        m.deepLinkEpisodeSeriesId = Str(episode.id).trim()
                        exit for
                    end if
                end if
            end for
            while m.screenarray.count() > 0
                closescreen(m.screenarray.Peek().previousscreen, m.screenarray.Peek().previouschildfocus, m.screenarray.Peek().currentscreen)
            end while
            showscreen(m.menugroup, m.menumarkuplist, m.seriesgroup, m.seriesrowlist)
            rowarray = m.seriesrowlist.content.getChildren(-1, 0)
            for i=0 to m.seriesrowlist.content.getChildCount() - 1
                itemarray = rowarray[i].getChildren(-1, 0)
                found = false
                for j=0 to itemarray.count() - 1
                    if itemarray[j].id = m.deepLinkEpisodeSeriesId then
                        found = true
                        m.deepLinkHandled = true
                        m.seriesrowlist.jumpToRowItem = [i,j]
                        exit for
                    else
                        j++
                    end if
                end for
                if found then
                    exit for
                else
                    i++
                end if
            end for
        end if
    end if
end sub

sub PlayDeepLinkMedia()
    if m.top.deepLinkHandled then
        if m.movierowlist.isInFocusChain() then
            showdetailsgroup()
            playbuttonselected()
        end if
    end if
    if m.top.episodeHandled then
        if m.episodemarkuplist.isInFocusChain() then
            m.episodeHandled = false
            callplayvideo()
        end if
    end if
    m.top.deepLinkHandled = false
    m.top.episodeHandled = false
end sub