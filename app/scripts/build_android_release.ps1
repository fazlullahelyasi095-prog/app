param(
    [ValidateSet('appbundle', 'apk')][string]$Artifact = 'appbundle',
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$BuildName = '1.0.0',
    [ValidateRange(1, 2100000000)][int]$BuildNumber = 1
)
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
    python scripts/release_preflight.py
    if ($LASTEXITCODE -ne 0) { throw 'Release preflight failed; no release build was started.' }
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
    flutter analyze --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }
    flutter test --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Regression tests failed.' }
    flutter build $Artifact --release --no-pub --dart-define-from-file=release/production.json --build-name=$BuildName --build-number=$BuildNumber
    if ($LASTEXITCODE -ne 0) { throw 'Release compilation or signing failed.' }
    Write-Output 'Local build completed. Verify the signature and complete device/Play checks before uploading.'
} finally {
    Pop-Location
}
