#!/usr/bin/env bash
# ==========================================================
#  Instalador do Jarvis (OpenJarvis) para Linux, macOS e WSL2
#  Uso:  bash instalar-jarvis.sh
# ==========================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENJARVIS_HOME="${OPENJARVIS_HOME:-$HOME/.openjarvis}"
SRC_DIR="$OPENJARVIS_HOME/src"

echo "======================================"
echo "   Instalador do JARVIS (OpenJarvis)"
echo "======================================"
echo "  Pasta do projeto : $REPO_ROOT"
echo "  Destino          : $OPENJARVIS_HOME"
echo

if [[ ! -d "$REPO_ROOT/.git" ]]; then
    echo "Esta pasta nao e um repositorio git. Baixe com:" >&2
    echo "  git clone https://github.com/miguelgatto2012-creator/openjarvis.git" >&2
    exit 1
fi

# Se ja estiver instalado, atualiza a copia instalada com esta pasta.
if [[ -d "$SRC_DIR/.git" ]]; then
    echo "[jarvis] Instalacao existente: atualizando com o conteudo desta pasta..."
    git -C "$SRC_DIR" remote set-url origin "$REPO_ROOT"
    git -C "$SRC_DIR" pull --ff-only || echo "[aviso] nao consegui atualizar automaticamente (alteracoes locais?)."
fi

# Instalador oficial, clonando ESTA pasta em vez do GitHub oficial.
# Ele instala uv, Python, Ollama, baixa o modelo qwen3.5:2b e cria o comando `jarvis`.
export OPENJARVIS_REPO_URL="$REPO_ROOT"
bash "$REPO_ROOT/scripts/install/install.sh" --no-analytics "$@"

chmod +x "$REPO_ROOT/iniciar-jarvis.sh" 2>/dev/null || true
echo
echo "Pronto! Para usar o Jarvis:  bash iniciar-jarvis.sh"
echo "(a interface grafica 'jarvis gui' precisa do Node.js 22+ instalado)"
