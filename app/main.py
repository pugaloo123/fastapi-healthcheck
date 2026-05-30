import sqlite3

from fastapi import FastAPI
import uvicorn 
from datetime import date, datetime
import os

app = FastAPI()

DB_PATH = 'counter.db'
LOG_PATH = 'app.log'

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS requests (
                   id INTEGER PRIMARY KEY AUTOINCREMENT,
                   timestamp TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def log(message: str):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_PATH, 'a') as f:
        f.write(f'[{timestamp}] {message}\n')

@app.on_event("startup")
def startup():
    init_db()
    log("Приложение запущено.")

@app.get('/')
def root():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO requests (timestamp) VALUES (?)",
                   (datetime.now().isoformat(),))
    conn.commit()
    cursor.execute("SELECT COUNT(*) FROM requests")
    count = cursor.fetchone()[0]
    conn.close()
    log(f'Запрос получен. Всего запросов: {count}')
    return {"total_requests": count}

@app.get('/health')
def health():
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) FROM requests')
        count = cursor.fetchone()[0]
        conn.close()
        return {"status": "ok", 'total_requests': count}
    except Exception as e:
        log(f"CRIT: healthcheck упал - {e}")
        return {'status': "error", "detail": str(e)}
    

