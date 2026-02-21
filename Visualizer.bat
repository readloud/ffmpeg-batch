@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

::Check tools
where ffmpeg >nul 2>nul || echo [WARNING] FFmpeg not installed!
where yt-dlp >nul 2>nul || echo [WARNING] yt-dlp not installed!
timeout /t 2 >nul

::========================================
::DEFAULT SYSTEM FOLDERS ONLY
::========================================
set "MUSIC_DIR=%USERPROFILE%\Music"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter"
set "TEMP_DIR=%TEMP%\YT_Converter"
set "ASSETS_DIR=assets"

:: Check if assets directory exists locally
if not exist "%ASSETS_DIR%" (
    echo ⚠️ Assets directory not found! Creating...
    mkdir "%ASSETS_DIR%"
    echo Please add bg_loop.mp4 and banner.png to the assets folder.
    pause
    exit /b 1
)

:: Check if background video exists
if not exist "%ASSETS_DIR%\bg_loop.mp4" (
    echo ❌ Background video not found: %ASSETS_DIR%\bg_loop.mp4
    echo Please add a background video file.
    pause
    exit /b 1
) else (
    set "input_bg=%ASSETS_DIR%\bg_loop.mp4"
)

:: Check if banner image exists
if not exist "%ASSETS_DIR%\banner.png" (
    echo ⚠️ Banner image not found: %ASSETS_DIR%\banner.png
    echo Continuing without banner...
    set "USE_BANNER=0"
) else (
    set "USE_BANNER=1"
)

::Create folders
if not exist "%MUSIC_DIR%" mkdir "%MUSIC_DIR%"
if not exist "%PICTURES_DIR%" mkdir "%PICTURES_DIR%"
if not exist "%VIDEOS_DIR%" mkdir "%VIDEOS_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Font settings
set "FONT_FILE=Ritual of the Witch Regular"
set "FONT_NAME=Ritual of the Witch"

::========================================
::MAIN MENU
::========================================
:MAIN_MENU
cls
echo ========================================
echo    YOUTUBE DOWNLOADER CONVERTER PRO
echo         DEFAULT SYSTEM FOLDERS
echo ========================================
echo.
echo [1] Download Audio MP3
echo [2] Download + Convert Waveform
echo [3] Bulk Download from File
echo [4] Convert Existing MP3
echo [5] Mix Audio + Video
echo [6] Change Background Video
echo [7] System Info
echo [0] Exit
echo.
echo ----------------------------------------
echo MUSIC:    %MUSIC_DIR%
echo PICTURES: %PICTURES_DIR%
echo VIDEOS:   %VIDEOS_DIR%
echo OUTPUT:   %OUTPUT_DIR%
echo ----------------------------------------
echo.
set /p choice="Select menu [0-7]: "

if "%choice%"=="1" goto DOWNLOAD_AUDIO
if "%choice%"=="2" goto DOWNLOAD_WAVEFORM
if "%choice%"=="3" goto BULK_DOWNLOAD
if "%choice%"=="4" goto CONVERT_WAVEFORM
if "%choice%"=="5" goto ADD_AUDIO_VIDEO
if "%choice%"=="6" goto CHANGE_BACKGROUND
if "%choice%"=="7" goto SYSTEM_INFO
if "%choice%"=="0" goto EXIT

echo Invalid choice!
pause
goto MAIN_MENU

::========================================
::CHANGE BACKGROUND VIDEO
::========================================
:CHANGE_BACKGROUND
cls
echo ========================================
echo        CHANGE BACKGROUND VIDEO
echo ========================================
echo.
echo Current background: %input_bg%
echo.
call :SELECT_BACKGROUND
if "!errorlevel!"=="1" goto MAIN_MENU
echo.
echo Background updated to: %input_bg%
pause
goto MAIN_MENU

:INPUT_METHOD
cls
echo Music Factory Visualizer [Batch Version]
echo ==========================================
echo MUSIC:    %MUSIC_DIR%
echo PICTURES: %PICTURES_DIR%
echo VIDEOS:   %VIDEOS_DIR%
echo OUTPUT:   %OUTPUT_DIR%
echo ==========================================
echo 1. YouTube (1920x1080)
echo 2. TikTok/Shorts (1080x1920)
echo 3. Exit
echo ==========================================
set /p choice="Select Format (1 - 3): "
if "%choice%"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
)

