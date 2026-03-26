from flask import Flask, request, send_file
from pathlib import Path, PurePath
def create_app():
    app = Flask(__name__, instance_relative_config=True)
    Path(app.instance_path).mkdir(mode=0o755, parents=True, exist_ok=True)
    app.config.from_mapping(
        MEDIAPATH=PurePath("d:/Media/Videos/"),
        DATABASE=Path(app.instance_path).joinpath("media.db"),
    )
    from . import db
    db.init_app(app)

    @app.route("/content", methods=["GET"])
    def content():
        try:
            sql = """SELECT *
                       FROM content_view
                   ORDER BY ContentType ASC
                          , EpisodeNumber ASC
                          , Title ASC"""
            args = ()
            data = db.sql_call(sql, args)
            if db.validate_data(data):
                for d in data:
                    d = db.format_subtitle(d)
                return data
            else:
                print("Data could not be validated")
                return "", 500
        except Exception as e:
            print("Could not get content")
            print(e)
            return "", 500
        
    @app.route("/server", methods=["POST"])
    def server():
        try:
            server = request.get_data(as_text=True)
            sql = """UPDATE server
                        SET server = ?
                      WHERE id = '1'"""
            args = (server,)
            db.sql_call(sql, args)
            return "", 200
        except Exception as e:
            print("Could not set server")
            print(e)
            return "", 500
        
    @app.route("/play", methods=["GET"])
    def play():
        try:
            id = request.args["id"]
            roku_contenttype_id = db.get_roku_contenttype_id(id)
            if roku_contenttype_id != -1:
                match roku_contenttype_id:
                    case 1:
                        mod = "CONCAT('Movies/', c.filename, '.', ft.filetype)"
                    case 4:
                        mod = "CONCAT('Shows/', c.filenametitleshow, '/', c.filenametitleseason, '/', c.filename, '.', ft.filetype)"
                    case _:
                        return "", 500
                sql = f"""SELECT {mod} AS filepath
                            FROM content c
                            JOIN filetype ft
                              ON c.filetype_id = ft.id
                           WHERE uuid = ?"""
                args = (id,)
                data = db.sql_call(sql, args)
                if db.validate_data(data):
                    file = app.config["MEDIAPATH"] / data[0]["filepath"]
                    return send_file(file, as_attachment=True)
                else:
                    print("Data could not be validated")
                    return "", 500
            else:
                print("db.get_roku_contenttype_id returned an error")
                return "", 500
        except Exception as e:
            print("Could not get media")
            print(e)
            return "", 500
        
    @app.route("/subtitle", methods=["GET"])
    def subtitle():
        try:
            id = request.args["id"]
            roku_contenttype_id = db.get_roku_contenttype_id(id)
            if roku_contenttype_id != -1:
                match roku_contenttype_id:
                    case 1:
                        mod = "CONCAT('Subtitles/', c.filename, '.srt')"
                    case 4:
                        mod = "CONCAT('Subtitles/', c.filenametitleshow, '/', c.filename, '.srt')"
                    case _:
                        return "", 500
                sql = f"""SELECT {mod} AS filepath
                            FROM content c
                           WHERE uuid = ?"""
                args = (id,)
                data = db.sql_call(sql, args)
                if db.validate_data(data):
                    file = app.config["MEDIAPATH"] / data[0]["filepath"]
                    return send_file(file, as_attachment=True)
                else:
                    print("Data could not be validated")
                    return "", 500
            else:
                print("db.get_roku_contenttype_id returned an error")
                return "", 500
        except Exception as e:
            print("Could not get subtitle")
            print(e)
            return "", 500
        
    @app.route("/timestamp", methods=["GET", "POST"])
    def timestamp():
        match request.method:
            case "GET":
                try:
                    id = request.args["id"]
                    sql = """SELECT timestamp
                               FROM content
                              WHERE uuid = ?
                           ORDER BY title ASC"""
                    args = (id,)
                    data = db.sql_call(sql, args)
                    if db.validate_data(data):
                        return data
                    else:
                        print("Data could not be validated")
                        return "", 500
                except Exception as e:
                    print("Could not get timestamp")
                    print(e)
                    return "", 500
            case "POST":
                try:
                    data = request.get_json()
                    id = data["id"]
                    ts = data["ts"]
                    sql = """UPDATE content
                                SET timestamp = ?
                              WHERE uuid = ?"""
                    args = (ts, id)
                    db.sql_call(sql, args)
                    return "", 200
                except Exception as e:
                    print("Could not set timestamp")
                    print(e)
                    return "", 500
            case _:
                return "", 500
    return app
