# NASplay
### *Description*
NASplay is a minimalist [Roku](https://www.roku.com/) app similar to [Plex](https://www.plex.tv/) or [Jellyfin](https://jellyfin.org/) that allows you to play content from your local media server. This repository hosts both the Roku app as well as a containerized backend framework for delivering your content. For testing and development on Roku see [how to activate developer mode](https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md) and the [Visual Studio Brightscript Extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) for debugging.
## Roku app
### *Configuration*
On the main menu, you can set your media server's IP address and port (default 8088). For example: ```http://192.168.1.2:8088```
### *Content*
Content must be provided by the user and added to the backend database. A few useful tools one might use are [HandBrake](https://handbrake.fr/) and [MakeMKV](https://www.makemkv.com/). To aid with metadata [The Movie Database API](https://developer.themoviedb.org/docs/getting-started) is extremely helpful.
## Backend Framework
### *Overview*
The backend content delivery suite is a [Docker](https://www.docker.com/) container consisting of a [MariaDB](https://mariadb.org/) database with [Adminer](https://www.adminer.org/) as a frontend and a [Node.js](https://nodejs.org/) server using the [Express](https://expressjs.com/) web app framework. Alternatively, each application can be installed and configured manually if containerization is undesirable.

Aside from the backend server, the actual media will need to be hosted as well. This is assumed to be on the same machine running the server and accessible to the Docker container. The default media location on the server is two directories up from the root of the docker container in a ```Media``` folder and mounted into a ```media``` folder in the working directory of the container.
### *Media Server*
Your media server needs to have media in the directory structure as follows in order for the backend server to deliver it and for Roku app to find it. Below ```filename``` needs to match the ```filename``` column in the ```content``` table of the database. The same goes for ```filenametitleshow``` and ```filenametitleseason```.
```
/Media
|—Movies
|    |—filename.mp4
|—Shows
|    |—filenametitleshow
|    |    |—filenametitleseason
|    |    |    |—filename.mp4
|    |    |—filenametitleseason
|    |    |    |—filename.mp4
|—Subtitles
|    |—filename.srt
|    |—filenametitleshow
|    |    |—filename.srt
```
### *MariaDB*
The database is created from ```media.sql``` when the container is started. It has the required structure, but is lacking configuration and content.
#### *Configuration*
The ```server``` table will need to have a record added that matches the same IP address and port used in the Roku app. This will be used along with the ```url``` table to generate URLs for the Roku to fetch the actual media.

The default ```user``` and ```password``` for the database are both 'node'. The root password for the database is randomly generated. These values are set in the ```compose.yaml``` and if modified must also be updated in ```index.js```.
#### *Content*
The ```content``` table contains all of the media content that will be compiled by the ```content_view``` and delivered to the Roku. This is where users will add their media's properties.

For ***Movies*** all of the media properties should be added in a single record. For ***Shows*** (also called *Series* throughout the code) you will need one record for the ***Series*** itself, one for each ***Season***, and one for each ***Episode***. The ```series_id``` and ```season_id``` columns are used by the Roku app to parse and organize content upon receiving the content feed.

The ```tmdb_id``` column will be essential for using The Movie Database's APIs and scripting if that source is used to populate artwork, titles, descriptions and soforth.

*** **Artwork** ***

The ```hdposterurl``` column is used for paths to poster (portrait) artwork that will be used to identify the ```Movies``` and ```Shows``` and must link to an image file with a 2:3 ratio. It will be rendered on the Roku app as ```154x231 px```. The ```fhdposter``` column is used for backdrop (landscape) artwork with a ratio of 16:9 and is rendered as ```300x168 px``` for the movie details screen and ```185x104``` for the episode thumbnails. ***This Roku metadata tag is being repurposed simply so it can be pulled in easily with the ```setFields()``` method.*** As it is highly recommended to use The Movie Database's content in building your database, their logo has been included in the corner of the Roku app by default.

The ```secondarytitle``` column is used for the year the movie was released as suggested by Roku's content metadata documentation.

The ```content_view``` generates the content feed for the Roku app. It is manipulated slightly by the Node.js server to replace the ```SubtitleUrl``` field with the ```SubtitleTracks``` object. More about Roku's content metadata [here](https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md)
#### Backup and Restore
According to the [documentation](https://hub.docker.com/_/mariadb) you can backup your database to the host machine by mounting to the ```/backup``` folder within the container. Similarly, to reset back to the initial database structure when starting up the container you can mount to the ```/docker-entrypoint-initdb.d```. You could also use this entrypoint to restore a backup if you wish to keep your data.
### Adminer
This is a useful frontend for database management. It is included by the ```compose.yaml``` file by default but not required if another tool is preferred.
### Node.js
The ```index.js``` file contains the Node.js server that runs queries on the database and serves the results to the Roku app.
