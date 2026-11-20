#!/usr/bin/env bash
# Inicia o Jarvis (Linux/macOS/WSL2): garante o Ollama rodando e abre um menu.
export PATH="$HOME/.local/bin:$PATH"

if ! command -v jarvis >/dev/null 2>&1; then
    echo "Jarvis ainda nao esta instalado. Rode primeiro:  bash instalar-jarvis.sh" >&2
    exit 1
fi

if command -v ollama >/dev/null 2>&1 && ! ollama list >/dev/null 2>&1; then
    echo "[jarvis] Iniciando o Ollama..."
    nohup ollama serve >/tmp/ollama-jarvis.log 2>&1 &
    for _ in $(seq 1 30); do ollama list >/dev/null 2>&1 && break; sleep 1; done
fi

if [[ $# -gt 0 ]]; then exec jarvis "$@"; fi

echo
echo "  ===== JARVIS ====="
echo "  1) Conversar no terminal (padrao)"
echo "  2) Interface grafica no navegador (jarvis gui)"
echo "  3) Diagnostico (jarvis doctor)"
read -r -p "Escolha [1]: " op
case "$op" in
    2) exec jarvis gui ;;
    3) exec jarvis doctor ;;
    *) exec jarvis ;;
esac