if "%choice%"=="1" (
    set "FORMAT=YT"
    set "WIDTH=1920"
    set "HEIGHT=1080"
    set "WAVE_HEIGHT=100"
    set "FONT_SIZE_TITLE=72"
    set "FONT_SIZE_SUB=36"
) else if "%choice%"=="2" (
    set "FORMAT=Shorts"
    set "WIDTH=1080"
    set "HEIGHT=1920"
    set "WAVE_HEIGHT=100"
    set "FONT_SIZE_TITLE=60"
    set "FONT_SIZE_SUB=30"
) else (
    echo ❌ Invalid choice! Please select 1, 2, or 3.
    timeout /t 2 /nobreak >nul
    goto :INPUT_METHOD
)
exit /b

::========================================
::FILE DISPLAY FUNCTIONS - DOES NOT MODIFY FILES
::========================================
:SHOW_MUSIC
cls
echo ========================================
echo        MUSIC FOLDER - DEFAULT
echo ========================================
echo %MUSIC_DIR%
echo.
echo MP3 FILE LIST:
echo ----------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3" "%MUSIC_DIR%\*.opus") do (
    if exist "%%f" (
        set /a m+=1
        echo [!m!] %%~nxf
        set "mp3_!m!=%%f"
        set "mp3_name_!m!=%%~nxf"
    )
)
if %m%==0 echo (No MP3 files yet)
echo ========================================
echo Total: %m% file(s)
echo.
echo [0] Back to Main Menu
echo.
exit /b %m%

:SHOW_PICTURES
cls
echo ========================================
echo      PICTURES FOLDER - DEFAULT
echo ========================================
echo %PICTURES_DIR%
echo.
echo IMAGE FILE LIST:
echo ----------------------------------------
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png" "%PICTURES_DIR%\*.webp" "%PICTURES_DIR%\*.jfif") do (
    if exist "%%f" (
        set /a p+=1
        echo [!p!] %%~nxf
        set "img_!p!=%%f"
        set "img_name_!p!=%%~nxf"
    )
)
if %p%==0 echo (No image files yet)
echo ========================================
echo Total: %p% file(s)
echo.
echo [0] Back to Image Selection Menu
echo.
exit /b %p%

:SHOW_VIDEOS
cls
echo ========================================
echo      VIDEOS FOLDER - DEFAULT
echo ========================================
echo %VIDEOS_DIR%
echo.
echo VIDEO FILE LIST:
echo ----------------------------------------
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov" "%VIDEOS_DIR%\*.wma") do (
    if exist "%%f" (
        set /a v+=1
        echo [!v!] %%~nxf
        set "video_!v!=%%f"
        set "video_name_!v!=%%~nxf"
    )
)
if %v%==0 echo (No video files yet)
echo ========================================
echo Total: %v% file(s)
echo.
echo [0] Back to Main Menu
echo.
exit /b %v%

:SHOW_OUTPUT
cls
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
echo %OUTPUT_DIR%
echo.
echo OUTPUT FILE LIST:
echo ----------------------------------------
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
    )
)
if %o%==0 echo (No output files yet)
echo ========================================
echo Total: %o% file(s)
echo.
echo [0] Back to Main Menu
echo.
exit /b 0

::========================================
::WAVEFORM STYLE SELECT FUNCTION
::========================================
:WAVEFORM_STYLE_SELECT
cls
echo =========================================
echo       FFMPEG WAVEFORM STYLE SELECTOR
echo =========================================
echo 1. CIRCULARWAVE             13. PURPLE LINE
echo 2. CIRCULARWAVE STATIC      14. SPLIT CHANNEL
echo 3. SCALE LOG                 15. PINK GLOW
echo 4. SCALEC BRT                16. BLUE LINE
echo 5. MODES QRT                 17. WHITE CLINE
echo 6. MODES P2P                 18. CYAN LINE2
echo 7. MODES LINE                19. YELLOW POINT
echo 8. MODES CLINE               20. CYAN MAGENTA HEX
echo 9. DRAWFULL                  21. RED BLUE CLINE
echo 10. SPECTRUM                 22. GREEN P2P
echo 11. CYAN MAGENTA LINE        23. WHITE CLINE(BLUR)
echo 12. CYAN LINE                24. DEFAULT 
echo =========================================
set /p wave_style="Select Style (1-24): "

