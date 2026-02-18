@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
:: DEFAULT SYSTEM FOLDERS ONLY
:: ========================================
set "MUSIC_DIR=%USERPROFILE%\Music"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter"
set "TEMP_DIR=%TEMP%\YT_Converter"

:: Create folders
if not exist "%MUSIC_DIR%" mkdir "%MUSIC_DIR%"
if not exist "%PICTURES_DIR%" mkdir "%PICTURES_DIR%"
if not exist "%VIDEOS_DIR%" mkdir "%VIDEOS_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Check tools
where ffmpeg >nul 2>nul || echo [WARNING] FFmpeg not installed!
where yt-dlp >nul 2>nul || echo [WARNING] yt-dlp not installed!
timeout /t 2 >nul

:: ========================================
:: MAIN MENU
:: ========================================
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
echo [6] System Info
echo [0] Exit
echo.
echo ----------------------------------------
echo MUSIC:    %MUSIC_DIR%
echo PICTURES: %PICTURES_DIR%
echo VIDEOS:   %VIDEOS_DIR%
echo OUTPUT:   %OUTPUT_DIR%
echo ----------------------------------------
echo.
set /p choice="Select menu [0-6]: "

if "%choice%"=="1" goto DOWNLOAD_AUDIO
if "%choice%"=="2" goto DOWNLOAD_WAVEFORM
if "%choice%"=="3" goto BULK_DOWNLOAD
if "%choice%"=="4" goto CONVERT_WAVEFORM
if "%choice%"=="5" goto ADD_AUDIO_VIDEO
if "%choice%"=="6" goto SYSTEM_INFO
if "%choice%"=="0" goto EXIT

echo Invalid choice!
pause
goto MAIN_MENU

:: ========================================
:: FILE DISPLAY FUNCTION - DOES NOT MODIFY FILES
:: ========================================
:SHOW_MUSIC
cls
echo ========================================
echo        MUSIC FOLDER - DEFAULT
echo ========================================
echo %MUSIC_DIR%
echo.
echo LIST OF MP3 FILES:
echo ----------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3") do (
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
exit /b 0

