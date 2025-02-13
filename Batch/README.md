# Batch Utility Scripts

This directory contains Windows Batch scripts for various file operations.

## Scripts

### resize_media.bat

A versatile utility script to batch resize various types of image files while preserving quality. Supports multiple image formats and processing modes. Particularly useful for:
- Batch processing multiple image files in one operation
- Processing nested directories of media files
- Upscaling pixel art while maintaining quality
- Resizing photos with proper interpolation
- Optimizing animated GIFs
- Converting and processing modern image formats (WebP, AVIF)

#### Supported Formats
- Animated: GIF
- Raster: PNG, JPG/JPEG, WebP, AVIF, TIFF
- And more (any format supported by ImageMagick)

#### Requirements
- Windows operating system
- ImageMagick installed and added to system PATH
- Read/Write permissions in the target directory

#### Usage

1. Configure the script variables (optional):
   ```batch
   set "TARGET_DIR=assets\images"      # Directory containing image files
   set "RESIZE_PERCENT=130"            # Scale factor (130 = 30% increase)
   set "FILE_TYPES=*.gif *.png *.jpg"  # Space-separated list of extensions
   set "PIXEL_ART_MODE=0"              # 0=Standard, 1=Pixel Art
   ```

2. Place the script in a convenient location and run it:
   ```batch
   resize_media.bat
   ```

#### Features
- Supports multiple image formats
- Two processing modes:
  - Standard mode (best for photographs)
  - Pixel art mode (preserves sharp edges)
- Recursively processes all matching files in target directory and subdirectories
- Preserves animation frames and timing in GIFs
- Optimizes output for file size and performance
- Provides detailed progress feedback during processing

#### Notes
- Default scaling is 130% (30% increase)
- Original files are modified in place; make backups before running
- Processing time depends on file size, type, and quantity
- The script can be modified to use different ImageMagick parameters for various effects

#### Customization Examples
```batch
:: Common file type combinations:
set "FILE_TYPES=*.gif *.png"                    # Pixel art formats
set "FILE_TYPES=*.jpg *.jpeg *.webp"            # Photo formats
set "FILE_TYPES=*.gif *.png *.jpg *.webp"       # Mixed formats

:: Different scaling options:
set "RESIZE_PERCENT=50"                         # Downscale by 50%
set "RESIZE_PERCENT=200"                        # Double size
set "RESIZE_PERCENT=75"                         # Reduce to 75%

:: Processing variations (modify the ImageMagick command):
:: High-quality photo scaling:
magick mogrify -filter Lanczos -resize 130% "%%F"

:: Maximum compression:
magick mogrify -resize 130% -compress JPEG2000 "%%F"

:: Convert while resizing:
magick mogrify -resize 130% -format webp "%%F"

:: Advanced animation handling:
magick mogrify -coalesce -resize 130% -layers optimize -loop 0 "%%F"
```

#### Troubleshooting
- If files are skipped: Check file permissions and ImageMagick installation
- If quality is poor: Ensure PIXEL_ART_MODE is set correctly for your media type
- If processing is slow: Process fewer file types at once or reduce directory size
- For memory errors: Process larger files individually or reduce the batch size 