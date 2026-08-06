#!/data/data/com.termux/files/usr/bin/bash

LOG_FILE="$HOME/loging_bateria.log"

# Loop infinito para execução contínua
while true; do
    BATTERY_INFO=$(termux-battery-status)

    PERCENT=$(echo "$BATTERY_INFO" | jq -r '.percentage')
    STATUS=$(echo "$BATTERY_INFO" | jq -r '.status')
    TEMP=$(echo "$BATTERY_INFO" | jq -r '.temperature')

    DATE_STR=$(date "+%Y-%m-%d %H:%M:%S")

    UPTIME_RAW=$(uptime)
    UPTIME_STR=$(echo "$UPTIME_RAW" | sed -n -E 's/.*up +([^,]+),.*/\1/p')
    LOAD_AVG=$(echo "$UPTIME_RAW" | awk -F'load average:' '{print $2}' | xargs)

    echo "[$DATE_STR] Bateria: ${PERCENT}% | Estado: ${STATUS} | Temp: ${TEMP}°C | Uptime: ${UPTIME_STR} | Carga: ${LOAD_AVG}" >> "$LOG_FILE"

    # Aguarda 5 minutos (300 segundos) até à próxima recolha
    sleep 300
done

