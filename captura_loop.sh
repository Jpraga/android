#!/bin/bash

# Configurações
PASTA_FOTOS="/sdcard/Pictures/fotos"
LIMITE_DISCO=39
INTERVALO_SEGUNDOS=5
LARGURA_FOTO=1280
QUALIDADE_FOTO=75

# Cria a pasta de fotos se não existir
mkdir -p "$PASTA_FOTOS"

echo "=== A iniciar captura contínua em loop ==="
echo "Guarda em: $PASTA_FOTOS"
echo "Limite de armazenamento: ${LIMITE_DISCO}%"
echo "Pressiona [CTRL+C] para parar."

while true; do
    # 1. Verifica a percentagem de espaço ocupado
    USO_DISCO=$(df "$PASTA_FOTOS" | awk 'NR==2 {print $(NF-1)}' | sed 's/%//')

    # 2. Se o uso do disco for igual ou superior ao limite, apaga a foto mais antiga
    while [ "$USO_DISCO" -ge "$LIMITE_DISCO" ]; do
        FOTO_ANTIGA=$(ls -1t "$PASTA_FOTOS"/*.jpg 2>/dev/null | tail -n 1)
        
        if [ -n "$FOTO_ANTIGA" ]; then
            echo "[ALERTA] Espaço em disco em ${USO_DISCO}%. A apagar mais antiga: $(basename "$FOTO_ANTIGA")"
            
            # Remove do disco físico
            rm "$FOTO_ANTIGA"
            
            # Notifica a Galeria do Android para remover a foto apagada da visualização
            termux-media-scan "$FOTO_ANTIGA" >/dev/null 2>&1
            
            # Reavalia o espaço em disco
            USO_DISCO=$(df "$PASTA_FOTOS" | awk 'NR==2 {print $(NF-1)}' | sed 's/%//')
        else
            echo "[AVISO] Limite de disco atingido, mas não há fotos para apagar em $PASTA_FOTOS."
            break
        fi
    done

    # 3. Nome da foto com Timestamp
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FOTO_TEMP="$PASTA_FOTOS/temp_${TIMESTAMP}.jpg"
    FOTO_FINAL="$PASTA_FOTOS/${TIMESTAMP}.jpg"

    # 4. Tira a foto usando a câmara traseira
    termux-camera-photo -c 0 "$FOTO_TEMP"

    # 5. Redimensiona e comprime
    if [ -f "$FOTO_TEMP" ]; then
        magick "$FOTO_TEMP" -resize "${LARGURA_FOTO}x" -quality "$QUALIDADE_FOTO" "$FOTO_FINAL"
        rm "$FOTO_TEMP"
        
        # Indexa a nova foto na Galeria
        termux-media-scan "$FOTO_FINAL" >/dev/null 2>&1
        
        TAMANHO=$(ls -lh "$FOTO_FINAL" | awk '{print $5}')
        echo "[OK] Foto guardada: ${TIMESTAMP}.jpg ($TAMANHO) | Disco: ${USO_DISCO}%"
    else
        echo "[ERRO] Falha ao capturar foto pela câmara."
    fi

    sleep "$INTERVALO_SEGUNDOS"
done
