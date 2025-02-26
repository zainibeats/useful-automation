@echo off
setlocal enabledelayedexpansion

echo ===== ez-release Setup Tool =====
echo This tool will copy the ez-release toolkit to your project.

:input_project
echo.
set /p PROJECT_DIR=Enter the path to your project directory: 

if not exist "%PROJECT_DIR%" (
    echo ERROR: The specified directory does not exist.
    goto input_project
)

echo.
echo Will copy ez-release toolkit to: %PROJECT_DIR%\ez-release
echo.
set /p CONFIRM=Proceed? (Y/N): 

if /i not "%CONFIRM%"=="Y" (
    echo Setup canceled.
    goto end
)

echo.
echo Copying ez-release toolkit to your project...
xcopy /E /I /Y "%~dp0*.*" "%PROJECT_DIR%\ez-release\"

echo.
echo Creating default configuration...
copy "%PROJECT_DIR%\ez-release\config.bat" "%PROJECT_DIR%\ez-release\config.bat.example"

echo.
echo Setup completed successfully!
echo.
echo NEXT STEPS:
echo 1. Edit the config.bat file in your project's ez-release directory
echo 2. Uncomment the section for your programming language
echo 3. Set your project details and preferences
echo 4. Run 'release.bat' to create your first release
echo.
echo See the README.md file for detailed instructions.

:end
endlocal
