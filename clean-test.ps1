# Controle local sans lecture ni export de mots de passe, jetons ou conversations.
[CmdletBinding()]
param(
    [ValidateSet('BeforeInstall', 'AfterInstall')][string]$Stage = 'BeforeInstall',
    [string]$OutputPath = 'med-tutor-preflight.json'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$profileRoot = [Environment]::GetFolderPath('UserProfile')
$codexRoot = Join-Path $profileRoot '.codex'
$configPath = Join-Path $codexRoot 'config.toml'
$configText = if (Test-Path -LiteralPath $configPath) { Get-Content -LiteralPath $configPath -Raw } else { '' }
$pluginRoot = Join-Path $codexRoot 'plugins'
$medTutorFiles = @()
if (Test-Path -LiteralPath $pluginRoot) {
    $medTutorFiles = @(Get-ChildItem -LiteralPath $pluginRoot -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object Name -eq 'med-tutor')
}
$skillPaths = @('.agents\skills\med-tutor', '.claude\skills\med-tutor')
$inheritedSkill = @($skillPaths | Where-Object { Test-Path -LiteralPath (Join-Path $profileRoot $_) }).Count -gt 0
$checks = [ordered]@{
    utc = [DateTime]::UtcNow.ToString('o')
    stage = $Stage
    codex_home_override_present = [bool]$env:CODEX_HOME
    med_tutor_cache_present = $medTutorFiles.Count -gt 0
    external_med_tutor_skill_present = $inheritedSkill
    standalone_mcp_config_present = $configText -match '(?m)^\s*\[mcp_servers\.'
    static_mcp_token_environment_present = [bool]$env:MCP_TOKEN
    browser_isolation = 'manual verification required'
    separate_openai_account = 'manual verification required'
    desktop_acceptance = 'untested'
}
$clean = -not ($checks.codex_home_override_present -or $checks.med_tutor_cache_present -or
    $checks.external_med_tutor_skill_present -or $checks.standalone_mcp_config_present -or
    $checks.static_mcp_token_environment_present)
$checks.local_baseline_clean = $clean
$checks | ConvertTo-Json | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "Rapport sans identifiants ecrit : $OutputPath"
if ($Stage -eq 'BeforeInstall' -and -not $clean) {
    throw 'Le profil contient une configuration preexistante. Utilisez un nouveau profil Windows; ne supprimez pas votre installation habituelle.'
}
