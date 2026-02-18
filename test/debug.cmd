@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
:: CONFIGURATION - DEFAULT SYSTEM FOLDERS ONLY
:: ========================================
set "MUSIC_DIR=%USERPROFILE%\Music"
set "MUSIC_DIR=%MUSIC_DIR%\YT_Audio"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "PICTURES_DIR=%PICTURES_DIR%\YT_Images"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter"

:: Create folders if not exist
if not exist "%MUSIC_DIR%" mkdir "%MUSIC_DIR%"
if not exist "%PICTURES_DIR%" mkdir "%PICTURES_DIR%"
if not exist "%VIDEOS_DIR%" mkdir "%VIDEOS_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ========================================
:: SIMPLE FILE LIST - PASTI JALAN
:: ========================================

:LIST_MUSIC
cls
echo ========================================
echo        MUSIC FOLDER - DEFAULT
echo ========================================
echo %MUSIC_DIR%
echo.

echo DAFTAR FILE MP3:
echo ----------------------------------------
set count=0
for %%f in ("%MUSIC_DIR%\*.mp3") do (
    if exist "%%f" (
        set /a count+=1
        echo [!count!] %%~nxf
    )
)

if %count%==0 echo (Tidak ada file MP3)
echo ========================================
echo Total: %count% file
echo.
pause
goto LIST_PICTURES

:LIST_PICTURES
cls
echo ========================================
echo      PICTURES FOLDER - DEFAULT
echo ========================================
echo %PICTURES_DIR%
echo.

echo DAFTAR FILE GAMBAR:
echo ----------------------------------------
set count=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do (
    if exist "%%f" (
        set /a count+=1
        echo [!count!] %%~nxf
    )
)

if %count%==0 echo (Tidak ada file gambar)
echo ========================================
echo Total: %count% file
echo.
pause
goto LIST_VIDEOS

:LIST_VIDEOS
cls
echo ========================================
echo      VIDEOS FOLDER - DEFAULT
echo ========================================
echo %VIDEOS_DIR%
echo.

echo DAFTAR FILE VIDEO:
echo ----------------------------------------
set count=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do (
    if exist "%%f" (
        set /a count+=1
        echo [!count!] %%~nxf
    )
)

if %count%==0 echo (Tidak ada file video)
echo ========================================
echo Total: %count% file
echo.
pause
goto LIST_OUTPUT

:LIST_OUTPUT
cls
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
echo %OUTPUT_DIR%
echo.

echo DAFTAR FILE OUTPUT:
echo ----------------------------------------
set count=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a count+=1
        echo [!count!] %%~nxf
    )
)

if %count%==0 echo (Tidak ada file output)
echo ========================================
echo Total: %count% file
echo.
pause
goto MENU_UTAMA

:: ========================================
:: MENU UTAMA - SEDERHANA
:: ========================================

:MENU_UTAMA
cls
echo ========================================
echo   YOUTUBE DOWNLOADER CONVERTER PRO
echo ========================================
echo.
echo 1. Lihat file MUSIK
echo 2. Lihat file GAMBAR
echo 3. Lihat file VIDEO
echo 4. Lihat file OUTPUT
echo 5. Download audio (MP3)
echo 6. Convert MP3 ke video
echo 7. Keluar
echo.
set /p pilih="Pilih menu [1-7]: "

if "%pilih%"=="1" goto LIST_MUSIC
if "%pilih%"=="2" goto LIST_PICTURES
if "%pilih%"=="3" goto LIST_VIDEOS
if "%pilih%"=="4" goto LIST_OUTPUT
if "%pilih%"=="5" goto DOWNLOAD_AUDIO
if "%pilih%"=="6" goto CONVERT_MP3
if "%pilih%"=="7" goto KELUAR

echo Pilihan salah!
pause
goto MENU_UTAMA

:: ========================================
:: DOWNLOAD AUDIO
:: ========================================
:DOWNLOAD_AUDIO
cls
echo ========================================
echo        DOWNLOAD AUDIO MP3
echo ========================================
echo.
echo Folder tujuan: %MUSIC_DIR%
echo.
set /p url="Masukkan URL YouTube: "

