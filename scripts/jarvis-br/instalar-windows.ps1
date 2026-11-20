<#
  Instalador "um clique" do Jarvis para Windows.

  O que ele faz:
    1. Garante git, Python 3.13, uv, Node.js (para a interface grafica)
       e as Build Tools do Visual Studio (C++), necessarias para compilar
       a extensao Rust do OpenJarvis.
    2. Chama o instalador oficial (deploy\windows\install.ps1) apontando
       para ESTA pasta, em vez do GitHub oficial. Ele instala tudo em
       %LOCALAPPDATA%\OpenJarvis, instala o Ollama e baixa o modelo
       qwen3.5:2b (~1.5 GB).
    3. Cria um atalho "Jarvis" na Area de Trabalho.

  Pode ser executado de novo a qualquer momento: ele atualiza a copia
  instalada com o conteudo desta pasta.
#>
$ErrorActionPreference = 'Stop'

function Info ($m) { Write-Host "[jarvis] $m" -ForegroundColor Cyan }
function Ok   ($m) { Write-Host "[ ok ]   $m" -ForegroundColor Green }
function Warn ($m) { Write-Host "[aviso]  $m" -ForegroundColor Yellow }

function Update-PathFromRegistry {
    $m = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $u = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$m;$u;$env:USERPROFILE\.local\bin"
}

function Install-Winget ($id, $extra) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Warn "winget nao encontrado. Instale '$id' manualmente."
        return
    }
    Info "Instalando $id via winget..."
    $wargs = @('install', '--id', $id, '-e', '--accept-source-agreements', '--accept-package-agreements')
    if ($extra) { $wargs += $extra }
    & winget @wargs
    Update-PathFromRegistry
}

function Test-MsvcLinker {
    if (-not ${env:ProgramFiles(x86)}) { return $false }
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $vswhere)) { return $false }
    $found = & $vswhere -latest -products * `
        -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        -find 'VC\Tools\MSVC\**\bin\Host*\*\link.exe' 2>$null
    foreach ($l in @($found)) { if ($l -and (Test-Path -LiteralPath $l)) { return $true } }
    return $false
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$installRoot = if ($env:OPENJARVIS_HOME) { $env:OPENJARVIS_HOME } else { Join-Path $env:LOCALAPPDATA 'OpenJarvis' }
$srcDir = Join-Path $installRoot 'src'
$firstInstall = -not (Test-Path (Join-Path $srcDir '.git'))

Write-Host ""
Write-Host "  ======================================" -ForegroundColor Green
Write-Host "     Instalador do JARVIS (OpenJarvis)  " -ForegroundColor Green
Write-Host "  ======================================" -ForegroundColor Green
Write-Host "  Pasta do projeto : $repoRoot"
Write-Host "  Destino          : $installRoot"
Write-Host ""

Update-PathFromRegistry

# 1. git (o instalador oficial clona esta pasta com git)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Install-Winget 'Git.Git' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git nao encontrado. Instale em https://git-scm.com e rode de novo." }
Ok "git"

# O instalador oficial clona via git: esta pasta precisa ser um repositorio git.
if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
    throw "Esta pasta nao e um repositorio git. Baixe com: git clone https://github.com/miguelgatto2012-creator/openjarvis.git"
}
& git config --global --add safe.directory ($repoRoot -replace '\\', '/') 2>$null

# 2. Node.js (so para 'jarvis gui'; nao e obrigatorio)
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Install-Winget 'OpenJS.NodeJS.LTS'
}
if (Get-Command node -ErrorAction SilentlyContinue) { Ok "Node.js $(node --version)" } else { Warn "Node.js ausente: a interface grafica (jarvis gui) nao vai funcionar, o chat no terminal sim." }

# 3. Visual Studio Build Tools (C++) - obrigatorio para a extensao Rust
if (-not (Test-MsvcLinker)) {
    Warn "As Build Tools C++ do Visual Studio nao foram encontradas (necessarias para compilar o OpenJarvis)."
    Warn "Download de alguns GB; o Windows vai pedir permissao de administrador."
    $r = Read-Host "Instalar agora? [S/n]"
    if ($r -notmatch '^[nN]') {
        Install-Winget 'Microsoft.VisualStudio.2022.BuildTools' @('--override', '--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
    }
    if (-not (Test-MsvcLinker)) {
        throw "Build Tools ainda nao detectadas. Reinicie o PC e rode este instalador de novo."
    }
}
Ok "Build Tools C++"

# 4. Instalador oficial, apontando para esta pasta
$env:OPENJARVIS_REPO_URL = $repoRoot
$env:OPENJARVIS_SKIP_SERVICE = '1'
if (-not $firstInstall) {
    Info "Instalacao existente encontrada: atualizando com o conteudo desta pasta..."
    & git -C $srcDir remote set-url origin $repoRoot
    $env:OPENJARVIS_FORCE = '1'
}
Info "Rodando o instalador oficial do OpenJarvis (pode levar varios minutos)..."
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'deploy\windows\install.ps1') -SkipService
if ($LASTEXITCODE -ne 0) { throw "O instalador oficial falhou (codigo $LASTEXITCODE). Veja as mensagens acima." }
Update-PathFromRegistry

# 5. Config inicial (motor local Ollama + qwen3.5:2b) na primeira instalacao
if ($firstInstall) {
    Info "Gerando configuracao inicial..."
    try {
        & uv run --project $srcDir jarvis _bootstrap --write-config --engine ollama --model 'qwen3.5:2b'
    } catch { Warn "Nao foi possivel gerar a config agora; o Jarvis cria uma no primeiro uso." }
}

# 6. Atalho na Area de Trabalho
try {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut((Join-Path $desktop 'Jarvis.lnk'))
    $lnk.TargetPath = Join-Path $repoRoot 'INICIAR-JARVIS-WINDOWS.bat'
    $lnk.WorkingDirectory = $repoRoot
    $lnk.Description = 'Iniciar o Jarvis (OpenJarvis)'
    $lnk.Save()
    Ok "Atalho 'Jarvis' criado na Area de Trabalho"
} catch { Warn "Nao consegui criar o atalho: $($_.Exception.Message)" }

Write-Host ""
Write-Host "  Pronto! Para usar: de dois cliques em INICIAR-JARVIS-WINDOWS.bat" -ForegroundColor Green
Write-Host "  (ou no atalho 'Jarvis' da Area de Trabalho)." -ForegroundColor Green
Write-Host "  Obs.: modelos maiores e a extensao Rust continuam baixando em segundo plano."
Write-Host "        'jarvis doctor' mostra o status."
