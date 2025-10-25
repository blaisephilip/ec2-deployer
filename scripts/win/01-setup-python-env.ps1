Write-Host "Checking Python and preparing Ansible virtual environment for Windows..."

# Show current Python version if available
try {
    & python --version 2>$null
} catch {
    Write-Host "Python not found in PATH."
}

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python is not installed. Attempting to install using winget (if available)..."

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Running: winget install Python.Python.3.14 -e --accept-package-agreements --accept-source-agreements"
        winget install --id Python.Python.3.14 -e --accept-package-agreements --accept-source-agreements

        # Refresh the current session path (winget installer commonly updates system PATH; user may need to reopen shell)
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Start-Sleep -Seconds 2
    } else {
        Write-Host "winget not available. Please install Python 3.11 manually from https://www.python.org/downloads/windows/ or via Microsoft Store, then re-run this script."
        exit 1
    }

    # Re-check python presence
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Python was not detected after installation. You may need to restart your terminal/PowerShell session. Exiting."
        exit 1
    }
}

# Ensure we are using Python 3.x
$pyVersion = (& python -c "import sys; print(sys.version.split()[0])") 2>$null
if ($pyVersion -notlike "3*") {
    Write-Host "Detected Python version: $pyVersion. Python 3.14 is recommended."
}

# Create virtual environment if not present
$venvPath = Join-Path -Path (Get-Location) -ChildPath "ansible-env"
if (-not (Test-Path $venvPath)) {
    Write-Host "Creating virtual environment at $venvPath"
    & python -m venv $venvPath
} else {
    Write-Host "Virtual environment already exists at $venvPath"
}

# Activate the virtual environment (PowerShell activation script)
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    Write-Host "Activating virtual environment..."
    # dot-source the Activate.ps1 so that changes affect the current session
    . $activateScript
} else {
    Write-Host "Activation script not found: $activateScript"
    Write-Host "Ensure the venv was created successfully and try again."
    exit 1
}

# Upgrade pip and install Ansible (note: Ansible control node functionality is best on Linux/WSL)
Write-Host "Upgrading pip and installing Ansible in the venv..."
python -m pip install --upgrade pip setuptools wheel
# python -m pip install ansible-core ansible-vault-win
python -m pip install --include-deps ansible

# Verify installation
try {
    & ansible --version
} catch {
    Write-Host "Ansible command not found in the venv. If you plan to manage Linux hosts from Windows, consider using WSL2 as the Ansible control node."
}

Write-Host "`nPython and Ansible environment setup complete."
