sub init()
    m.top.id = "MainScene"
    m.top.backgroundURI = "pkg:/images/background_1280x720.png"
    m.top.overhang.logoURI = "pkg:/images/nasplay-logo-160x48.png"
    m.top.overhang.title = "nasplay"
    m.content_feed_certification = "https://shansou504.github.io/nasplay_content_feed_certification/content_feed_certification.json"
    m.server = GetServer()
    m.setServerTask = CreateObject("roSGNode", "SetServerTask")
    m.mainContentTask = CreateObject("roSGNode", "MainContentTask")
    m.mainContentTask.observeField("content", "OnMainContentTaskContent")
    if m.server = m.content_feed_certification
        m.mainContentTask.contenturi = m.server
    else
        m.mainContentTask.contenturi = m.server + "/content"
    end if
    m.mainContentTask.control = "RUN"
    m.setTimestampTask = CreateObject("roSGNode", "SetTimestampTask")
    m.menuListPanel = CreateObject("roSGNode", "MenuListPanel")
    m.menuListPanel.observeField("createNextPanelIndex", "UpdateSecondPanel")
    m.seriesGridPanel = CreateObject("roSGNode", "SeriesGridPanel")
    m.seriesGridPanel.observeField("createNextPanelIndex", "CreateSeasonListPanel")
    m.filteredSeasons = CreateObject("roSGNode", "ContentNode")
    m.seasonListPanel = CreateObject("roSGNode", "SeasonListPanel")    
    m.seasonListPanel.observeField("createNextPanelIndex", "CreateEpisodeListPanel")
    m.filteredEpisodes = CreateObject("roSGNode", "ContentNode")
    m.episodeListPanel = CreateObject("roSGNode", "EpisodeListPanel")
    m.episodeListPanel.list.observeField("itemFocused", "CreateEpisodeVideo")
    m.episodeListPanel.list.observeField("itemSelected", "PlayVideo")
    m.movieGridPanel = CreateObject("roSGNode", "MovieGridPanel")
    m.movieGridPanel.observeField("createNextPanelIndex", "CreateMovieDetailsPanel")
    m.movieDetailsPanel = CreateObject("roSGNode", "MovieDetailsPanel")
    m.movieDetailsPanelPlayButton = m.movieDetailsPanel.findNode("PlayButton")
    m.movieDetailsPanelPlayButton.observeField("buttonSelected", "PlayVideo")
    m.keyboardDialog = CreateObject("roSGNode", "StandardKeyboardDialog")
    m.keyboardDialog.ObserveField("buttonSelected","SetServer")
    m.keyboardDialog.title = "Server"
    m.keyboardDialog.buttons = ["Save"]
    m.resourcesListPanel = CreateObject("roSGNode", "ResourcesListPanel")
    m.playbackTimer = CreateObject("roSGNode", "Timer")
    m.playbackTimer.duration = 30
    m.playbackTimer.repeat = true
    m.playbackTimer.observeField("fire", "SetTimestampOnServer")
    m.videoNode = CreateObject("roSGNode", "Video")
    m.videoNode.observeField("state", "OnVideoStateChange")
    m.appLaunchCompleteFired = false
end sub

sub FireAppLaunchComplete()
    if m.appLaunchCompleteFired then return
    m.top.signalBeacon("AppLaunchComplete")
    m.appLaunchCompleteFired = true
end sub

Function GetServer() As Dynamic
    m.savedServer = CreateObject("roRegistrySection", "SavedServer")
    if m.savedServer.Exists("address")
        if m.savedServer.Read("address") <> ""
            return m.savedServer.Read("address")
        else
            return m.content_feed_certification
        end if
    else
        return m.content_feed_certification
    end if
End Function

sub SetServer()
    m.savedServer.Write("address", m.keyboardDialog.text)
    m.savedServer.flush()
    m.server = GetServer()
    m.setServerTask.contenturi = m.server + "/server"
    assocArray = {
        server: m.server
    }
    m.setServerTask.server = FormatJson(assocArray)
    m.setServerTask.control = "RUN"
    m.keyboardDialog.message = ["Saved. Please exit and reopen the app."]
end sub

