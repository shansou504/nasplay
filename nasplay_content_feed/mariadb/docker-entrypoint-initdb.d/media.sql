/*!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.2-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: media
-- ------------------------------------------------------
-- Server version	11.4.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Current Database: `media`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `media` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;

USE `media`;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES
(1,'Action'),
(2,'Comedy'),
(3,'Family'),
(4,'Sci-Fi'),
(5,'Drama'),
(6,'007');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content`
--

DROP TABLE IF EXISTS `content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tmdb_id` int(11) DEFAULT NULL,
  `contenttype_id` int(11) NOT NULL,
  `title` varchar(250) NOT NULL,
  `series_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `titleseason` varchar(250) DEFAULT NULL,
  `secondarytitle` varchar(250) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `hdposterurl` varchar(250) DEFAULT NULL,
  `fhdposterurl` varchar(250) DEFAULT NULL,
  `releasedate` varchar(10) DEFAULT NULL,
  `rating_id` int(11) DEFAULT NULL,
  `episodenumber` int(11) DEFAULT NULL,
  `numepisodes` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `url_id` int(11) DEFAULT NULL,
  `filename` varchar(250) DEFAULT NULL,
  `streamformat_id` int(11) DEFAULT NULL,
  `filetype_id` int(11) DEFAULT NULL,
  `filenametitleshow` varchar(250) DEFAULT NULL,
  `filenametitleseason` varchar(250) DEFAULT NULL,
  `subtitleurl_id` int(11) DEFAULT NULL,
  `server_id` int(11) DEFAULT NULL,
  `timestamp` float DEFAULT NULL,
  `watched` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content`
--

LOCK TABLES `content` WRITE;
/*!40000 ALTER TABLE `content` DISABLE KEYS */;
/*!40000 ALTER TABLE `content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `content_view`
--

DROP TABLE IF EXISTS `content_view`;
/*!50001 DROP VIEW IF EXISTS `content_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `content_view` AS SELECT
 1 AS `ID`,
  1 AS `Title`,
  1 AS `TitleSeason`,
  1 AS `SeriesID`,
  1 AS `SeasonID`,
  1 AS `SecondaryTitle`,
  1 AS `Description`,
  1 AS `ReleaseData`,
  1 AS `EpisodeNumber`,
  1 AS `NumEpisodes`,
  1 AS `ContentType`,
  1 AS `HDPosterUrl`,
  1 AS `FHDPosterUrl`,
  1 AS `Rating`,
  1 AS `Categories`,
  1 AS `Url`,
  1 AS `StreamFormat`,
  1 AS `SubtitleUrl`,
  1 AS `TimeStamp`,
  1 AS `Watched` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `contenttype`
--

DROP TABLE IF EXISTS `contenttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contenttype` (
  `id` int(11) NOT NULL,
  `contenttype` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenttype`
--

LOCK TABLES `contenttype` WRITE;
/*!40000 ALTER TABLE `contenttype` DISABLE KEYS */;
INSERT INTO `contenttype` VALUES
(0,'not set'),
(1,'movie'),
(2,'series'),
(3,'season'),
(4,'episode'),
(5,'audio');
/*!40000 ALTER TABLE `contenttype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filetype`
--

DROP TABLE IF EXISTS `filetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filetype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filetype` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filetype`
--

LOCK TABLES `filetype` WRITE;
/*!40000 ALTER TABLE `filetype` DISABLE KEYS */;
INSERT INTO `filetype` VALUES
(1,'mp4'),
(2,'mkv');
/*!40000 ALTER TABLE `filetype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rating`
--

DROP TABLE IF EXISTS `rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rating` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rating`
--

LOCK TABLES `rating` WRITE;
/*!40000 ALTER TABLE `rating` DISABLE KEYS */;
INSERT INTO `rating` VALUES
(1,'G'),
(2,'PG'),
(3,'PG-13'),
(4,'R'),
(5,'UR'),
(6,'TV-PG'),
(7,'TV-14');
/*!40000 ALTER TABLE `rating` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `server`
--

DROP TABLE IF EXISTS `server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `server` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server` varchar(250) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `server`
--

LOCK TABLES `server` WRITE;
/*!40000 ALTER TABLE `server` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `server` VALUES
(1,'http://localhost:8088');
/*!40000 ALTER TABLE `server` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `subtitleurl`
--

DROP TABLE IF EXISTS `subtitleurl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subtitleurl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subtitleurl` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subtitleurl`
--

LOCK TABLES `subtitleurl` WRITE;
/*!40000 ALTER TABLE `subtitleurl` DISABLE KEYS */;
INSERT INTO `subtitleurl` VALUES
(1,'Subtitles');
/*!40000 ALTER TABLE `subtitleurl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `url`
--

DROP TABLE IF EXISTS `url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `url`
--

LOCK TABLES `url` WRITE;
/*!40000 ALTER TABLE `url` DISABLE KEYS */;
INSERT INTO `url` VALUES
(1,'Movies'),
(2,'Shows');
/*!40000 ALTER TABLE `url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `media`
--

USE `media`;

--
-- Final view structure for view `content_view`
--

/*!50001 DROP VIEW IF EXISTS `content_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`node`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `content_view` AS select `c`.`id` AS `ID`,`c`.`title` AS `Title`,`c`.`titleseason` AS `TitleSeason`,`c`.`series_id` AS `SeriesID`,`c`.`season_id` AS `SeasonID`,`c`.`secondarytitle` AS `SecondaryTitle`,`c`.`description` AS `Description`,`c`.`releasedate` AS `ReleaseData`,`c`.`episodenumber` AS `EpisodeNumber`,`c`.`numepisodes` AS `NumEpisodes`,`ct`.`contenttype` AS `ContentType`,`c`.`hdposterurl` AS `HDPosterUrl`,`c`.`fhdposterurl` AS `FHDPosterUrl`,`r`.`rating` AS `Rating`,`cat`.`category` AS `Categories`,concat(`s`.`server`,'/',`url`.`url`,'/',if(`c`.`contenttype_id` = 4,concat(`c`.`filenametitleshow`,'/',`c`.`filenametitleseason`,'/',`c`.`filename`),`c`.`filename`),'.',`f`.`filetype`) AS `Url`,`f`.`filetype` AS `StreamFormat`,concat(`s`.`server`,'/',`sub`.`subtitleurl`,'/',if(`c`.`contenttype_id` = 4,concat(`c`.`filenametitleshow`,'/'),''),`c`.`filename`,'.srt') AS `SubtitleUrl`,`c`.`timestamp` AS `TimeStamp`,`c`.`watched` AS `Watched` from (((((((`content` `c` left join `contenttype` `ct` on(`c`.`contenttype_id` = `ct`.`id`)) left join `rating` `r` on(`c`.`rating_id` = `r`.`id`)) left join `url` on(`c`.`url_id` = `url`.`id`)) left join `filetype` `f` on(`c`.`streamformat_id` = `f`.`id`)) left join `subtitleurl` `sub` on(`c`.`subtitleurl_id` = `sub`.`id`)) left join `server` `s` on(`c`.`server_id` = `s`.`id`)) left join `category` `cat` on(`c`.`category_id` = `cat`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-05-05 19:45:27
