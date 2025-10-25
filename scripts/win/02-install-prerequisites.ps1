Write-Host "Checking WSL installation..."
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "WSL is not installed. Please install WSL by following the instructions at https://learn.microsoft.com/en-us/windows/wsl/install and re-run this script."
    exit 1
}

Write-Host "WSL is installed."

Write-Host "Install Ubuntu on WSL if not already installed..."
if (-not (wsl -l -q | Select-String -Pattern "^Ubuntu$")) {
    Write-Host "Ubuntu distribution not found. Installing Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "Ubuntu installed. You may need to restart your terminal/PowerShell session."
} else {
    Write-Host "Ubuntu distribution is already installed."
}
Write-Host "WSL and Ubuntu setup complete."

Write-Host "Available WSL distributions:"
wsl --list --all
Write-Host "You can now run Linux commands and tools via WSL."
Write-Host "Switching to WSL to install prerequisites..."

# Resolve repo root (script is scripts\win\01-install-prerequisites.ps1)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path

# Convert Windows path to WSL path (fallback to simple /mnt/c/... if wslpath fails)
try {
    $wslRepo = wsl wslpath -a "$repoRoot" 2>$null
    if (-not $wslRepo) { throw "wslpath empty" }
} catch {
    $drive = $repoRoot.Substring(0,2).ToLower() -replace ':',''
    $wslRepo = "/mnt/$drive" + ($repoRoot.Substring(2) -replace '\\','/')
}

# Run safe single-line command in WSL
$cmd = "sudo apt update && sudo apt upgrade -y && sudo apt install -y dos2unix python3-venv && cd '$wslRepo' && bash ./01-setup-environment.sh"
Write-Host "Running in WSL: $cmd"
wsl bash -lc $cmd