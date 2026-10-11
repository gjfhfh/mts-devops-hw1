#!/usr/bin/env bash
# monitor.sh: статус сервиса и число ошибок в syslog за последний час.
# Использование: ./monitor.sh <service>
# Коды выхода: 0 сервис активен, 1 не активен, 2 неверные аргументы,
#              3 сервис не найден или нет systemctl.

set -u
SYSLOG=${SYSLOG:-/var/log/syslog}

if [ $# -ne 1 ]; then
  echo "Использование: $0 <service>" >&2
  exit 2
fi
SERVICE=${1%.service}

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl не найден: скрипт рассчитан на Linux с systemd" >&2
  exit 3
fi

if ! systemctl list-unit-files "${SERVICE}.service" --no-legend 2>/dev/null | grep -q .; then
  echo "Сервис '$SERVICE' не найден" >&2
  exit 3
fi

STATUS=$(systemctl is-active "$SERVICE")
RC=0
echo "Сервис: $SERVICE | статус: $STATUS"

if [ "$STATUS" != "active" ]; then
  RC=1
  echo "--- Последние 10 строк журнала ---"
  journalctl -u "$SERVICE" -n 10 --no-pager
fi

echo "--- Ошибки в $SYSLOG за последний час ---"
if [ ! -r "$SYSLOG" ]; then
  echo "Файл $SYSLOG не найден или нет прав (попробуйте sudo)" >&2
  exit "$RC"
fi
if [ ! -s "$SYSLOG" ]; then
  echo "Лог пуст, ошибок: 0"
  exit "$RC"
fi
if ! head -n 1 "$SYSLOG" | grep -qE '^[0-9]{4}-[0-9]{2}-'; then
  echo "Неизвестный формат времени в $SYSLOG (ожидается ISO 8601)" >&2
  exit "$RC"
fi

SINCE=$(date -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')
COUNT=$(grep -iE 'error|fail|critical' "$SYSLOG" | awk -v since="$SINCE" '$1 >= since {n++} END {print n+0}')
echo "Ошибок за последний час: $COUNT"
exit "$RC"