sub OnMainContentTaskContent()
    m.series = invalid
    m.seasons = invalid
    m.episodes = invalid
    m.movies = invalid
    if m.mainContentTask.content <> invalid and m.mainContentTask.content <> "" then
        m.json = ParseJson(m.mainContentTask.content)
        m.series = GetContent("series")
        m.seasons = GetContent("season")
        m.episodes = GetContent("episode")
        m.movies = GetContent("movie")
    end if
    if m.series <> invalid then
        m.seriesGridPanel.grid.content = m.series
    end if
    if m.movies <> invalid then
        m.movieGridPanel.grid.content = m.movies
    end if
    m.top.panelSet.appendChild(m.menuListPanel)
    m.top.panelSet.appendChild(m.seriesGridPanel)
    m.menuListPanel.setFocus(true)
    if m.pendingArgs <> invalid then
        args = m.pendingArgs
        m.pendingArgs = invalid
        HandleDeepLink(args)
    else
        FireAppLaunchComplete()
    end if
end sub

function GetContent(contentType = invalid)
    parentNode = CreateObject("roSGNode", "ContentNode")
    if contentType <> invalid then
        for each item in m.json
            if item.ContentType = contentType then
                childNode = CreateObject("roSGNode", "ContentNode")
                childNode.setFields({
                    Title: item.Title,
                    Description: item.Description,
                    HDPosterUrl: item.HDPosterUrl,
                    ContentType: item.ContentType,
                    ReleaseDate: item.ReleaseDate,
                    Rating: item.Rating,
                    Url: item.Url,
                    SubtitleTracks: item.SubtitleTracks
                })
                ' EpisodeNumber is kept as INTEGER in database for sorting
                ' and converted to string here to match Roku's ContentNode schema
                if item.EpisodeNumber <> invalid
                    childNode.setField("EpisodeNumber", item.EpisodeNumber.toStr())
                end if
                if item.NumEpisodes <> invalid
                    childNode.setField("NumEpisodes", item.NumEpisodes.toStr())
                end if
                ' ID (uuid) maps to the built-in node id field
                childNode.id = item.ID
                ' Custom fields not in standard ContentNode schema
                childNode.addField("LandscapeUrl", "string", false)
                childNode.setField("LandscapeUrl", item.LandscapeUrl)
                childNode.addField("TitleSeason", "string", false)
                childNode.setField("TitleSeason", item.TitleSeason)
                childNode.addField("SeriesID", "string", false)
                childNode.setField("SeriesID", item.SeriesID)
                childNode.addField("SeasonID", "string", false)
                childNode.setField("SeasonID", item.SeasonID)
                childNode.addField("SecondaryTitle", "string", false)
                childNode.setField("SecondaryTitle", item.SecondaryTitle)
                childNode.addField("Timestamp", "float", false)
                childNode.setField("Timestamp", item.Timestamp)
                childNode.addField("Watched", "integer", false)
                childNode.setField("Watched", item.Watched)
                parentNode.appendChild(childNode)
            end if
        end for
    end if
    return parentNode
end function

sub UpdateSecondPanel()
    title = m.menuListPanel.list.content.getChild(m.menuListPanel.createNextPanelIndex).Title
    if title = "Shows" then
        m.menuListPanel.nextPanel = m.seriesGridPanel
    else if title = "Movies" then
        m.menuListPanel.nextPanel = m.movieGridPanel
    else if title = "Server" then
        m.keyboardDialog.message = ["Current server is " + m.server]
        m.top.dialog = m.keyboardDialog
        m.menuListPanel.nextPanel = invalid
    else if title = "Resources" then
        m.menuListPanel.nextPanel = m.resourcesListPanel
    else
        ' Prevent crash
        m.menuListPanel.nextPanel = invalid
    end if
end sub

sub CreateMovieDetailsPanel()
    content = m.movieGridPanel.grid.content.getChild(m.movieGridPanel.createNextPanelIndex)
    m.movieDetailsPanel.content = content
    m.movieGridPanel.nextPanel = m.movieDetailsPanel
    m.videoNode.content = content
end sub

sub CreateSeasonListPanel()
    if m.filteredSeasons.getChildCount() > 0 then
        children = m.filteredSeasons.getChildren(-1, 0)
        m.filteredSeasons.removeChildren(children)
    end if
    currentSeriesGridChild = m.seriesGridPanel.grid.content.getChild(m.seriesGridPanel.createNextPanelIndex)
    seasons = m.seasons.getChildren(-1, 0)
    for each season in seasons
        if season.SeriesID = currentSeriesGridChild.id then
            m.filteredSeasons.appendChild(season.clone(true))
        end if
    end for
    m.seasonListPanel.overhangTitle = currentSeriesGridChild.Title
    m.seasonListPanel.list.content = m.filteredSeasons
    m.seriesGridPanel.nextPanel = m.seasonListPanel
