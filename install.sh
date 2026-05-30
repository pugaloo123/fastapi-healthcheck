#!/bin/bash

set -e

echo "Установка FastAPI Counter"

#Проверка что запущен от root
if [ "$EUID" -ne 0 ]; then
    echo "Запустить от root: sudo ./install.sh"
    exit 1
fi

echo "Устанавливаем зависимости"
cp -r . /opt/fastapi-counter
cd /opt/fastapi-counter

echo "Создаем виртуальное окружение"
python3 -m venv venv
venv/bin/pip install -r requirements.txt

echo "Копируем check_app.sh"
cp scripts/check_app.sh /usr/local/bin/check_app.sh
chmod +x /usr/local/bin/check_app.sh

echo "Копируем systemd unit-файлы"
cp systemd/fastapi-counter.service /etc/systemd/system/
cp systemd/check-app.service /etc/systemd/system/

echo "Активируем сервисы"
systemctl daemon-reload
systemctl enable --now fastapi-counter
systemctl enable --now check-app.timer

echo "Настраиваем logrotate"
cp logrotate/check_app /etc/logrotate.d/check_app

echo ""
echo "Готово!"
echo "Статус приложения:  systemctl status fastapi-counter"
echo "Статус таймера:     systemctl status check-app.timer"
echo "Лог приложения:     tail -f /opt/fastapi-counter/app.log"
echo "Лог мониторинга:    tail -f /var/log/check_app.log"