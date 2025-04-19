const express = require('express');
const app = express();
const port = 3000;
const mariadb = require('mariadb');
const pool = mariadb.createPool(
    {
        host: 'db',
        user: 'node',
        password: 'node',
        database: 'media',
        connectionLimit: 5
    }
);
const path = require('path');
const mediapath = path.join(__dirname,'media');

async function runQuery(qry, args) {
    let conn;
    try {
        conn = await pool.getConnection();
        const res = await conn.query(qry, args);
        return res;
    } catch (err) {
        console.log(err);
    } finally {
        if (conn) conn.release();
    }
}

app.get('/media', async function (req, res) {
    let args = [];
    const data = await runQuery('SELECT * FROM content_view;', args);
    data.forEach(item => {
        if (['movie','episode'].includes(item.ContentType)) {
            item.SubtitleTracks = [{"language": "eng", "description": "English", "trackname": item.SubtitleUrl}];
        }
        delete item.SubtitleUrl;
    });
    res.json(data);
});

app.get('/gettimestamp/:id', async function (req, res) {
    let args = [];
    args.push(req.params.id);
    const data = await runQuery('SELECT timestamp FROM content WHERE id = ?;', args);
    res.json(data[0].timestamp);
});

app.get('/settimestamp/:id/timestamp/:ts', async function (req, res) {
    let args = [];
    args.push(req.params.ts);
    args.push(req.params.id);
    const data = await runQuery('UPDATE content SET timestamp = ? WHERE id = ?;', args);
    res.send('OK');
});

app.get('/Movies/:movie', (req, res) => {
    res.sendFile(path.join(mediapath,'Movies',req.params.movie));
});

app.get('/Shows/:show/:season/:episode', (req, res) => {
    res.sendFile(path.join(mediapath,'Shows',req.params.show,'/',req.params.season,'/',req.params.episode));
});

app.get('/Subtitles/:subtitle', (req, res) => {
    res.sendFile(path.join(mediapath,'Subtitles',req.params.subtitle));
});

app.get('/Subtitles/:show/:episode', (req, res) => {
    res.sendFile(path.join(mediapath,'Subtitles',req.params.show,req.params.episode));
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
});