end sub

sub CreateEpisodeListPanel()
    if m.filteredEpisodes.getChildCount() > 0 then
        children = m.filteredEpisodes.getChildren(-1, 0)
        m.filteredEpisodes.removeChildren(children)
    end if
    currentSeasonListChild = m.seasonListPanel.list.content.getChild(m.seasonListPanel.createNextPanelIndex)
    episodes = m.episodes.getChildren(-1, 0)
    for each episode in episodes
        if episode.SeasonID = currentSeasonListChild.id then
            m.filteredEpisodes.appendChild(episode.clone(true))
        end if
    end for
    m.episodeListPanel.totalEpisodes = currentSeasonListChild.NumEpisodes
    m.episodeListPanel.list.content = m.filteredEpisodes
    m.seasonListPanel.nextPanel = m.episodeListPanel
end sub

sub CreateEpisodeVideo()
    content = m.episodeListPanel.list.content.getChild(m.episodeListPanel.list.itemFocused)
    m.videoNode.content = content
end sub

sub PlayVideo()
    m.top.appendChild(m.videoNode)
    m.videoNode.seek = m.videoNode.content.Timestamp
    m.videoNode.control = "play"
    m.videoNode.setFocus(true)
    m.playbackTimer.control = "start"
end sub

sub SetTimestampOnServer(ts = 9e30 as float)
    if m.videoNode.position = invalid then return
    if ts = 9e30 then ts = m.videoNode.position
    assocArray = {
        id: m.videoNode.content.id,
        ts: ts
    }
    if m.server <> m.content_feed_certification then
        m.setTimestampTask.contenturi = m.server + "/timestamp"
        m.setTimestampTask.content = FormatJson(assocArray)
        m.setTimestampTask.control = "RUN"
    end if
end sub

sub StopVideo(timestamp)
    SetTimestampOnServer(timestamp)
    m.videoNode.content.setField("Timestamp", timestamp)
    id = m.videoNode.content.id
    m.playbackTimer.control = "stop"
    m.videoNode.control = "stop"
    m.top.removeChild(m.videoNode)
    lastPanel = m.top.panelSet.getChild(m.top.panelSet.getChildCount() - 1)
    lastIndex = invalid
    if lastPanel <> invalid then
        if lastPanel.id = "MovieDetailsPanel" then
            for index = 0 to m.movieGridPanel.grid.content.getChildCount() - 1
                movieNode = m.movieGridPanel.grid.content.getChild(index)
                if movieNode.id = id then
                    lastIndex = index
                    movieNode.setField("Timestamp", timestamp)
                    exit for
                end if
            end for
            if lastIndex <> invalid then
                movieJson = m.movies.getChild(lastIndex)
                movieJson.setField("Timestamp", timestamp)
            end if
            m.movieDetailsPanelPlayButton.setFocus(true)
        else if lastPanel.id = "EpisodeListPanel" then
            m.episodeListPanel.setFocus(true)
        end if
    end if
end sub

sub OnVideoStateChange()
    if m.videoNode.state = "playing" then
        FireAppLaunchComplete()
    else if m.videoNode.state = "finished" then
        StopVideo(0)
    end if
end sub

sub OnLaunchArgs()
    HandleDeepLinkArgs(m.top.launchArgs)
end sub

sub OnInputArgs()
    if m.videoNode <> invalid and m.videoNode.hasFocus() then
        m.playbackTimer.control = "stop"
        m.videoNode.control = "stop"
        if m.videoNode.getParent() <> invalid then
            m.top.removeChild(m.videoNode)
        end if
    end if
    HandleDeepLinkArgs(m.top.inputArgs)
end sub

sub HandleDeepLinkArgs(args as Object)
    if args = invalid then return
    if args.contentId = invalid or args.mediaType = invalid then return
    if m.series = invalid and m.movies = invalid and m.episodes = invalid then
        m.pendingArgs = args
        return
    end if
    HandleDeepLink(args)
end sub

