@echo off
setlocal enabledelayedexpansion

echo ===== Release Signing and Packaging Script =====
echo This script will sign and package your release artifacts.

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

REM Set default values for missing configuration
if not defined GPG_KEY_ID set GPG_KEY_ID=YOUR_GPG_KEY_ID
if not defined ENABLE_SIGNING set ENABLE_SIGNING=true
if not defined OUTPUT_DIR set OUTPUT_DIR=build

REM Create release directory
echo Creating release directory...
if not exist release mkdir release

REM Process readme template
if exist template-processor.bat (
    echo Processing readme template...
    call template-processor.bat
) else (
    echo WARNING: template-processor.bat not found. Skipping template processing.
)

REM Determine what files to copy based on the output type
echo Copying release artifacts to release directory...

if "%OUTPUT_TYPE%"=="installer_portable" (
    REM Copy installer and portable executables
    if exist "%OUTPUT_DIR%\%INSTALLER_NAME%" (
        copy /Y "%OUTPUT_DIR%\%INSTALLER_NAME%" release\
    ) else (
        echo WARNING: %OUTPUT_DIR%\%INSTALLER_NAME% not found. Skipping copy.
    )
    
    if exist "%OUTPUT_DIR%\%PORTABLE_NAME%" (
        copy /Y "%OUTPUT_DIR%\%PORTABLE_NAME%" release\
    ) else (
        echo WARNING: %OUTPUT_DIR%\%PORTABLE_NAME% not found. Skipping copy.
    )
) else if "%OUTPUT_TYPE%"=="single_executable" (
    REM Copy single executable
    if exist "%OUTPUT_DIR%\%EXECUTABLE_NAME%" (
        copy /Y "%OUTPUT_DIR%\%EXECUTABLE_NAME%" release\
    ) else (
        echo WARNING: %OUTPUT_DIR%\%EXECUTABLE_NAME% not found. Skipping copy.
    )
) else if "%OUTPUT_TYPE%"=="package" (
    REM Copy package file
    if exist "%OUTPUT_DIR%\%PACKAGE_NAME%" (
        copy /Y "%OUTPUT_DIR%\%PACKAGE_NAME%" release\
    ) else (
        echo WARNING: %OUTPUT_DIR%\%PACKAGE_NAME% not found. Skipping copy.
    )
) else if "%OUTPUT_TYPE%"=="library" (
    REM Copy library file
    if exist "%OUTPUT_DIR%\%LIBRARY_NAME%" (
        copy /Y "%OUTPUT_DIR%\%LIBRARY_NAME%" release\
    ) else (
        echo WARNING: %OUTPUT_DIR%\%LIBRARY_NAME% not found. Skipping copy.
    )
)

REM Copy documentation files
echo Copying documentation...
if exist README.md copy /Y README.md release\
if exist LICENSE copy /Y LICENSE release\
if exist CHANGELOG.md copy /Y CHANGELOG.md release\
if exist release-readme.txt copy /Y release-readme.txt release\README.txt

REM Create checksums
echo Generating checksums...
cd release

REM Generate checksums for all executables in the release directory
for %%F in (*.exe *.dll *.jar *.zip) do (
    if exist "%%F" (
        echo Creating checksum for %%F...
        certutil -hashfile "%%F" SHA256 > "%%F.sha256"
    )
)

REM Sign files if enabled
if /i "%ENABLE_SIGNING%"=="true" (
    if "%GPG_KEY_ID%"=="YOUR_GPG_KEY_ID" (
        echo WARNING: GPG key ID not configured. Set GPG_KEY_ID in config.bat to enable signing.
    ) else (
        echo Signing release artifacts with GPG key %GPG_KEY_ID%...
        
        REM Sign all executable files
        for %%F in (*.exe *.dll *.jar *.zip) do (
            if exist "%%F" (
                echo Signing %%F...
                gpg --batch --yes --default-key %GPG_KEY_ID% --detach-sign "%%F"
                if !ERRORLEVEL! neq 0 (
                    echo WARNING: GPG signing failed for %%F. Make sure GPG is installed and the key is available.
                )
            )
        )
    )
) else (
    echo GPG signing disabled in configuration.
)

REM Create verification instructions
echo Creating verification instructions...
echo %PROJECT_NAME% Release Verification Instructions > VERIFY.txt
echo ===================================== >> VERIFY.txt
echo. >> VERIFY.txt

if /i "%ENABLE_SIGNING%"=="true" (
    echo 1. To verify the GPG signature: >> VERIFY.txt
    
    for %%F in (*.exe *.dll *.jar *.zip) do (
        if exist "%%F.sig" (
            echo    gpg --verify "%%F.sig" "%%F" >> VERIFY.txt
        )
    )
    echo. >> VERIFY.txt
)

echo 2. To verify the SHA256 checksum: >> VERIFY.txt
for %%F in (*.exe *.dll *.jar *.zip) do (
    if exist "%%F.sha256" (
        echo    certutil -hashfile "%%F" SHA256 >> VERIFY.txt
        echo    Compare the output with the contents of "%%F.sha256" >> VERIFY.txt
    )
)
echo. >> VERIFY.txt

if /i "%ENABLE_SIGNING%"=="true" (
    if not "%GPG_KEY_ID%"=="YOUR_GPG_KEY_ID" (
        echo 3. Public key information: >> VERIFY.txt
        echo    Key ID: %GPG_KEY_ID% >> VERIFY.txt
        if defined DEVELOPER_NAME echo    Key user: %DEVELOPER_NAME% >> VERIFY.txt
        if defined DEVELOPER_EMAIL echo    Key email: %DEVELOPER_EMAIL% >> VERIFY.txt
        echo. >> VERIFY.txt
        echo 4. Import the public key: >> VERIFY.txt
        echo    gpg --keyserver keyserver.ubuntu.com --recv-keys %GPG_KEY_ID% >> VERIFY.txt
        echo. >> VERIFY.txt
        
        REM Export public key for users
        echo Exporting public key...
        gpg --armor --export %GPG_KEY_ID% > %GPG_KEY_ID%-public-key.asc
    )
)

cd ..

REM Create the ZIP file
echo Creating ZIP archive...
set RELEASE_PACKAGE=%PROJECT_NAME%-%NEW_VERSION%-Release.zip
powershell -Command "Compress-Archive -Path 'release\*' -DestinationPath '%RELEASE_PACKAGE%' -Force"

echo.
echo ===== Release package created successfully! =====
echo Package location: %CD%\%RELEASE_PACKAGE%
echo.
echo This package contains:
echo - %PROJECT_NAME% release artifacts
if /i "%ENABLE_SIGNING%"=="true" echo - GPG signatures (.sig files)
echo - SHA256 checksums
echo - Verification instructions
echo - README files
if /i "%ENABLE_SIGNING%"=="true" if not "%GPG_KEY_ID%"=="YOUR_GPG_KEY_ID" echo - Developer public key for verification

endlocal
