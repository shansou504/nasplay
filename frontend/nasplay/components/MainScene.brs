sub init()
    m.top.id = "MainScene"
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
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
    m.playbackTimer = CreateObject("roSGNode", "Timer")
    m.playbackTimer.duration = 30
    m.playbackTimer.repeat = true
    m.playbackTimer.observeField("fire", "SetTimestampOnServer")
    m.videoNode = CreateObject("roSGNode", "Video")
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
                if item.NumEpisodes <> invalid
                    childNode.setField("NumEpisodes", item.NumEpisodes.toStr())
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
        m.menuListPanel.nextPanel = m.seriesGridPanel
    else if title = "Movies" then
        m.menuListPanel.nextPanel = m.movieGridPanel
    else if title = "Server" then
        m.keyboardDialog.message = ["Current server is " + m.server]
        m.top.dialog = m.keyboardDialog
        m.menuListPanel.nextPanel = invalid
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
    m.seasonListPanel.leftLabel.text = currentSeriesGridChild.Title
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

sub SetTimestampOnServer()
    if m.videoNode = invalid then return
    assocArray = {
        id: m.videoNode.content.id,
        ts: m.videoNode.position
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
                SetTimestampOnServer()
                timestamp = m.videoNode.position
                ' Set timestamp on video node
                m.videoNode.content.setField("Timestamp", timestamp)
                id = m.videoNode.content.id
                m.playbackTimer.control = "stop"
                m.videoNode.control = "stop"
                m.top.removeChild(m.videoNode)
                lastPanel = m.top.panelSet.getChild(m.top.panelSet.getChildCount() - 1)
                lastIndex = invalid
                if lastPanel <> invalid then
                    if lastPanel.id = "MovieDetailsPanel" then
                        ' Set timestamp on m.movieGridPanel.grid.content node
                        for index = 0 to m.movieGridPanel.grid.content.getChildCount() - 1
                            movieNode = m.movieGridPanel.grid.content.getChild(index)
                            if movieNode.id = id then
                                lastIndex = index
                                movieNode.setField("Timestamp", timestamp)
                                exit for
                            end if
                        end for
                        ' Set timestamp on m.movies source object
                        movieJson = m.movies.getChild(lastIndex)
                        movieJson.setField("Timestamp", timestamp)
                        ' Reset focus back to playButton
                        m.movieDetailsPanelPlayButton.setFocus(true)
                    else if lastPanel.id = "EpisodeListPanel" then
                        m.episodeListPanel.setFocus(true)
                    else
                        result = false
                    end if
                end if
                result = true
            end if
        end if
    end if
    return result
end function
