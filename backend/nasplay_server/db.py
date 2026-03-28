import sqlite3
import click
from flask import current_app, g
def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(
            current_app.config["DATABASE"],
            autocommit=True
        )
        g.db.row_factory = sqlite3.Row
    return g.db
def validate_data(data):
    return len(data) > 0
def sql_call(sql, args):
    db = get_db()
    cur = db.cursor()
    cur.execute(sql, args)
    row_list = cur.fetchall()
    rows = []
    try:
        columns = row_list[0].keys()
        for row_i in range(len(row_list)):
            row_dict = {}
            for col_i in range(len(columns)):
                row_dict[columns[col_i]] = row_list[row_i][columns[col_i]]
            rows.append(row_dict)
    except:
        pass
    return rows
def format_subtitle(data):
    try:        
        if validate_data(data):
            subtitle_url = data["SubtitleUrl"]
            data["SubtitleTracks"] = [{"language": "eng",
                "description": "English", "trackname": subtitle_url}]
            del data["SubtitleUrl"]
            return data
        else:
            print("Data could not be validated")
            return ""
    except Exception as e:
        print("Could not get metadata")
        print(e)
        return ""
def get_roku_contenttype_id(id):
    try:
        sql = """SELECT roku_contenttype_id
                    FROM content
                    WHERE uuid = ?
                    LIMIT 1"""
        args = (id,)
        data = sql_call(sql, args)
        if validate_data(data):
            return data[0]["roku_contenttype_id"]
        else:
            print("Data could not be validated")
            return -1
    except Exception as e:
        print("Could not get ContentType")
        print(e)
        return -1
def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()
def init_db():
    db = get_db()
    print(current_app.root_path)
    with current_app.open_resource("schema.sql") as f:
        db.executescript(f.read().decode("utf8"))
@click.command("init-db")
def init_db_command():
    click.echo("Clearing the existing data and creati new tables.")
    init_db()
    click.echo("Initialized the database.")
def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
