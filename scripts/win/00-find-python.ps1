Write-Host "Searching for Python installations..."

# Check if running on Windows
if ($null -eq $IsWindows) {
    # PowerShell 5.1 or below
    $IsWindowsOS = $true # Since PS 5.1 only runs on Windows
} else {
    # PowerShell Core 6.0 or higher
    $IsWindowsOS = $IsWindows
}

if ($IsWindowsOS) {
    Write-Host "Running on Windows"
} else {
    Write-Host "Not running on Windows - exiting script."
    Write-Host "This script is designed to run on Windows systems only."
    return
}

# Check common installation paths
$paths = @(
    "$env:LOCALAPPDATA\Programs\Python\*",
    "C:\Program Files\Python*",
    "C:\Program Files (x86)\Python*",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps\python*.exe"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Get-Item $path | ForEach-Object {
            Write-Host "`nFound Python in: $($_.FullName)"
            if (Test-Path "$($_.FullName)\python.exe") {
                $version = & "$($_.FullName)\python.exe" --version 2>&1
                Write-Host "Version: $version"
            }
        }
    }
}

# Check system PATH for Python executables
Write-Host "`nPython executables in PATH:"
$env:Path -split ';' | Where-Object { $_ -like '*Python*' } | ForEach-Object {
    Write-Host $_
}

# List available Python versions using py launcher
Write-Host "`nPy Launcher available versions:"
py --list