if "%wave_style%"=="0" exit /b 2
if "%wave_style%"=="" set wave_style=1
exit /b 0

::========================================
::CREATE WAVEFORM VIDEO FUNCTION
::========================================
:CREATE_WAVEFORM
set "input_mp3=%~1"
set "input_bg=%~2"
set "output_file=%~3"

echo.
echo Creating video with waveform...
echo Audio file: %input_mp3%
echo Background: %input_bg%
echo Output: %output_file%
echo.

::Validate files
if not exist "%input_mp3%" (
    echo [ERROR] Audio file not found: %input_mp3%
    exit /b 1
)

if not exist "%input_bg%" (
    echo [ERROR] Background file not found: %input_bg%
    exit /b 1
)

:: Set font path
set "TEMP_PATH=%CD%\%FONT_FILE%"
set "FONT_PATH=!TEMP_PATH:\=/!"
set "FONT_PATH=!FONT_PATH::=\:!"

echo Rendering video for !SAFE_TITLE!...

:: Check for selected logo
set "USE_LOGO=0"
if defined SELECTED_IMAGE (
    if exist "!SELECTED_IMAGE!" (
        set "logo=!SELECTED_IMAGE!"
        echo Using selected logo: !logo!
        set "USE_LOGO=1"
    ) else (
        echo Selected image not found, continuing without logo
        set "USE_LOGO=0"
    )
) else (
    echo No logo selected, continuing without logo
    set "USE_LOGO=0"
)

:: YouTube Horizontal Logic (default to YT if FORMAT not set)
if not defined FORMAT (
    set "FORMAT=YT"
    set "WIDTH=1920"
    set "HEIGHT=1080"
    set "WAVE_HEIGHT=100"
    set "FONT_SIZE_TITLE=72"
    set "FONT_SIZE_SUB=36"
)

:: Simple waveform filter (simplified for reliability)
set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=p2p:rate=25:colors=white@0.9[wave]"

