#!/bin/bash

LOG="/var/log/check_app.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
APP_URL="http://localhost:8000/health"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 $APP_URL)

if [ "$HTTP_CODE" != "200" ]; then
    echo "[$TIMESTAMP] WARN: Приложение не отвечает (код: $HTTP_CODE). Перезапуск..." >> "$LOG"
    systemctl restart fastapi-counter
    sleep 3

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 $APP_URL)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "[$TIMESTAMP] OK: Приложение восстановлено." >> "$LOG"
    else
        echo "[$TIMESTAMP] CRIT: Приложение не поднялось после перезапуска!" >> "$LOG"
    fi 
else
    echo "[$TIMESTAMP] OK: Приложение работает (код: $HTTP_CODE)." >> "$LOG"
fi
