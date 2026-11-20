# Inicia o Jarvis no Windows: garante que o Ollama esta rodando e abre um menu.
$ErrorActionPreference = 'Continue'
$installRoot = if ($env:OPENJARVIS_HOME) { $env:OPENJARVIS_HOME } else { Join-Path $env:LOCALAPPDATA 'OpenJarvis' }
$m = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$u = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$(Join-Path $installRoot 'bin');$env:USERPROFILE\.local\bin;$m;$u"

if (-not (Get-Command jarvis -ErrorAction SilentlyContinue)) {
    Write-Host "Jarvis ainda nao esta instalado. Rode primeiro INSTALAR-JARVIS-WINDOWS.bat" -ForegroundColor Red
    exit 1
}

# Ollama (motor dos modelos locais)
$ollama = (Get-Command ollama -ErrorAction SilentlyContinue).Source
if ($ollama) {
    try { & $ollama list 2>&1 | Out-Null } catch { }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Iniciando o Ollama..." -ForegroundColor Cyan
        Start-Process -FilePath $ollama -ArgumentList 'serve' -WindowStyle Hidden
        for ($i = 0; $i -lt 30; $i++) {
            Start-Sleep -Seconds 1
            try { & $ollama list 2>&1 | Out-Null } catch { }
            if ($LASTEXITCODE -eq 0) { break }
        }
    }
} else {
    Write-Host "Aviso: Ollama nao encontrado; rode o instalador de novo." -ForegroundColor Yellow
}

if ($args.Count -gt 0) { & jarvis @args; exit $LASTEXITCODE }

Write-Host ""
Write-Host "  ===== JARVIS =====" -ForegroundColor Green
Write-Host "  1) Conversar no terminal (padrao)"
Write-Host "  2) Interface grafica no navegador (jarvis gui)"
Write-Host "  3) Diagnostico (jarvis doctor)"
$op = Read-Host "Escolha [1]"
switch ($op) {
    '2' { & jarvis gui }
    '3' { & jarvis doctor }
    default { & jarvis }
}
