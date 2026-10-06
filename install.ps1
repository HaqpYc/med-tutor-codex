# Installe uniquement le plugin med-tutor depuis une version Git precise.
[CmdletBinding()]
param(
    [ValidateSet('Install', 'Check', 'Remove')][string]$Action = 'Install',
    [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+$')][string]$Release = 'v0.1.2',
    [string]$CodexPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$marketplace = 'med-tutor-codex'
$selector = 'med-tutor@med-tutor-codex'
$repository = 'https://github.com/HaqpYc/med-tutor-codex.git'

if (-not $CodexPath) {
    $command = Get-Command codex.exe -ErrorAction SilentlyContinue
    if (-not $command) { $command = Get-Command codex -ErrorAction SilentlyContinue }
    if ($command) { $CodexPath = $command.Source }
    else {
        # Runtime fourni avec l'application Windows, sans Node.js ni npm.
        $runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
        if (Test-Path -LiteralPath $runtimeRoot) {
            $candidates = @(Get-ChildItem -LiteralPath $runtimeRoot -Directory | Sort-Object LastWriteTime -Descending)
            foreach ($candidate in $candidates) {
                $executable = Join-Path $candidate.FullName 'codex.exe'
                if (Test-Path -LiteralPath $executable -PathType Leaf) { $CodexPath = $executable; break }
            }
        }
    }
}
if (-not $CodexPath -or -not (Test-Path -LiteralPath $CodexPath -PathType Leaf)) {
    throw 'Codex introuvable. Installez et ouvrez Codex pour Windows, ou indiquez -CodexPath avec le chemin de codex.exe.'
}
function Invoke-Codex {
    param([string[]]$Arguments)
    $result = & $CodexPath @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Codex a echoue (code $LASTEXITCODE). Aucune autre configuration n'est remplacee." }
    return $result
}
Invoke-Codex -Arguments @('--version') | Write-Output
$catalogs = (Invoke-Codex -Arguments @('plugin', 'marketplace', 'list', '--json') | Out-String | ConvertFrom-Json).marketplaces
$existing = @($catalogs | Where-Object name -eq $marketplace)
if ($Action -eq 'Check') {
    Invoke-Codex -Arguments @('plugin', 'list', '--json') | Write-Output
    return
}
if ($existing.Count -gt 1) { throw 'Plusieurs sources med-tutor-codex existent. Faites verifier la configuration.' }
if ($existing.Count -eq 1) {
    $sourceProperty = $existing[0].PSObject.Properties['marketplaceSource']
    if (-not $sourceProperty -or $sourceProperty.Value.sourceType -ne 'git' -or
        $sourceProperty.Value.source.TrimEnd('/') -ne $repository) {
        throw 'La source med-tutor-codex existante ne correspond pas au depot attendu. Elle est conservee.'
    }
}
if ($Action -eq 'Remove') {
    Invoke-Codex -Arguments @('plugin', 'remove', $selector) | Write-Output
    if ($existing.Count) { Invoke-Codex -Arguments @('plugin', 'marketplace', 'remove', $marketplace) | Write-Output }
    Write-Output 'Plugin retire. Une connexion OAuth distincte peut encore exister : deconnectez-la dans les reglages de Codex.'
    return
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git est requis pour cette source. Installez Git pour Windows depuis git-scm.com, puis relancez PowerShell.'
}
# Reenregistrer uniquement notre source garantit la version demandee, meme lors d'une mise a jour.
if ($existing.Count) { Invoke-Codex -Arguments @('plugin', 'marketplace', 'remove', $marketplace) | Write-Output }
Invoke-Codex -Arguments @('plugin', 'marketplace', 'add', $repository, '--ref', $Release) | Write-Output
Invoke-Codex -Arguments @('plugin', 'add', $selector) | Write-Output
Write-Output 'Installation terminee. Quittez completement Codex, relancez-le, puis ouvrez une nouvelle conversation et connectez med-tutor.'
Write-Output 'Saisissez vos identifiants med-tutor uniquement sur med-tutor-consent.pages.dev. Installation ne signifie pas connexion validee.'
