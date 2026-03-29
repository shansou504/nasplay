sub init()
    m.top.id = "MainScene"
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    m.content_feed_certification = "https://shansou504.github.io/nasplay_content_feed_certification/content_feed_certification.json"
    m.server = GetServer()
    m.setServerTask = CreateObject("roSGNode", "SetServerTask")
    m.setTimestampTask = CreateObject("roSGNode", "SetTimestampTask")
    m.mainContentTask = CreateObject("roSGNode", "MainContentTask")
    m.mainContentTask.observeField("content", "OnMainContentTaskContent")
    if m.server = m.content_feed_certification
        m.mainContentTask.contenturi = m.server
    else
        m.mainContentTask.contenturi = m.server + "/content"
    end if
    m.mainContentTask.control = "RUN"
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
    m.menuListPanel = m.top.panelSet.createChild("MenuListPanel")
    m.menuListPanel.observeField("createNextPanelIndex", "UpdateSecondPanel")
    ' SeriesGridPanel is defined here so it shows up the first time the app is opened.
    ' It is removed and recreated each time the main menu highlights "Shows"
    m.seriesGridPanel = CreateObject("roSGNode", "SeriesGridPanel")
    if m.series <> invalid then
        m.seriesGridPanel.grid.content = m.series
    end if
    m.seriesGridPanel.observeField("createNextPanelIndex", "CreateSeasonListPanel")
    m.top.panelSet.appendChild(m.seriesGridPanel)
    m.menuListPanel.setFocus(true)
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
                    FHDPosterUrl: item.FHDPosterUrl,
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
                ' ID (uuid) maps to the built-in node id field
                childNode.id = item.ID
                ' Custom fields not in standard ContentNode schema
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
        m.seriesGridPanel = CreateObject("roSGNode", "SeriesGridPanel")
        if m.series <> invalid then
            m.seriesGridPanel.grid.content = m.series
        end if
        m.seriesGridPanel.observeField("createNextPanelIndex", "CreateSeasonListPanel")
        m.menuListPanel.nextPanel = m.seriesGridPanel
    else if title = "Movies" then
        m.movieGridPanel = CreateObject("roSGNode", "MovieGridPanel")
        if m.movies <> invalid then
            m.movieGridPanel.grid.content = m.movies
        end if
        m.movieGridPanel.grid.observeField("itemFocused", "CreateMovieVideo")
        m.movieGridPanel.grid.observeField("itemSelected", "PlayVideo")
        m.menuListPanel.nextPanel = m.movieGridPanel
    else if title = "Server" then
        m.keyboardDialogPanel = CreateObject("roSGNode", "KeyboardDialogPanel")
        m.keyboardDialog = CreateObject("roSGNode", "StandardKeyboardDialog")
        m.keyboardDialogPanel.appendChild(m.keyboardDialog)
        m.keyboardDialog.ObserveField("buttonSelected","SetServer")
        m.keyboardDialog.title = "Server"
        m.keyboardDialog.buttons = ["Save"]
        ' I don't know why this line is here. I'll probably delete it
        m.top.dialog = m.keyboardDialog
        m.menuListPanel.nextPanel = m.keyboardDialogPanel
    else
        ' Prevent crash
        m.menuListPanel.nextPanel = invalid
    end if
end sub

sub CreateMovieVideo()
    m.videoNode = CreateObject("roSGNode", "Video")
    content = m.movieGridPanel.grid.content.getChild(m.movieGridPanel.grid.itemFocused)
    m.videoNode.content = content.clone(true)
    m.videoNode.control = "prebuffer"
end sub

sub CreateSeasonListPanel()
    m.filteredSeasons = CreateObject("roSGNode", "ContentNode")
    currentSeriesGridChild = m.seriesGridPanel.grid.content.getChild(m.seriesGridPanel.createNextPanelIndex)
    seasons = m.seasons.getChildren(-1, 0)
    for each season in seasons
        if season.SeriesID = currentSeriesGridChild.id then
            m.filteredSeasons.appendChild(season.clone(true))
        end if
    end for
    m.seasonListPanel = CreateObject("roSGNode", "SeasonListPanel")
    m.seasonListPanel.list.content = m.filteredSeasons
    m.seasonListPanel.observeField("createNextPanelIndex", "CreateEpisodeListPanel")
    m.seriesGridPanel.nextPanel = m.seasonListPanel
end sub

sub CreateEpisodeListPanel()
    m.filteredEpisodes = CreateObject("roSGNode", "ContentNode")
    currentSeasonListChild = m.seasonListPanel.list.content.getChild(m.seasonListPanel.createNextPanelIndex)
    episodes = m.episodes.getChildren(-1, 0)
    for each episode in episodes
        if episode.SeasonID = currentSeasonListChild.id then
            m.filteredEpisodes.appendChild(episode.clone(true))
        end if
    end for
    m.episodeListPanel = CreateObject("roSGNode", "EpisodeListPanel")
    m.episodeListPanel.list.content = m.filteredEpisodes
    m.episodeListPanel.list.observeField("itemFocused", "CreateEpisodeVideo")
    m.episodeListPanel.list.observeField("itemSelected", "PlayVideo")
    m.seasonListPanel.nextPanel = m.episodeListPanel
end sub

sub CreateEpisodeVideo()
    m.videoNode = CreateObject("roSGNode", "Video")
    content = m.episodeListPanel.list.content.getChild(m.episodeListPanel.list.itemFocused)
    m.videoNode.content = content.clone(true)
    m.videoNode.control = "prebuffer"
end sub

sub PlayVideo()
    m.top.appendChild(m.videoNode)
    m.videoNode.setFocus(true)
    m.videoNode.control = "play"
    timestamp = m.videoNode.content.Timestamp
    if timestamp <> invalid and timestamp > 0
        m.videoNode.seek = timestamp
    end if
    m.playbackTimer = CreateObject("roSGNode", "Timer")
    m.playbackTimer.duration = 30
    m.playbackTimer.repeat = true
    m.playbackTimer.observeField("fire", "SetTimestamp")
    m.playbackTimer.control = "start"
end sub

sub SetTimestamp()
    if m.videoNode = invalid then return
    assocArray = {
        id: m.videoNode.content.id,
        timestamp: m.videoNode.position
    }
    m.setTimestampTask.contenturi = m.server + "/timestamp"
    m.setTimestampTask.content = FormatJson(assocArray)
    m.setTimestampTask.control = "RUN"
end sub

function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "back"
            if m.videoNode <> invalid and m.videoNode.hasFocus() then
                SetTimestamp()
                m.playbackTimer.control = "stop"
                m.playbackTimer = invalid
                m.videoNode.control = "stop"
                m.top.removeChild(m.videoNode)
                m.videoNode = invalid
                if m.top.panelSet.getChild(m.top.panelSet.getChildCount() - 1).id = "MovieGridPanel" then
                    m.movieGridPanel.setFocus(true)
                else
                    m.episodeListPanel.setFocus(true)
                end if
                result = true
            end if
        end if
    end if
    return result
end function
