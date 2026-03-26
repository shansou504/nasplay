DROP TABLE IF EXISTS server;
DROP TABLE IF EXISTS rating;
DROP TABLE IF EXISTS filetype;
DROP TABLE IF EXISTS filetype;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS contenttype;
DROP TABLE IF EXISTS content;
CREATE TABLE server (id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, server TEXT NOT NULL UNIQUE);
CREATE TABLE rating (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, rating TEXT NOT NULL UNIQUE);
CREATE TABLE filetype (id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, filetype TEXT NOT NULL UNIQUE);
CREATE TABLE category (id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, category TEXT NOT NULL UNIQUE);
CREATE TABLE contenttype (
        "id"    INTEGER NOT NULL UNIQUE,
        "contenttype"   TEXT NOT NULL UNIQUE,
        "roku_id"       INTEGER NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE content (
        "id"    INTEGER NOT NULL UNIQUE,
        "uuid"  TEXT NOT NULL UNIQUE,
        "tmdb_id"       INTEGER,
        "roku_contenttype_id"   INTEGER NOT NULL,
        "title" TEXT NOT NULL,
        "series_id"     TEXT,
        "season_id"     TEXT,
        "titleseason"   TEXT,
        "secondarytitle"        TEXT,
        "description"   TEXT,
        "hdposterurl"   TEXT,
        "fhdposterurl"  TEXT,
        "releasedate"   TEXT,
        "rating_id"     INTEGER,
        "episodenumber" INTEGER,
        "numepisodes"   INTEGER,
        "category_id"   INTEGER,
        "filename"      TEXT,
        "filetype_id"   INTEGER,
        "filenametitleshow"     TEXT,
        "filenametitleseason"   TEXT,
        "server_id"     INTEGER,
        "timestamp"     REAL,
        "watched"       INTEGER,
        FOREIGN KEY("roku_contenttype_id") REFERENCES "contenttype"("roku_id"),
        PRIMARY KEY("id" AUTOINCREMENT)
);
DROP VIEW IF EXISTS content_view;
CREATE VIEW content_view AS 
     SELECT c.uuid ID
          , ct.contenttype ContentType
          , c.title Title
          , c.titleseason TitleSeason
          , c.season_id SeasonID
          , c.series_id SeriesID
          , c.secondarytitle SecondaryTitle
          , c.description Description
          , c.hdposterurl HDPosterUrl
          , c.fhdposterurl FHDPosterUrl
          , c.releasedate ReleaseDate
          , r.rating Rating
          , c.episodenumber EpisodeNumber
          , concat(s.server, '/play?id=', c.uuid) Url
          , concat(s.server, '/subtitle?id=', c.uuid) SubtitleUrl
          , c.timestamp Timestamp
          , c.watched Watched
       FROM content c
            LEFT JOIN contenttype ct
                   ON c.roku_contenttype_id = ct.roku_id
            LEFT JOIN rating r
                   ON c.rating_id = r.id
            LEFT JOIN server s
                   ON c.server_id = s.id;