# Jarvis (OpenJarvis) — guia rápido em português

Este repositório contém o **OpenJarvis** (Stanford — <https://openjarvis.stanford.edu>,
código original em <https://github.com/open-jarvis/OpenJarvis>, licença Apache 2.0):
um assistente de IA pessoal que roda **localmente no seu PC**, usando modelos
abertos via [Ollama](https://ollama.com).

Foram adicionados scripts de instalação e inicialização "de um clique".

## Requisitos

- Internet (a primeira instalação baixa alguns GB: Python, dependências, Ollama e o modelo `qwen3.5:2b` ~1,5 GB)
- ~10 GB livres em disco (mais se for baixar modelos maiores)
- 8 GB de RAM ou mais (GPU é opcional, mas acelera bastante)

## Windows

1. Instale o Git, se ainda não tiver: <https://git-scm.com> (ou `winget install Git.Git`).
2. Baixe o repositório (no PowerShell ou Prompt de Comando):
   ```
   git clone https://github.com/miguelgatto2012-creator/openjarvis.git
   ```
3. Abra a pasta `openjarvis` e dê dois cliques em **`INSTALAR-JARVIS-WINDOWS.bat`**.
   - Ele instala automaticamente: Python 3.13, uv, Node.js, Visual Studio Build Tools (C++),
     Ollama e o modelo inicial. O Windows vai pedir permissão de administrador
     para as Build Tools (download grande — pode demorar).
   - Se ele pedir para reiniciar o PC, reinicie e rode o instalador de novo.
4. Para usar: dê dois cliques em **`INICIAR-JARVIS-WINDOWS.bat`** (ou no atalho
   **Jarvis** criado na Área de Trabalho) e escolha:
   1. conversar no terminal
   2. interface gráfica no navegador
   3. diagnóstico

## Linux / macOS / WSL2

```bash
git clone https://github.com/miguelgatto2012-creator/openjarvis.git
cd openjarvis
bash instalar-jarvis.sh     # instala tudo (não rode com sudo)
bash iniciar-jarvis.sh      # abre o Jarvis
```

## Comandos úteis

```bash
jarvis                     # conversar
jarvis gui                 # interface gráfica (precisa de Node.js 22+)
jarvis doctor              # verifica se está tudo OK
jarvis ask "pergunta"      # pergunta única
jarvis init --preset code-assistant --force   # trocar de "perfil"
ollama pull qwen3.5:9b     # baixar um modelo maior (se o PC aguentar)
```

Presets disponíveis: `chat-simple`, `code-assistant`, `deep-research`,
`scheduled-monitor`, `morning-digest-linux`/`-mac`/`-minimal`.

## Atualizar

Depois de um `git pull` nesta pasta, rode o instalador de novo: ele atualiza a
cópia instalada (em `%LOCALAPPDATA%\OpenJarvis` no Windows ou `~/.openjarvis`
no Linux/macOS).

## Problemas comuns

- **"jarvis não é reconhecido"**: feche e abra o terminal (o PATH foi atualizado) ou use o `INICIAR-JARVIS-*`.
- **Erro `link.exe not found`** (Windows): faltam as Build Tools C++; rode o instalador de novo e aceite instalá-las.
- **Chat não responde**: rode `jarvis doctor`; o modelo pode ainda estar baixando.
- Documentação completa (inglês): <https://open-jarvis.github.io/OpenJarvis/>
