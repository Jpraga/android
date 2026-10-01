#!/bin/bash

# Configurações
PASTA_FOTOS="$HOME/fotos"
LIMITE_DISCO=80
INTERVALO_SEGUNDOS=5 # Intervalo entre fotos (ajusta conforme necessário)
LARGURA_FOTO=1280    # Reduz a resolução para manter o tamanho do ficheiro reduzido
QUALIDADE_FOTO=75    # Qualidade JPEG (75% gera ficheiros à volta de 150KB-300KB)

# Cria a pasta de fotos se não existir
mkdir -p "$PASTA_FOTOS"

echo "=== A iniciar captura contínua em loop ==="
echo "Guarda em: $PASTA_FOTOS"
echo "Limite de armazenamento: ${LIMITE_DISCO}%"
echo "Pressiona [CTRL+C] para parar."

while true; do
    # 1. Verifica a percentagem de espaço ocupado no armazenamento do Termux/dispositivo
    USO_DISCO=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')

    # 2. Se o uso do disco for igual ou superior ao limite, apaga a foto mais antiga
    while [ "$USO_DISCO" -ge "$LIMITE_DISCO" ]; do
        FOTO_ANTIGA=$(ls -1t "$PASTA_FOTOS"/*.jpg 2>/dev/null | tail -n 1)
        
        if [ -n "$FOTO_ANTIGA" ]; then
            echo "[ALERTA] Espaço em disco em ${USO_DISCO}%. A apagar mais antiga: $(basename "$FOTO_ANTIGA")"
            rm "$FOTO_ANTIGA"
            # Reavalia o espaço em disco após eliminar
            USO_DISCO=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
        else
            echo "[AVISO] Limite de disco atingido, mas não há fotos para apagar em $PASTA_FOTOS."
            break
        fi
    done

    # 3. Nome da foto com Timestamp
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FOTO_TEMP="$PASTA_FOTOS/temp_${TIMESTAMP}.jpg"
    FOTO_FINAL="$PASTA_FOTOS/${TIMESTAMP}.jpg"

    # 4. Tira a foto usando a câmara traseira (id 0)
    termux-camera-photo -c 0 "$FOTO_TEMP"

   # 5. Redimensiona e comprime usando o comando "magick"
    if [ -f "$FOTO_TEMP" ]; then
        magick "$FOTO_TEMP" -resize "${LARGURA_FOTO}x" -quality "$QUALIDADE_FOTO" "$FOTO_FINAL"
        rm "$FOTO_TEMP"
        
        # Indexa a nova foto na Galeria do Android
        termux-media-scan "$FOTO_FINAL"
        
        TAMANHO=$(du -h "$FOTO_FINAL" | cut -f1)
        echo "[OK] Foto guardada e indexada: ${TIMESTAMP}.jpg ($TAMANHO) | Disco: ${USO_DISCO}%"
    else
        echo "[ERRO] Falha ao capturar foto pela câmara."
    fi
done