if "%url%"=="" (
    echo URL tidak boleh kosong!
    pause
    goto DOWNLOAD_AUDIO
)

echo.
echo Mendownload...
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "%url%"

if errorlevel 1 (
    echo [ERROR] Download gagal!
) else (
    echo [SUCCESS] Download selesai!
)
pause
goto MENU_UTAMA

:: ========================================
:: CONVERT MP3 KE VIDEO
:: ========================================
:CONVERT_MP3
cls
echo ========================================
echo        CONVERT MP3 KE VIDEO
echo ========================================

:: Cek file MP3
set count=0
for %%f in ("%MUSIC_DIR%\*.mp3") do set /a count+=1

if %count%==0 (
    echo [ERROR] Tidak ada file MP3 di %MUSIC_DIR%!
    pause
    goto MENU_UTAMA
)

:: Tampilkan file MP3
echo.
echo DAFTAR FILE MP3:
echo ----------------------------------------
set idx=0
for %%f in ("%MUSIC_DIR%\*.mp3") do (
    set /a idx+=1
    echo [!idx!] %%~nxf
    set "mp3_!idx!=%%f"
)
echo ----------------------------------------

:: Pilih file
echo.
set /p nomor="Pilih nomor file: "

set "selected="
if "%nomor%"=="1" set "selected=%mp3_1%"
if "%nomor%"=="2" set "selected=%mp3_2%"
if "%nomor%"=="3" set "selected=%mp3_3%"
if "%nomor%"=="4" set "selected=%mp3_4%"
if "%nomor%"=="5" set "selected=%mp3_5%"
if "%nomor%"=="6" set "selected=%mp3_6%"
if "%nomor%"=="7" set "selected=%mp3_7%"
if "%nomor%"=="8" set "selected=%mp3_8%"
if "%nomor%"=="9" set "selected=%mp3_9%"
if "%nomor%"=="10" set "selected=%mp3_10%"

if "%selected%"=="" (
    echo File tidak valid!
    pause
    goto CONVERT_MP3
)

:: Cek file gambar
set count2=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do set /a count2+=1

if %count2%==0 (
    echo [ERROR] Tidak ada file gambar di %PICTURES_DIR%!
    pause
    goto MENU_UTAMA
)

:: Tampilkan file gambar
echo.
echo DAFTAR FILE GAMBAR:
echo ----------------------------------------
set idx2=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do (
    set /a idx2+=1
    echo [!idx2!] %%~nxf
    set "img_!idx2!=%%f"
)
echo ----------------------------------------

:: Pilih gambar
echo.
set /p nomor2="Pilih nomor gambar: "

set "selected_img="
if "%nomor2%"=="1" set "selected_img=%img_1%"
if "%nomor2%"=="2" set "selected_img=%img_2%"
if "%nomor2%"=="3" set "selected_img=%img_3%"
if "%nomor2%"=="4" set "selected_img=%img_4%"
if "%nomor2%"=="5" set "selected_img=%img_5%"
if "%nomor2%"=="6" set "selected_img=%img_6%"
if "%nomor2%"=="7" set "selected_img=%img_7%"
if "%nomor2%"=="8" set "selected_img=%img_8%"
if "%nomor2%"=="9" set "selected_img=%img_9%"
if "%nomor2%"=="10" set "selected_img=%img_10%"

if "%selected_img%"=="" (
    echo Gambar tidak valid!
    pause
    goto CONVERT_MP3
)

:: Convert
echo.
echo Mengconvert...
for %%f in ("%selected%") do set "namafile=%%~nf"
set "output=%OUTPUT_DIR%\%namafile%.mp4"

ffmpeg -loop 1 -i "%selected_img%" -i "%selected%" -c:v libx264 -preset ultrafast -tune stillimage -c:a aac -b:a 192k -shortest -vf "scale=1280:720" "%output%"

if errorlevel 1 (
    echo [ERROR] Convert gagal!
) else (
    echo [SUCCESS] Convert selesai!
    echo File: %output%
)
pause
goto MENU_UTAMA

:: ========================================
:: KELUAR
:: ========================================
:KELUAR
echo.
echo Terima kasih!
timeout /t 2 >nul
exit /b 0