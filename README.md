# FastAPI Counter

Простое FastAPI приложение — счётчик запросов с SQLite + автоматический мониторинг через systemd.

## Что делает

- `GET /` — считает запросы и сохраняет в SQLite
- `GET /health` — проверяет что приложение и база живы
- `check_app.sh` — каждую минуту проверяет `/health`, при падении перезапускает

## Требования

- Ubuntu / Debian
- Python 3.10+
- systemd
- curl

## Установка

```bash
git clone https://github.com/ТВО_ЮЗЕРНЕЙМ/fastapi-counter.git
cd fastapi-counter
chmod +x install.sh
sudo ./install.sh
```

## Запуск

После установки сервис запускается автоматически. Если нужно управлять вручную:

```bash
sudo systemctl stop fastapi-counter

sudo systemctl start fastapi-counter

sudo systemctl stop check-app.timer

sudo systemctl start check-app.timer
```

## Проверка

```bash

systemctl status fastapi-counter


systemctl status check-app.timer


tail -f /opt/fastapi-counter/app.log

tail -f /var/log/check_app.log

sudo logrotate -d /etc/logrotate.d/check_app
```

## Тест аварии

Останавливаем приложение вручную и ждём минуту:

```bash
sudo systemctl stop fastapi-counter
tail -f /var/log/check_app.log
```

Скрипт обнаружит падение и автоматически поднимет сервис.

## Структура проекта

```
fastapi-counter/
├── app/
│   └── main.py                  # FastAPI приложение
├── logrotate/
│   └── check_app                # конфиг ротации логов          
├── scripts/
│   └── check_app.sh             # скрипт мониторинга
├── systemd/
│   ├── fastapi-counter.service  # запуск приложения
│   ├── check-app.service        # запуск скрипта проверки
│   └── check-app.timer          # расписание проверки
├── requirements.txt             # зависимости Python
├── install.sh                   # установка одной командой
└── README.md
```