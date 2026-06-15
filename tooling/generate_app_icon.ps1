[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$masterPath = Join-Path $root 'assets\branding\health_monitor_app_icon_master.png'

$androidIcons = @{
    (Join-Path $root 'android\app\src\main\res\mipmap-mdpi\ic_launcher.png') = 48
    (Join-Path $root 'android\app\src\main\res\mipmap-hdpi\ic_launcher.png') = 72
    (Join-Path $root 'android\app\src\main\res\mipmap-xhdpi\ic_launcher.png') = 96
    (Join-Path $root 'android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png') = 144
    (Join-Path $root 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png') = 192
}

$androidRoundIcons = @{
    (Join-Path $root 'android\app\src\main\res\mipmap-mdpi\ic_launcher_round.png') = 48
    (Join-Path $root 'android\app\src\main\res\mipmap-hdpi\ic_launcher_round.png') = 72
    (Join-Path $root 'android\app\src\main\res\mipmap-xhdpi\ic_launcher_round.png') = 96
    (Join-Path $root 'android\app\src\main\res\mipmap-xxhdpi\ic_launcher_round.png') = 144
    (Join-Path $root 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_round.png') = 192
}

$iosIcons = @{
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png') = 20
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png') = 40
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png') = 60
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png') = 29
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png') = 58
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png') = 87
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png') = 40
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png') = 80
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png') = 120
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png') = 120
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png') = 180
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png') = 76
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png') = 152
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png') = 167
    (Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png') = 1024
}

function New-ArgbColor {
    param(
        [int]$A,
        [int]$R,
        [int]$G,
        [int]$B
    )

    return [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function New-RoundRectPath {
    param(
        [System.Drawing.RectangleF]$Rect,
        [float]$Radius
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = [Math]::Min($Radius * 2, [Math]::Min($Rect.Width, $Rect.Height))
    $path.AddArc($Rect.X, $Rect.Y, $d, $d, 180, 90)
    $path.AddArc($Rect.Right - $d, $Rect.Y, $d, $d, 270, 90)
    $path.AddArc($Rect.Right - $d, $Rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($Rect.X, $Rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-Canvas {
    param([int]$Size)

    return [System.Drawing.Bitmap]::new($Size, $Size)
}

function Initialize-Graphics {
    param([System.Drawing.Bitmap]$Bitmap)

    $graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    return $graphics
}

function Save-ScaledBitmap {
    param(
        [System.Drawing.Bitmap]$Source,
        [string]$Path,
        [int]$Size
    )

    $directory = Split-Path $Path -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $target = New-Canvas -Size $Size
    $graphics = Initialize-Graphics -Bitmap $target
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.DrawImage($Source, 0, 0, $Size, $Size)
        $target.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $target.Dispose()
    }
}

function Draw-Icon {
    param([int]$Size)

    $bitmap = New-Canvas -Size $Size
    $graphics = Initialize-Graphics -Bitmap $bitmap
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)

        $top = New-ArgbColor 255 92 119 104
        $bottom = New-ArgbColor 255 123 151 134
        $backgroundBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            [System.Drawing.Rectangle]::new(0, 0, $Size, $Size),
            $top,
            $bottom,
            [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $graphics.FillRectangle($backgroundBrush, 0, 0, $Size, $Size)
        $backgroundBrush.Dispose()

        # 背景高光，让图标更有层次感.
        $warmPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $warmPath.AddEllipse($Size * 0.06, $Size * 0.04, $Size * 0.86, $Size * 0.72)
        $warmGlow = [System.Drawing.Drawing2D.PathGradientBrush]::new($warmPath)
        $warmGlow.CenterColor = [System.Drawing.Color]::FromArgb(92, 244, 232, 218)
        $warmGlow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 244, 232, 218))
        $graphics.FillPath($warmGlow, $warmPath)
        $warmGlow.Dispose()
        $warmPath.Dispose()

        $coolPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $coolPath.AddEllipse($Size * 0.34, $Size * 0.16, $Size * 0.56, $Size * 0.48)
        $coolGlow = [System.Drawing.Drawing2D.PathGradientBrush]::new($coolPath)
        $coolGlow.CenterColor = [System.Drawing.Color]::FromArgb(60, 224, 235, 238)
        $coolGlow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 224, 235, 238))
        $graphics.FillPath($coolGlow, $coolPath)
        $coolGlow.Dispose()
        $coolPath.Dispose()

        $panelSize = $Size * 0.63
        $panelX = ($Size - $panelSize) / 2
        $panelRect = [System.Drawing.RectangleF]::new($panelX, $panelX, $panelSize, $panelSize)

        $shadowRect = [System.Drawing.RectangleF]::new($panelRect.X, ($panelRect.Y + ($Size * 0.012)), $panelRect.Width, $panelRect.Height)
        $shadowPath = New-RoundRectPath -Rect $shadowRect -Radius ($panelSize * 0.2)
        $shadowBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 88 31 35 32))
        $graphics.FillPath($shadowBrush, $shadowPath)
        $shadowBrush.Dispose()
        $shadowPath.Dispose()

        $panelPath = New-RoundRectPath -Rect $panelRect -Radius ($panelSize * 0.2)
        $panelBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 255 255 253 248))
        $graphics.FillPath($panelBrush, $panelPath)
        $panelBrush.Dispose()

        $panelBorder = [System.Drawing.Pen]::new((New-ArgbColor 220 221 216 207), ($Size * 0.006))
        $panelBorder.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawPath($panelBorder, $panelPath)
        $panelBorder.Dispose()

        $panelHighlightPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $panelHighlightPath.AddEllipse($panelRect.X + ($Size * 0.04), $panelRect.Y + ($Size * 0.03), $panelRect.Width * 0.72, $panelRect.Height * 0.72)
        $panelHighlightBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 28 244 232 218))
        $graphics.FillPath($panelHighlightBrush, $panelHighlightPath)
        $panelHighlightBrush.Dispose()
        $panelHighlightPath.Dispose()
        $panelPath.Dispose()

        $cx = $Size / 2.0
        $cy = $Size / 2.0
        $ringRadius = $Size * 0.21

        $ringRect = [System.Drawing.RectangleF]::new($cx - $ringRadius, $cy - $ringRadius, $ringRadius * 2, $ringRadius * 2)
        $ringPen = [System.Drawing.Pen]::new((New-ArgbColor 255 123 151 134), ($Size * 0.017))
        $ringPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawEllipse($ringPen, $ringRect.X, $ringRect.Y, $ringRect.Width, $ringRect.Height)
        $ringPen.Dispose()

        $innerRadius = $Size * 0.174
        $innerRect = [System.Drawing.RectangleF]::new($cx - $innerRadius, $cy - $innerRadius, $innerRadius * 2, $innerRadius * 2)
        $innerBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 255 247 244 237))
        $graphics.FillEllipse($innerBrush, $innerRect)
        $innerBrush.Dispose()

        $innerBorder = [System.Drawing.Pen]::new((New-ArgbColor 220 221 216 207), ($Size * 0.004))
        $graphics.DrawEllipse($innerBorder, $innerRect.X, $innerRect.Y, $innerRect.Width, $innerRect.Height)
        $innerBorder.Dispose()

        $pulsePoints = [System.Drawing.PointF[]]@(
            ([System.Drawing.PointF]::new($cx - ($Size * 0.132), $cy + ($Size * 0.009))),
            ([System.Drawing.PointF]::new($cx - ($Size * 0.073), $cy + ($Size * 0.009))),
            ([System.Drawing.PointF]::new($cx - ($Size * 0.040), $cy - ($Size * 0.054))),
            ([System.Drawing.PointF]::new($cx - ($Size * 0.007), $cy + ($Size * 0.035))),
            ([System.Drawing.PointF]::new($cx + ($Size * 0.036), $cy - ($Size * 0.023))),
            ([System.Drawing.PointF]::new($cx + ($Size * 0.081), $cy + ($Size * 0.009))),
            ([System.Drawing.PointF]::new($cx + ($Size * 0.132), $cy + ($Size * 0.009)))
        )

        $pulseShadow = [System.Drawing.Pen]::new((New-ArgbColor 120 255 253 248), ($Size * 0.022))
        $pulseShadow.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pulseShadow.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pulseShadow.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawLines($pulseShadow, $pulsePoints)
        $pulseShadow.Dispose()

        $pulsePen = [System.Drawing.Pen]::new((New-ArgbColor 255 31 35 32), ($Size * 0.009))
        $pulsePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pulsePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pulsePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawLines($pulsePen, $pulsePoints)
        $pulsePen.Dispose()

        $accent = [System.Drawing.SolidBrush]::new((New-ArgbColor 255 216 165 110))
        $graphics.FillEllipse($accent, $cx + ($Size * 0.144), $cy - ($Size * 0.129), $Size * 0.021, $Size * 0.021)
        $accent.Dispose()

        $accentHighlight = [System.Drawing.SolidBrush]::new((New-ArgbColor 255 255 253 248))
        $graphics.FillEllipse($accentHighlight, $cx + ($Size * 0.149), $cy - ($Size * 0.124), $Size * 0.008, $Size * 0.008)
        $accentHighlight.Dispose()

        $coolDot = [System.Drawing.SolidBrush]::new((New-ArgbColor 255 224 235 238))
        $graphics.FillEllipse($coolDot, $cx - ($Size * 0.166), $cy + ($Size * 0.116), $Size * 0.018, $Size * 0.018)
        $coolDot.Dispose()

        return $bitmap
    }
    finally {
        $graphics.Dispose()
    }
}

$master = Draw-Icon -Size 2048
try {
    if (-not (Test-Path (Split-Path $masterPath -Parent))) {
        New-Item -ItemType Directory -Path (Split-Path $masterPath -Parent) -Force | Out-Null
    }
    $master.Save($masterPath, [System.Drawing.Imaging.ImageFormat]::Png)

    foreach ($entry in $androidIcons.GetEnumerator()) {
        Save-ScaledBitmap -Source $master -Path $entry.Key -Size $entry.Value
    }

    foreach ($entry in $androidRoundIcons.GetEnumerator()) {
        Save-ScaledBitmap -Source $master -Path $entry.Key -Size $entry.Value
    }

    foreach ($entry in $iosIcons.GetEnumerator()) {
        Save-ScaledBitmap -Source $master -Path $entry.Key -Size $entry.Value
    }

    Write-Host "master: $masterPath"
    Write-Host ("android icons: {0} files" -f ($androidIcons.Count + $androidRoundIcons.Count))
    Write-Host ("ios icons: {0} files" -f $iosIcons.Count)
}
finally {
    $master.Dispose()
}