sub HandleDeepLink(args as Object)
    mt = LCase(args.mediaType)
    if mt = "movie" then
        DeepLinkToMovie(args.contentId)
    else if mt = "episode" then
        DeepLinkToEpisode(args.contentId)
    else if mt = "series" then
        episode = PickSeriesEpisode(args.contentId)
        if episode <> invalid then DeepLinkToEpisode(episode.id)
    end if
end sub

sub DeepLinkToMovie(movieId as String)
    movieIdx = FindChildIndexById(m.movies, movieId)
    if movieIdx < 0 then return
    menuIdx = FindMenuIndexByTitle("Movies")
    if menuIdx < 0 then return

    m.menuListPanel.list.jumpToItem = menuIdx
    m.menuListPanel.createNextPanelIndex = menuIdx
    UpdateSecondPanel()
    m.top.panelSet.replaceChild(m.movieGridPanel, 1)

    m.movieGridPanel.grid.jumpToItem = movieIdx
    m.movieGridPanel.createNextPanelIndex = movieIdx
    CreateMovieDetailsPanel()
    m.top.panelSet.appendChild(m.movieDetailsPanel)

    PlayVideo()
end sub

sub DeepLinkToEpisode(episodeId as String)
    episode = FindChildById(m.episodes, episodeId)
    if episode = invalid then return
    seasonIdx = FindChildIndexById(m.seasons, episode.SeasonID)
    if seasonIdx < 0 then return
    seasonNode = m.seasons.getChild(seasonIdx)
    seriesIdx = FindChildIndexById(m.series, seasonNode.SeriesID)
    if seriesIdx < 0 then return
    menuIdx = FindMenuIndexByTitle("Shows")
    if menuIdx < 0 then return

    m.menuListPanel.list.jumpToItem = menuIdx
    m.menuListPanel.createNextPanelIndex = menuIdx
    UpdateSecondPanel()

    m.seriesGridPanel.grid.jumpToItem = seriesIdx
    m.seriesGridPanel.createNextPanelIndex = seriesIdx
    CreateSeasonListPanel()
    m.top.panelSet.appendChild(m.seasonListPanel)

    localSeasonIdx = FindChildIndexById(m.filteredSeasons, seasonNode.id)
    if localSeasonIdx < 0 then return
    m.seasonListPanel.list.jumpToItem = localSeasonIdx
    m.seasonListPanel.createNextPanelIndex = localSeasonIdx
    CreateEpisodeListPanel()
    m.top.panelSet.appendChild(m.episodeListPanel)

    localEpisodeIdx = FindChildIndexById(m.filteredEpisodes, episodeId)
    if localEpisodeIdx < 0 then return
    m.episodeListPanel.list.jumpToItem = localEpisodeIdx
    m.videoNode.content = m.filteredEpisodes.getChild(localEpisodeIdx)

    PlayVideo()
end sub

function FindChildById(parent as Object, id as String) as Object
    if parent = invalid then return invalid
    for index = 0 to parent.getChildCount() - 1
        child = parent.getChild(index)
        if child.id = id then return child
    end for
    return invalid
end function

function FindChildIndexById(parent as Object, id as String) as Integer
    if parent = invalid then return -1
    for index = 0 to parent.getChildCount() - 1
        if parent.getChild(index).id = id then return index
    end for
    return -1
end function

function FindMenuIndexByTitle(title as String) as Integer
    content = m.menuListPanel.list.content
    if content = invalid then return -1
    for index = 0 to content.getChildCount() - 1
        if content.getChild(index).Title = title then return index
    end for
    return -1
end function

function PickSeriesEpisode(seriesId as String) as Object
    if m.episodes = invalid then return invalid
    firstMatch = invalid
    firstUnwatched = invalid
    inProgress = invalid
    for index = 0 to m.episodes.getChildCount() - 1
        ep = m.episodes.getChild(index)
        if ep.SeriesID = seriesId then
            if firstMatch = invalid then firstMatch = ep
            if ep.Watched = 0 then
                if ep.Timestamp > 0 and inProgress = invalid then inProgress = ep
                if firstUnwatched = invalid then firstUnwatched = ep
            end if
        end if
    end for
    if inProgress <> invalid then return inProgress
    if firstUnwatched <> invalid then return firstUnwatched
    return firstMatch
end function

function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "back"
            if m.videoNode <> invalid and m.videoNode.hasFocus() then
                StopVideo(m.videoNode.position)
                result = true
            end if
        end if
    end if
    return result
end function
