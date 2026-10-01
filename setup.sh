#!/data/data/com.termux/files/usr/bin/bash

# Evita perguntas interativas durante a instalação
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# Define a palavra-passe para o SSH
PASSWORD="mudar_para_sua_senha"

echo "[+] A manter o Termux ativo..."
termux-wake-lock

echo "[+] A solicitar acesso ao armazenamento..."
termux-setup-storage

echo "[+] A atualizar repositórios base..."
pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "[+] A ativar o repositório X11..."
pkg install x11-repo -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "[+] A atualizar a lista de pacotes..."
pkg update -y

echo "[+] A instalar pacotes e dependências..."
pkg install termux-api imagemagick openssh wget net-tools termux-api python python-pip python-onnxruntime clang make screen dbus -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "[+] A configurar a palavra-passe do utilizador..."
echo -e "${PASSWORD}\n${PASSWORD}" | passwd

echo "[+] A iniciar o servidor SSH..."
sshd

echo -e "\n========================================"
echo "[+] Setup concluído com sucesso!"
echo "Utilizador: $(whoami)"
echo "Endereço IP:"
ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'
echo "Servidor SSH ativo no porto 8022."
echo "========================================"
