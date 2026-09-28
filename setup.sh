#!/data/data/com.termux/files/usr/bin/bash

# Define a palavra-passe para o SSH (altera para a tua)
PASSWORD="mudar_para_sua_senha"

echo "[+] A manter o Termux ativo..."
termux-wake-lock

echo "[+] A solicitar acesso ao armazenamento..."
termux-setup-storage

echo "[+] A atualizar repositórios base..."
pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confold"

echo "[+] A ativar o repositório X11 (necessário para dbus e pacotes gráficos)..."
pkg install x11-repo -y

echo "[+] A atualizar lista de pacotes após ativar X11..."
pkg update -y

echo "[+] A instalar pacotes de sistema, ferramentas e dependências..."
pkg install openssh wget net-tools termux-api python python-pip python-onnxruntime clang make screen dbus -y

echo "[+] A configurar a palavra-passe do utilizador..."
echo -e "${PASSWORD}\n${PASSWORD}" | passwd

echo "[+] A iniciar o servidor SSH..."
sshd

echo -e "\n========================================"
echo "[+] Setup concluído com sucesso!"
echo "Utilizador: $(whoami)"
echo "Endereço IP:"
ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'
echo "Servidor SSH a correr no porto 8022."
echo "========================================"
