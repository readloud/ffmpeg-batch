# 🎸 FFmpeg Matrix Audio Visualizer

An automated **FFmpeg**-based script to convert audio files (MP3) into aesthetic video visualizers with a *Matrix Green* theme. This tool supports batch processing for both local files and lists of URLs.

## ✨ Key Features
- **Batch Processing**: Automatically render an entire folder of MP3s or a list of URLs with one click.
- **Smart Background Logic**: 
  - Uses a specific image if filenames match (`song1.mp3` -> `song1.jpg`).
  - Falls back to a global `images.webp`.
  - Automatically uses a solid Matrix-black background if no images are found.
- **Dynamic Visualizer**: Responsive Matrix-green waveform.
- **Auto-Titling**: Video titles are automatically extracted from the filename or the URL string.
- **Streaming Support**: Renders directly from audio direct-links without needing to download them first.

## 🛠️ Prerequisites
1. **FFmpeg**: Ensure FFmpeg is installed and added to your *System Path*.
2. **Windows OS**: These scripts are written in `.bat` format for Command Prompt.

## 🚀 How to Use

### 1. Rendering Local Files (MP3 + Images)
1. Place your `.mp3` files in the root folder.
2. (Optional) Add `.jpg`, `.png`, or `.webp` images.
3. Run `auto_render.bat`.
4. Check the `output/` folder for your videos.

### 2. Rendering from URLs (list.txt)
1. Create a file named `list.txt`.
2. Paste direct MP3 URLs (one per line).
3. Run `render_url.bat`.

## 📁 Folder Structure
```text
.
├── output/              # Rendered .mp4 files
├── images.webp          # Default background image
├── auto_render.bat      # Script for local files
├── render_url.bat       # Script for URL lists
├── list.txt             # List of audio links
└── [Your MP3 Files]

🛠️ Troubleshooting

Issue,Solution
'ffmpeg' not recognized,Ensure FFmpeg is installed and the bin folder path is added to Windows Environment Variables.
Protocol not found (URL),Use a modern FFmpeg version (v4.0+) compiled with SSL/HTTPS support.
Messy Text,"If titles are too long, decrease the fontsize in the .bat script or shorten the MP3 filename."
Image Not Appearing,Ensure the image filename matches the MP3 filename exactly (case-sensitive).

Gemini said
Certainly! Here is the English version of your complete documentation and scripts, tailored for a professional GitHub repository.

1. README.md
Save this as README.md.

Markdown
# 🎸 FFmpeg Matrix Audio Visualizer

An automated **FFmpeg**-based script to convert audio files (MP3) into aesthetic video visualizers with a *Matrix Green* theme. This tool supports batch processing for both local files and lists of URLs.

## ✨ Key Features
- **Batch Processing**: Automatically render an entire folder of MP3s or a list of URLs with one click.
- **Smart Background Logic**: 
  - Uses a specific image if filenames match (`song1.mp3` -> `song1.jpg`).
  - Falls back to a global `images.webp`.
  - Automatically uses a solid Matrix-black background if no images are found.
- **Dynamic Visualizer**: Responsive Matrix-green waveform.
- **Auto-Titling**: Video titles are automatically extracted from the filename or the URL string.
- **Streaming Support**: Renders directly from audio direct-links without needing to download them first.

## 🛠️ Prerequisites
1. **FFmpeg**: Ensure FFmpeg is installed and added to your *System Path*.
2. **Windows OS**: These scripts are written in `.bat` format for Command Prompt.

## 🚀 How to Use

### 1. Rendering Local Files (MP3 + Images)
1. Place your `.mp3` files in the root folder.
2. (Optional) Add `.jpg`, `.png`, or `.webp` images.
3. Run `auto_render.bat`.
4. Check the `output/` folder for your videos.

### 2. Rendering from URLs (list.txt)
1. Create a file named `list.txt`.
2. Paste direct MP3 URLs (one per line).
3. Run `render_url.bat`.

## 📁 Folder Structure
```text
.
├── output/              # Rendered .mp4 files
├── images.webp          # Default background image
├── auto_render.bat      # Script for local files
├── render_url.bat       # Script for URL lists
├── list.txt             # List of audio links
└── [Your MP3 Files]
🛠️ Troubleshooting
Issue	Solution
'ffmpeg' not recognized	Ensure FFmpeg is installed and the bin folder path is added to Windows Environment Variables.
Protocol not found (URL)	Use a modern FFmpeg version (v4.0+) compiled with SSL/HTTPS support.
Messy Text	If titles are too long, decrease the fontsize in the .bat script or shorten the MP3 filename.
Image Not Appearing	Ensure the image filename matches the MP3 filename exactly (case-sensitive).

📜 License
This project is licensed under the MIT License.

---