:: YouTube format
if "%FORMAT%"=="YT" (
    if "!USE_LOGO!"=="1" (
        if "%USE_BANNER%"=="1" (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; %WAVEFORM_FILTER%; [bg_l][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        ) else (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "!logo!" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=100:-1[logo_s]; [bg][logo_s]overlay=W-w-10:10[bg_l]; %WAVEFORM_FILTER%; [bg_l][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 2:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        )
    ) else (
        if "%USE_BANNER%"=="1" (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%ASSETS_DIR%\banner.png" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; %WAVEFORM_FILTER%; [bg_w_banner][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 2:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        ) else (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; %WAVEFORM_FILTER%; [bg][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        )
    )
) else (
    :: TikTok format
    if "!USE_LOGO!"=="1" (
        if "%USE_BANNER%"=="1" (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; %WAVEFORM_FILTER%; [bg_l][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        ) else (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "!logo!" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=100:-1[logo_s]; [bg][logo_s]overlay=W-w-10:10[bg_l]; %WAVEFORM_FILTER%; [bg_l][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 2:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        )
    ) else (
        if "%USE_BANNER%"=="1" (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%ASSETS_DIR%\banner.png" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; %WAVEFORM_FILTER%; [bg_w_banner][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 2:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        ) else (
            ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
            -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,boxblur=10:5[bg]; %WAVEFORM_FILTER%; [bg][wave]overlay=0:H-h[bg_waves]; [bg_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
            -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
        )
    )
)

if !errorlevel! equ 0 (
    echo ✅ Successfully rendered: %output_file%
) else (
    echo ❌ Error rendering video for !SAFE_TITLE!
    echo FFmpeg error code: !errorlevel!
)
exit /b 0

:end
echo.
echo ==========================================
echo ✅ All videos rendered!
echo 📁 Check the output folder: %OUTPUT_DIR%
echo ==========================================
echo.
echo 1. Process another video
echo 2. Open output folder
echo 3. Exit
set /p end_choice="Select (1, 2, or 3): "

if "!end_choice!"=="1" (
    goto :MAIN_MENU
) else if "!end_choice!"=="2" (
    explorer "%OUTPUT_DIR%"
    timeout /t 2 /nobreak >nul
    goto :end
) else (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    exit /b 0
)

::========================================
::SELECT BACKGROUND VIDEO FUNCTION
::========================================
:SELECT_BACKGROUND
cls
echo Select Background Video
echo ==========================================
echo Choose background source:
echo 1. Use default bg_loop.mp4 from assets folder
echo 2. Select from Videos folder
echo 3. Back to previous menu
echo ==========================================
set /p bg_choice="Select (1-3): "

if "!bg_choice!"=="1" (
    if exist "%ASSETS_DIR%\bg_loop.mp4" (
        set "input_bg=%ASSETS_DIR%\bg_loop.mp4"
        echo Using default background: bg_loop.mp4
        timeout /t 2 >nul
        exit /b 0
    ) else (
        echo ❌ Default background not found in assets folder!
        echo Please add bg_loop.mp4 to the assets folder.
        timeout /t 3 >nul
        goto :SELECT_BACKGROUND
    )
) else if "!bg_choice!"=="2" (
    call :SHOW_VIDEOS_BG
    set "video_count=!errorlevel!"
    if !video_count!==0 (
        echo [ERROR] No video files in Videos folder!
        timeout /t 2 >nul
        goto :SELECT_BACKGROUND
    )
    goto :PICK_BACKGROUND
) else if "!bg_choice!"=="3" (
    exit /b 1
) else (
    echo ❌ Invalid choice!
    timeout /t 2 >nul
    goto :SELECT_BACKGROUND
)
exit /b 0

:SHOW_VIDEOS_BG
cls
echo ========================================
echo      VIDEOS FOLDER - SELECT BACKGROUND
echo ========================================
echo %VIDEOS_DIR%
echo.
echo VIDEO FILE LIST:
echo ----------------------------------------
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do (
    if exist "%%f" (
        set /a v+=1
        echo [!v!] %%~nxf
        set "bg_video_!v!=%%f"
        set "bg_video_name_!v!=%%~nxf"
    )
)
if %v%==0 echo (No video files yet)
echo ========================================
echo Total: %v% file(s)
echo.
echo [0] Back to Background Selection Menu
echo.
exit /b %v%

:PICK_BACKGROUND
echo.
set /p bg_number="Select background video number [0 to cancel]: "

if "!bg_number!"=="0" (
    echo Cancelled background selection.
    timeout /t 2 >nul
    goto :SELECT_BACKGROUND
)

set "selected_bg="
for /l %%i in (1,1,!v!) do (
    if "!bg_number!"=="%%i" set "selected_bg=!bg_video_%%i!"
)

if "!selected_bg!"=="" (
    echo Invalid choice! Please select a valid number.
    timeout /t 2 >nul
    goto :PICK_BACKGROUND
)

set "input_bg=!selected_bg!"
echo Using background: !input_bg!
timeout /t 2 >nul
exit /b 0

::========================================
::SELECT IMAGE AND BACKGROUND FUNCTION
::========================================
:SELECT_IMAGE
cls
echo Select Logo/Image and Background
echo ==========================================
echo Current background: %input_bg%
echo.
echo IMAGE OPTIONS:
echo 1. Use default logo from assets folder
echo 2. Select from Pictures folder
echo 3. No logo
echo.
echo BACKGROUND OPTIONS:
echo 4. Select different background video
echo 5. Reset to default background
echo.
echo 6. Back to Main Menu
echo ==========================================
set /p img_choice="Select (1-6): "

if "!img_choice!"=="1" (
    if exist "%ASSETS_DIR%\logo.png" (
        set "SELECTED_IMAGE=%ASSETS_DIR%\logo.png"
        echo Using default logo
        timeout /t 2 >nul
        goto :BACKGROUND_CHECK
    ) else (
        echo ❌ Default logo not found in assets folder!
        echo Please add logo.png to the assets folder.
        timeout /t 3 >nul
        goto :SELECT_IMAGE
    )
) else if "!img_choice!"=="2" (
    call :SHOW_PICTURES
    set "pic_count=!errorlevel!"
    if !pic_count!==0 (
        echo [ERROR] No image files in Pictures folder!
        timeout /t 2 >nul
        goto :SELECT_IMAGE
    )
    goto :PICK_IMAGE
) else if "!img_choice!"=="3" (
    set "SELECTED_IMAGE="
    echo No logo selected
    timeout /t 2 >nul
    goto :BACKGROUND_CHECK
) else if "!img_choice!"=="4" (
    call :SELECT_BACKGROUND
    if "!errorlevel!"=="1" goto :SELECT_IMAGE
    goto :SELECT_IMAGE
) else if "!img_choice!"=="5" (
    if exist "%ASSETS_DIR%\bg_loop.mp4" (
        set "input_bg=%ASSETS_DIR%\bg_loop.mp4"
        echo Reset to default background: bg_loop.mp4
        timeout /t 2 >nul
    ) else (
        echo ❌ Default background not found in assets folder!
        timeout /t 2 >nul
    )
    goto :SELECT_IMAGE
) else if "!img_choice!"=="6" (
    exit /b 1
) else (
    echo ❌ Invalid choice!
    timeout /t 2 >nul
    goto :SELECT_IMAGE
)
exit /b 0

:BACKGROUND_CHECK
echo.
echo Current background: %input_bg%
echo Do you want to change the background?
echo 1. Keep current background
echo 2. Select different background
echo 3. Reset to default background
echo.
set /p bg_change="Select (1-3): "

if "!bg_change!"=="1" (
    echo Keeping current background
    timeout /t 1 >nul
    exit /b 0
) else if "!bg_change!"=="2" (
    call :SELECT_BACKGROUND
    if "!errorlevel!"=="1" goto :BACKGROUND_CHECK
    exit /b 0
) else if "!bg_change!"=="3" (
    if exist "%ASSETS_DIR%\bg_loop.mp4" (
        set "input_bg=%ASSETS_DIR%\bg_loop.mp4"
        echo Reset to default background: bg_loop.mp4
        timeout /t 2 >nul
    ) else (
        echo ❌ Default background not found in assets folder!
        timeout /t 2 >nul
    )
    exit /b 0
) else (
    echo Invalid choice, keeping current background
    timeout /t 2 >nul
    exit /b 0
)

:PICK_IMAGE
echo.
set /p img_number="Select image number [0 to cancel]: "

if "!img_number!"=="0" (
    echo Cancelled image selection.
    timeout /t 2 >nul
    goto :SELECT_IMAGE
)

set "selected_img="
for /l %%i in (1,1,!p!) do (
    if "!img_number!"=="%%i" set "selected_img=!img_%%i!"
)

if "!selected_img!"=="" (
    echo Invalid choice! Please select a valid number.
    timeout /t 2 >nul
    goto :PICK_IMAGE
)

set "SELECTED_IMAGE=!selected_img!"
echo Using image: !SELECTED_IMAGE!
timeout /t 2 >nul
goto :BACKGROUND_CHECK

::========================================
::SELECT MP3 FUNCTION - REMAINS SAFE
::========================================
:SELECT_MP3
call :SHOW_MUSIC
set "mp3_count=!errorlevel!"
if !mp3_count!==0 (
    echo [ERROR] No MP3 files!
    echo.
    echo Press any key to return to Main Menu...
    pause >nul
    exit /b 1
)

:PICK_MP3
set /p mp3_choice="Select MP3 number [0 to cancel]: "

if "!mp3_choice!"=="0" (
    echo Cancelled MP3 selection.
    exit /b 2
)

set "selected_mp3="
for /l %%i in (1,1,!mp3_count!) do (
    if "!mp3_choice!"=="%%i" set "selected_mp3=!mp3_%%i!"
)

if "!selected_mp3!"=="" (
    echo Invalid choice!
    goto PICK_MP3
)

echo Using MP3: !selected_mp3!
exit /b 0

::========================================
::SELECT VIDEO FUNCTION - REMAINS SAFE
::========================================
:SELECT_VIDEO
call :SHOW_VIDEOS
set "video_count=!errorlevel!"
if !video_count!==0 (
    echo [ERROR] No video files!
    echo.
    echo Press any key to return to Main Menu...
    pause >nul
    exit /b 1
)

:PICK_VIDEO
set /p video_choice="Select video number [0 to cancel]: "

if "!video_choice!"=="0" (
    echo Cancelled video selection.
    exit /b 2
)

set "selected_video="
for /l %%i in (1,1,!video_count!) do (
    if "!video_choice!"=="%%i" set "selected_video=!video_%%i!"
)

if "!selected_video!"=="" (
    echo Invalid choice!
    goto PICK_VIDEO
)

echo Using video: !selected_video!
exit /b 0

::========================================
::MENU 1 - DOWNLOAD AUDIO MP3
::========================================
:DOWNLOAD_AUDIO
cls
echo ========================================
echo        DOWNLOAD AUDIO MP3
echo ========================================
echo.
echo [0] Back to Main Menu
echo.
set /p url="Enter YouTube URL: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_AUDIO

::Sanitize input
set "url=!url:"=!"

echo.
echo Downloading audio to: %MUSIC_DIR%
echo.
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
) else (
    echo [SUCCESS] Download complete!
    echo File saved to: %MUSIC_DIR%
    call :SHOW_MUSIC
)
pause
goto MAIN_MENU

::========================================
::MENU 2 - DOWNLOAD + CONVERT WITH IMAGE + WAVEFORM
::========================================
:DOWNLOAD_WAVEFORM
cls
echo ========================================
echo    DOWNLOAD + CONVERT WITH WAVEFORM
echo ========================================
echo.
echo [0] Back to Main Menu
echo.
set /p url="Enter YouTube URL: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_WAVEFORM

::Sanitize input
set "url=!url:"=!"
set "youtube_url=!url!"

echo [1/3] Fetching Metadata from YouTube...
yt-dlp --print "title" "%youtube_url%" > title.txt 2>nul
set /p SAFE_TITLE=<title.txt 2>nul
if "!SAFE_TITLE!"=="" set "SAFE_TITLE=Unknown_Title"
del title.txt 2>nul

:: Create filters
set "track_filters='ReadLoud Music Compilation':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"

::Select image
call :SELECT_IMAGE
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto DOWNLOAD_WAVEFORM
if "!gambar_exit!"=="0" (
    echo Proceeding with selected image...
)

::Select format
call :INPUT_METHOD

::Select waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" goto MAIN_MENU

::Download audio
echo.
echo Downloading audio...
set "temp_audio=%TEMP_DIR%\temp_waveform_%random%.mp3"
echo Downloading to: !temp_audio!
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
    pause
    goto DOWNLOAD_WAVEFORM
)

:: Verify file was downloaded
if not exist "!temp_audio!" (
    echo [ERROR] Downloaded file not found!
    pause
    goto DOWNLOAD_WAVEFORM
) else (
    echo [SUCCESS] Audio downloaded successfully!
)

::Create output filename
set "output_file=%OUTPUT_DIR%\!SAFE_TITLE!_%FORMAT%.mp4"

::Create waveform video
call :CREATE_WAVEFORM "!temp_audio!" "%input_bg%" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Failed to create video!
) else (
    echo [SUCCESS] Video complete!
    echo File saved to: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)

::Cleanup - ONLY delete temporary files
del "!temp_audio!" 2>nul
pause
goto MAIN_MENU

::========================================
::MENU 4 - CONVERT EXISTING MP3 + IMAGE + WAVEFORM
::========================================
:CONVERT_WAVEFORM
cls
echo ========================================
echo    CONVERT MP3 + IMAGE + WAVEFORM
echo ========================================

::Select MP3
call :SELECT_MP3
set "mp3_exit=!errorlevel!"
if "!mp3_exit!"=="1" goto MAIN_MENU
if "!mp3_exit!"=="2" goto CONVERT_WAVEFORM

::Select image
call :SELECT_IMAGE
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto CONVERT_WAVEFORM
if "!gambar_exit!"=="0" (
    echo Proceeding with selected image...
)

::Get filename
for %%f in ("!selected_mp3!") do set "SAFE_TITLE=%%~nf"

:: Create simple filter for local files
set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"

::Select format
call :INPUT_METHOD

::Select waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" goto MAIN_MENU

::Create output filename
set "output_file=%OUTPUT_DIR%\!SAFE_TITLE!_%FORMAT%.mp4"

::Create waveform video
call :CREATE_WAVEFORM "!selected_mp3!" "%input_bg%" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Failed to create video!
) else (
    echo [SUCCESS] Video complete!
    echo File saved to: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

::========================================
::MENU 5 - ADD AUDIO TO VIDEO
::========================================
:ADD_AUDIO_VIDEO
cls
echo ========================================
echo        ADD AUDIO TO VIDEO
echo ========================================

::Select video
call :SELECT_VIDEO
set "video_exit=!errorlevel!"
if "!video_exit!"=="1" goto MAIN_MENU
if "!video_exit!"=="2" goto ADD_AUDIO_VIDEO

::Select MP3
call :SELECT_MP3
set "mp3_exit=!errorlevel!"
if "!mp3_exit!"=="1" goto MAIN_MENU
if "!mp3_exit!"=="2" goto ADD_AUDIO_VIDEO

echo.
echo [1] Replace audio (remove original audio)
echo [2] Mix with original (mix with original audio)
echo [0] Cancel
echo.
set /p mix="Select [0-2]: "

if "!mix!"=="0" goto ADD_AUDIO_VIDEO
if "!mix!"=="1" (
    set "mix_mode=replace"
) else if "!mix!"=="2" (
    set "mix_mode=mix"
) else (
    echo Invalid choice!
    pause
    goto ADD_AUDIO_VIDEO
)

for %%f in ("!selected_video!") do set "filename=%%~nf"
set "output_file=%OUTPUT_DIR%\!filename!_mixed_%random%.mp4"

echo.
echo Processing audio mixing...
if "!mix_mode!"=="replace" (
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest -y "!output_file!"
) else (
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -filter_complex "[0:a][1:a]amix=inputs=2:duration=first" -c:v copy -c:a aac -y "!output_file!"
)

if errorlevel 1 (
    echo [ERROR] Failed to process audio!
) else (
    echo [SUCCESS] Video complete!
    echo File saved to: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

::========================================
::MENU 3 - BULK DOWNLOAD FROM FILE
::========================================
:BULK_DOWNLOAD
setlocal enabledelayedexpansion
cls
echo ========================================
echo         BULK DOWNLOAD FROM FILE
echo ========================================
echo.
echo Searching for TXT files in: %CD%
echo.

::1. Reset Counter & Clear Memory
set "idx=0"
for /f "tokens=1 delims==" %%v in ('set urlfile_ 2^>nul') do set "%%v="

::2. Scan Files (Only show files containing YT links)
for %%f in (*.txt) do (
    findstr /i "youtube.com youtu.be" "%%f" >nul 2>nul
    if !errorlevel! equ 0 (
        set /a idx+=1
        set "urlfile_!idx!=%%f"
        echo [!idx!] %%f
    )
)

if %idx%==0 (
    echo [ERROR] No .txt file containing YouTube URLs found!
    pause
    endlocal & goto MAIN_MENU
)

echo.
echo [0] Back to Main Menu
set /p "file_choice=Select file number: "
if "!file_choice!"=="0" (endlocal & goto MAIN_MENU)

::Get selected file
set "selected_urlfile=!urlfile_%file_choice%!"
if "!selected_urlfile!"=="" (
    echo Invalid choice!
    pause
    endlocal & goto BULK_DOWNLOAD
)

cls
echo ========================================
echo FILE: !selected_urlfile!
echo ========================================
echo [1] Download MP3 Only (320kbps)
echo [2] Download + Waveform (MP4)
echo [3] Download Original Video (Best Quality MP4)
echo [0] Cancel
echo ----------------------------------------
set /p "bulk_type=Select Format [0-3]: "

if "!bulk_type!"=="0" (endlocal & goto BULK_DOWNLOAD)

::3. Prepare variables based on choice
if "!bulk_type!"=="1" (
    set "proses_type=audio"
) else if "!bulk_type!"=="2" (
    set "proses_type=waveform"
    call :SELECT_IMAGE
    if "!errorlevel!"=="1" (endlocal & goto MAIN_MENU)
    if "!errorlevel!"=="2" (endlocal & goto BULK_DOWNLOAD)
    set "bulk_img=!SELECTED_IMAGE!"
    call :WAVEFORM_STYLE_SELECT
    call :INPUT_METHOD
) else if "!bulk_type!"=="3" (
    set "proses_type=video_asli"
) else (
    echo Invalid choice!
    pause
    endlocal & goto BULK_DOWNLOAD
)

echo.
echo Processing bulk download...
echo ========================================

set "total=0"
set "success=0"
set "failed=0"

for /f "usebackq delims=" %%u in ("!selected_urlfile!") do (
    set /a total+=1
    
    ::Get Video Title
    for /f "delims=" %%t in ('yt-dlp --get-filename --restrict-filenames -o "%%(title)s" "%%u" 2^>nul') do set "SAFE_TITLE=%%t"
    if "!SAFE_TITLE!"=="" set "SAFE_TITLE=Unknown_!total!"
    
    echo [!total!] !SAFE_TITLE!

    if "!proses_type!"=="audio" (
        yt-dlp -x --audio-format mp3 --audio-quality 320k --restrict-filenames -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            echo    [OK] Success.
            set /a success+=1
        ) else (
            echo    [FAILED] Download error.
            set /a failed+=1
        )
    ) else if "!proses_type!"=="waveform" (
        set "temp_audio=!TEMP_DIR!\tmp_!random!.mp3"
        echo Downloading to: !temp_audio!
        yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            if exist "!temp_audio!" (
                set "output_file=!OUTPUT_DIR!\!SAFE_TITLE!_%FORMAT%.mp4"
                set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"
                call :CREATE_WAVEFORM "!temp_audio!" "%input_bg%" "!output_file!"
                if !errorlevel! equ 0 (
                    echo    [OK] Success.
                    set /a success+=1
                ) else (
                    echo    [FAILED] Video creation failed.
                    set /a failed+=1
                )
                del "!temp_audio!" 2>nul
            ) else (
                echo    [FAILED] Downloaded file not found.
                set /a failed+=1
            )
        ) else (
            echo    [FAILED] Download error.
            set /a failed+=1
        )
    ) else if "!proses_type!"=="video_asli" (
        ::DOWNLOAD ORIGINAL VIDEO (Best MP4)
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --restrict-filenames -o "%OUTPUT_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            echo    [OK] Success.
            set /a success+=1
        ) else (
            echo    [FAILED] Download error.
            set /a failed+=1
        )
    )
)

echo.
echo ========================================
echo COMPLETE! Successful: !success! ^| Failed: !failed!
echo ========================================
pause
endlocal
goto MAIN_MENU

::========================================
::MENU 7 - SYSTEM INFORMATION
::========================================
:SYSTEM_INFO
cls
echo ========================================
echo         SYSTEM INFORMATION
echo ========================================
echo.
echo [DEFAULT SYSTEM FOLDERS]
echo ----------------------------------------
echo Music    : %MUSIC_DIR%
echo Pictures : %PICTURES_DIR%
echo Videos   : %VIDEOS_DIR%
echo Output   : %OUTPUT_DIR%
echo.
echo [FOLDER STATUS]
echo ----------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3") do set /a m+=1
echo Music    : %m% MP3 files

set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do set /a p+=1
echo Pictures : %p% image files

set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do set /a v+=1
echo Videos   : %v% video files

set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do set /a o+=1
echo Output   : %o% output files
echo.
echo [INSTALLED TOOLS]
echo ----------------------------------------
where ffmpeg >nul 2>nul && echo FFmpeg   : INSTALLED || echo FFmpeg   : NOT FOUND
where yt-dlp >nul 2>nul && echo yt-dlp   : INSTALLED || echo yt-dlp   : NOT FOUND
echo.
echo [NOTE]
echo ----------------------------------------
echo - Original MP3 files are NEVER deleted
echo - Image files are NEVER modified/deleted
echo - Video files are NEVER deleted
echo - Only temporary files are cleaned up
echo.
echo [0] Back to Main Menu
echo.
set /p "back=Press 0 to return: "
if "!back!"=="0" goto MAIN_MENU
pause
goto MAIN_MENU

::========================================
::EXIT
::========================================
:EXIT
cls
echo ========================================
echo     THANK YOU FOR USING
echo    YOUTUBE DOWNLOADER CONVERTER PRO
echo ========================================
echo.
echo Cleaning up temporary files...
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" 2>nul
    echo Temporary files cleaned up.
) else (
    echo No temporary files.
)
echo.
echo [INFO] Your MP3, Image, Video files are SAFE
echo [INFO] All original files remain untouched
echo.
echo Goodbye!
timeout /t 5 >nul

::Clear environment and exit
endlocal
exit /b 0