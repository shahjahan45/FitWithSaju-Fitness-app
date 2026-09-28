param(
    [Parameter(Mandatory = $true)]
    [string]$LaravelPath
)

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$MediaSource = Join-Path $ProjectRoot "assets\exercises\media\*"
$ThumbSource = Join-Path $ProjectRoot "assets\exercises\thumbs\*"
$MediaTarget = Join-Path $LaravelPath "storage\app\public\exercises\media"
$ThumbTarget = Join-Path $LaravelPath "storage\app\public\exercises\thumbs"

New-Item -ItemType Directory -Force -Path $MediaTarget | Out-Null
New-Item -ItemType Directory -Force -Path $ThumbTarget | Out-Null
Copy-Item $MediaSource $MediaTarget -Force
Copy-Item $ThumbSource $ThumbTarget -Force

Write-Host "FitWithSaju exercise media copied successfully." -ForegroundColor Green
Write-Host "Next run: php artisan storage:link"
