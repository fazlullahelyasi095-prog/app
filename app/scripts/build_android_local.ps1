param(
    [string]$ServerAddress = '10.64.199.162',
    [ValidateRange(1, 65535)][int]$Port = 3000,
    [ValidateSet('android-arm', 'android-arm64', 'android-x64')]
    [string]$TargetPlatform = 'android-arm64'
)
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
    $serverUrl = "http://${ServerAddress}:$Port"
    flutter build apk --debug "--target-platform=$TargetPlatform" "--dart-define=API_BASE_URL=$serverUrl/api" "--dart-define=SOCKET_BASE_URL=$serverUrl"
    if ($LASTEXITCODE -ne 0) { throw 'Local APK build failed.' }
    Write-Output "APK: $((Get-Location).Path)\build\app\outputs\flutter-apk\app-debug.apk"
    Write-Output "Backend: $serverUrl (phone and server must share the local network)."
} finally {
    Pop-Location
}