:SHOW_PICTURES
cls
echo ========================================
echo      PICTURES FOLDER - DEFAULT
echo ========================================
echo %PICTURES_DIR%
echo.
echo LIST OF IMAGE FILES:
echo ----------------------------------------
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do (
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
echo [0] Back to Main Menu
echo.
exit /b 0

:SHOW_VIDEOS
cls
echo ========================================
echo      VIDEOS FOLDER - DEFAULT
echo ========================================
echo %VIDEOS_DIR%
echo.
echo LIST OF VIDEO FILES:
echo ----------------------------------------
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do (
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
exit /b 0

:SHOW_OUTPUT
cls
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
echo %OUTPUT_DIR%
echo.
echo LIST OF OUTPUT FILES:
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

:: ========================================
:: FUNCTION TO SELECT WAVEFORM STYLE
:: ========================================
:WAVEFORM_STYLE_SELECT
cls
echo =========================================
echo       FFMPEG WAVEFORM STYLE SELECTOR
echo =========================================
echo [ SOLID BACKGROUNDS ]
echo 1. Black - White Cline          5. Black - Red/Blue Cline
echo 2. Black - Cyan Line            6. Black - Green P2P
echo 3. Black - Yellow Point         7. Black - White Cline (Blur)
echo 4. Blue  - White Cline          8. Black - Cyan/Magenta Hex
echo.
echo [ IMAGE BACKGROUNDS ]
echo 9.  White Cline                 13. Red/Blue Cline
echo 10. Cyan Line                   14. Green P2P
echo 11. Yellow Point                15. White Cline (Blur)
echo 12. Cyan/Magenta Hex
echo =========================================
set /p wave_style="Select Style (1-15): "

if "%wave_style%"=="0" exit /b 2
if "%wave_style%"=="" set wave_style=1
exit /b 0

:: ========================================
:: FUNCTION TO CREATE WAVEFORM VIDEO
:: ========================================
:CREATE_WAVEFORM
set "input_img=%~1"
set "input_mp3=%~2"
set "output_file=%~3"

echo.
echo Creating video with waveform...
echo Style: %wave_style%
echo Resolution: 1280x720
echo.

:: Validate files
if not exist "%input_mp3%" (
    echo [ERROR] Audio file not found!
    exit /b 1
)
if not exist "%input_img%" (
    echo [ERROR] Image file not found!
    exit /b 1
)

:: Apply waveform style based on choice
:: Solid Background Logic (Styles 1-8)
if %wave_style% equ 1 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 2 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=line:rate=25:colors=cyan[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 3 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=yellow[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 4 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=blue:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 5 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=red|blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 6 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=p2p:rate=25:colors=green[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 7 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1,boxblur=2:1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 8 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)

:: Image Background Logic (Styles 9-15)
if %wave_style% equ 9 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 10 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=line:rate=25:colors=cyan[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 11 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=yellow[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 12 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 13 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=red|blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 14 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=p2p:rate=25:colors=green[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 15 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1,boxblur=2:1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)

:WAVEFORM_DONE
if errorlevel 1 (
    echo [ERROR] Failed to create waveform video!
    exit /b 1
) else (
    echo [SUCCESS] Video created successfully!
    exit /b 0
)

:: ========================================
:: FUNCTION TO SELECT IMAGE - STAYS SAFE
:: ========================================
:PILIH_GAMBAR
call :SHOW_PICTURES
if %p%==0 (
    echo [ERROR] No image files available!
    echo.
    echo Press any key to return to Main Menu...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_GAMBAR
set /p img_choice="Select image number [0 to cancel]: "

if "!img_choice!"=="0" (
    echo Cancelled image selection.
    exit /b 2
)

set "selected_img="
for /l %%i in (1,1,%p%) do (
    if "!img_choice!"=="%%i" set "selected_img=!img_%%i!"
)

if "!selected_img!"=="" (
    echo Invalid choice!
    goto ULANG_PILIH_GAMBAR
)

echo Using image: !selected_img!
exit /b 0

:: ========================================
:: FUNCTION TO SELECT MP3 - STAYS SAFE
:: ========================================
:PILIH_MP3
call :SHOW_MUSIC
if %m%==0 (
    echo [ERROR] No MP3 files available!
    echo.
    echo Press any key to return to Main Menu...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_MP3
set /p mp3_choice="Select MP3 number [0 to cancel]: "

if "!mp3_choice!"=="0" (
    echo Cancelled MP3 selection.
    exit /b 2
)

set "selected_mp3="
for /l %%i in (1,1,%m%) do (
    if "!mp3_choice!"=="%%i" set "selected_mp3=!mp3_%%i!"
)

if "!selected_mp3!"=="" (
    echo Invalid choice!
    goto ULANG_PILIH_MP3
)

echo Using MP3: !selected_mp3!
exit /b 0

:: ========================================
:: FUNCTION TO SELECT VIDEO - STAYS SAFE
:: ========================================
:PILIH_VIDEO
call :SHOW_VIDEOS
if %v%==0 (
    echo [ERROR] No video files available!
    echo.
    echo Press any key to return to Main Menu...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_VIDEO
set /p video_choice="Select video number [0 to cancel]: "

if "!video_choice!"=="0" (
    echo Cancelled video selection.
    exit /b 2
)

set "selected_video="
for /l %%i in (1,1,%v%) do (
    if "!video_choice!"=="%%i" set "selected_video=!video_%%i!"
)

if "!selected_video!"=="" (
    echo Invalid choice!
    goto ULANG_PILIH_VIDEO
)

echo Using video: !selected_video!
exit /b 0

:: ========================================
:: MENU 1 - DOWNLOAD AUDIO MP3
:: ========================================
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

:: Sanitize input
set "url=!url:"=!"

echo.
echo Downloading audio to: %MUSIC_DIR%
echo.
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
) else (
    echo [SUCCESS] Download complete!
    echo File saved in: %MUSIC_DIR%
    call :SHOW_MUSIC
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 2 - DOWNLOAD + CONVERT WITH IMAGE + WAVEFORM
:: ========================================
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

:: Sanitize input
set "url=!url:"=!"

:: Select image
call :PILIH_GAMBAR
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto DOWNLOAD_WAVEFORM

:: Download audio
echo.
echo Downloading audio...
set "temp_audio=%TEMP_DIR%\temp_waveform_%random%.mp3"
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
    pause
    goto DOWNLOAD_WAVEFORM
)

:: Get video title
set "title=video_%random%"
for /f "delims=" %%i in ('yt-dlp --get-filename -o "%%(title)s" "!url!" 2^>nul') do set "title=%%i"
if "!title!"=="" set "title=video_!random!"

:: Select waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" (
    del "!temp_audio!" 2>nul
    goto MAIN_MENU
)

:: Create output filename
set "output_file=%OUTPUT_DIR%\!title!_%wave_style%_%random%.mp4"

:: Create waveform video
call :CREATE_WAVEFORM "!selected_img!" "!temp_audio!" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Failed to create video!
) else (
    echo [SUCCESS] Video complete!
    echo File saved in: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)

:: Cleanup - ONLY delete temporary files
del "!temp_audio!" 2>nul
pause
goto MAIN_MENU

:: ========================================
:: MENU 3 - CONVERT EXISTING MP3 + IMAGE + WAVEFORM
:: ========================================
:CONVERT_WAVEFORM
cls
echo ========================================
echo    CONVERT MP3 + IMAGE + WAVEFORM
echo ========================================

:: Select MP3
call :PILIH_MP3
set "mp3_exit=!errorlevel!"
if "!mp3_exit!"=="1" goto MAIN_MENU
if "!mp3_exit!"=="2" goto CONVERT_WAVEFORM

:: Select image
call :PILIH_GAMBAR
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto CONVERT_WAVEFORM

:: Get filename
for %%f in ("!selected_mp3!") do set "filename=%%~nf"

:: Select waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" goto MAIN_MENU

:: Create output filename
set "output_file=%OUTPUT_DIR%\!filename!_waveform_%random%.mp4"

:: Create waveform video
call :CREATE_WAVEFORM "!selected_img!" "!selected_mp3!" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Failed to create video!
) else (
    echo [SUCCESS] Video complete!
    echo File saved in: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 4 - ADD AUDIO TO VIDEO
:: ========================================
:ADD_AUDIO_VIDEO
cls
echo ========================================
echo        ADD AUDIO TO VIDEO
echo ========================================

:: Select video
call :PILIH_VIDEO
set "video_exit=!errorlevel!"
if "!video_exit!"=="1" goto MAIN_MENU
if "!video_exit!"=="2" goto ADD_AUDIO_VIDEO

:: Select MP3
call :PILIH_MP3
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
    echo File saved in: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 5 - BULK DOWNLOAD FROM FILE
:: ========================================
:BULK_DOWNLOAD
setlocal Enabledelayedexpansion
cls
echo ========================================
echo         BULK DOWNLOAD FROM FILE
echo ========================================
echo.
echo Searching for TXT files in: %CD%
echo.

:: 1. Reset Counter & Clear Memory
set "idx=0"
for /f "tokens=1 delims==" %%v in ('set urlfile_ 2^>nul') do set "%%v="

:: 2. Scan Files (Only show files containing YT links)
for %%f in (*.txt) do (
    findstr /i "youtube.com youtu.be" "%%f" >nul 2>nul
    if !errorlevel! equ 0 (
        set /a idx+=1
        set "urlfile_!idx!=%%f"
        echo [!idx!] %%f
    )
)

if %idx%==0 (
    echo [ERROR] No .txt files containing YouTube URLs found!
    pause
    endlocal & goto MAIN_MENU
)

echo.
echo [0] Back to Main Menu
set /p "file_choice=Select file number: "
if "!file_choice!"=="0" (endlocal & goto MAIN_MENU)

:: Get selected file
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

:: 3. Prepare variables based on choice
if "!bulk_type!"=="1" (
    set "proses_type=audio"
) else if "!bulk_type!"=="2" (
    set "proses_type=waveform"
    call :PILIH_GAMBAR
    if "!errorlevel!"=="1" (endlocal & goto MAIN_MENU)
    set "bulk_img=!selected_img!"
    call :WAVEFORM_STYLE_SELECT
) else if "!bulk_type!"=="3" (
    set "proses_type=original_video"
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
    
    :: Get Video Title
    for /f "delims=" %%t in ('yt-dlp --get-filename --restrict-filenames -o "%%(title)s" "%%u" 2^>nul') do set "title=%%t"
    
    echo [!total!] !title!

    if "!proses_type!"=="audio" (
        yt-dlp -x --audio-format mp3 --audio-quality 320k --restrict-filenames -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    ) else if "!proses_type!"=="waveform" (
        set "temp_audio=!TEMP_DIR!\tmp_!random!.mp3"
        yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            call :CREATE_WAVEFORM "!bulk_img!" "!temp_audio!" "!OUTPUT_DIR!\!title!_waveform.mp4"
            del "!temp_audio!" 2>nul
        )
    ) else if "!proses_type!"=="original_video" (
        :: DOWNLOAD ORIGINAL VIDEO (Best MP4)
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --restrict-filenames -o "%OUTPUT_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    )

    if !errorlevel! equ 0 (
        echo    [OK] Success.
        set /a success+=1
    ) else (
        echo    [FAILED] An error occurred.
        set /a failed+=1
    )
)

echo.
echo ========================================
echo COMPLETE! Successful: %success% ^| Failed: %failed%
echo ========================================
pause
endlocal
goto MAIN_MENU

:: ========================================
:: MENU 6 - SYSTEM INFORMATION
:: ========================================
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

:: ========================================
:: EXIT
:: ========================================
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
    echo No temporary files found.
)
echo.
echo [INFO] Your MP3, Image, and Video files are SAFE
echo [INFO] All original files remain untouched
echo.
echo Goodbye!
timeout /t 5 >nul

:: Clean up environment and exit
endlocal
exit /b 0