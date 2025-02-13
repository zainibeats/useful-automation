@echo off
:: resize_media.bat
:: Purpose: Batch resize image files using ImageMagick
:: Supports: GIF, PNG, JPG, JPEG, WEBP, AVIF, TIFF, and more
:: Requirements: ImageMagick must be installed and in system PATH

:: Configuration
:: Target directory containing media files (will process all subdirectories)
set "TARGET_DIR=assets\images"

:: Resize percentage (130 = 30% increase)
:: NOTE: This is a placeholder value. You should set this to the desired percentage.
set "RESIZE_PERCENT=130"

:: File types to process (space-separated)
:: Add or remove extensions as needed
set "FILE_TYPES=*.gif *.png *.jpg *.jpeg *.webp *.avif *.tiff"

:: Processing mode
:: 0 = Standard (good for photos)
:: 1 = Pixel art mode (preserves sharp edges)
set "PIXEL_ART_MODE=0"

echo Processing media files in %TARGET_DIR%...
echo Using %RESIZE_PERCENT%%% scaling...
echo File types: %FILE_TYPES%
echo Mode: %PIXEL_ART_MODE% (0=Standard, 1=Pixel Art)

:: Process each file in the directory and subdirectories
:: Flags:
::   -coalesce: Fully render each frame (for animations)
::   -filter point: Preserve pixel art sharpness (when PIXEL_ART_MODE=1)
::   -resize: Scale the image by specified percentage
::   -layers optimize: Optimize animations (for GIFs)
for %%T in (%FILE_TYPES%) do (
    echo.
    echo Processing %%T files...
    for /R "%TARGET_DIR%" %%F in (%%T) do (
        echo Processing: %%F
        if %PIXEL_ART_MODE%==1 (
            magick mogrify -coalesce -filter point -resize %RESIZE_PERCENT%%% -layers optimize "%%F"
        ) else (
            magick mogrify -coalesce -resize %RESIZE_PERCENT%%% -layers optimize "%%F"
        )
    )
)

echo.
echo All media files have been processed successfully.
pause
