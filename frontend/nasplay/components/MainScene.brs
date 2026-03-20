sub init()
    m.top.id = "MainScene"
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    ' Need to update to actual server address or use a config file
    m.server = "http://localhost:8000/"
    STOP
    m.mainContentTask = CreateObject("roSGNode", "MainContentTask")
    m.mainContentTask.observeField("content", "OnMainContentTaskContent")
    m.mainContentTask.contenturi = m.server + "content"
    m.mainContentTask.control = "RUN"
end sub

sub OnMainContentTaskContent()
    m.json = ParseJson(m.mainContentTask.content)
    m.series = GetContent("series")
    m.seasons = GetContent("season")
    m.episodes = GetContent("episode")
    m.movies = GetContent("movie")
    m.menuListPanel = m.top.panelSet.createChild("MenuListPanel")
    m.menuListPanel.observeField("createNextPanelIndex", "UpdateSecondPanel")
    ' SeriesGridPanel is defined here so it shows up the first time the app is opened.
    ' It is removed and recreated each time the main menu highlights "Shows"
    m.seriesGridPanel = CreateObject("roSGNode", "SeriesGridPanel")
    m.seriesGridPanel.grid.content = m.series
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
        m.seriesGridPanel.grid.content = m.series
        m.seriesGridPanel.observeField("createNextPanelIndex", "CreateSeasonListPanel")
        m.menuListPanel.nextPanel = m.seriesGridPanel
    else if title = "Movies" then
        m.movieGridPanel = CreateObject("roSGNode", "MovieGridPanel")
        m.movieGridPanel.grid.content = m.movies
        m.menuListPanel.nextPanel = m.movieGridPanel
    else
        ' Remove right panel for now. This will get replaced with "Server" option
        m.menuListPanel.nextPanel = invalid
    end if
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
    m.seasonListPanel.nextPanel = m.episodeListPanel
end sub
