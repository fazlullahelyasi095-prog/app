# Builds an original geometric TH monogram in TryHub's existing theme colors.
# Windows asset-generation helper; not part of the Flutter runtime.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$iconDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../ios/Runner/Assets.xcassets/AppIcon.appiconset'))
$catalog = Get-Content (Join-Path $iconDirectory 'Contents.json') | ConvertFrom-Json
foreach ($entry in ($catalog.images | Sort-Object filename -Unique)) {
    $size = [int]([double]($entry.size.Split('x')[0]) * [int]($entry.scale.TrimEnd('x')))
    $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $accent = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 45, 85))
    try {
        $graphics.Clear([System.Drawing.Color]::Black)
        $graphics.ScaleTransform($size / 1024.0, $size / 1024.0)
        # White T and pink H. Use geometry so generation has no font dependency.
        $graphics.FillRectangle([System.Drawing.Brushes]::White, 176, 272, 312, 88)
        $graphics.FillRectangle([System.Drawing.Brushes]::White, 288, 360, 88, 392)
        $graphics.FillRectangle($accent, 544, 272, 88, 480)
        $graphics.FillRectangle($accent, 760, 272, 88, 480)
        $graphics.FillRectangle($accent, 632, 468, 128, 88)
        $bitmap.Save((Join-Path $iconDirectory $entry.filename), [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $accent.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}
Write-Output 'Generated opaque iPhone, iPad and App Store icons from the existing catalog.'
