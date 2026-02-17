Here's how to add a waveform to an existing video using ffmpeg. I'll provide several approaches depending on your needs:

## Method 1: Add waveform as an overlay (shows audio visualization)

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 output.mp4
```

**Parameter explanations:**
- `s=1280x200` - waveform size (width x height)
- `mode=cline` - centered line waveform (try `line`, `p2p`, or `cline`)
- `colors=white` - waveform color
- `overlay=0:H-h` - position at bottom (0 from left, H-h from top)

## Method 2: Create a new video with waveform and original video side-by-side

```batch
ffmpeg -i input.mp4 -filter_complex "[0:v]scale=640:-1[vleft];[0:a]showwaves=s=640x360:mode=cline[waves];[vleft][waves]hstack" -c:a copy output.mp4
```

## Method 3: Oscilloscope style waveform

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x200:mode=point:rate=25:colors=white@0.8[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 output.mp4
```

## Method 4: Full screen waveform (replaces video)

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white|blue" -c:v libx264 -c:a copy output.mp4
```

## For CMD/Batch file usage:

```batch
ffmpeg -i "input.mp4" -filter_complex "[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 "output.mp4"
```

**Additional options you can customize:**
- Change `colors=white` to any color (red, blue, cyan, or hex #RRGGBB)
- Adjust `s=1280x200` for different waveform sizes
- Try different modes: `mode=line`, `mode=p2p`, `mode=cline`, `mode=point`
- Add `:scale=sqrt` for logarithmic scale (better for quiet/loud variations)

The waveform will animate in real-time matching your audio throughout the video.

**Bar overlay effect. The bar is created by this part:
```
drawbox=x=0:y=h-20:w=iw*t/291:h=20:color=gray@0.5:t=fill
```
**And the moving overlay is created by:
```
[0][bar]overlay=-w+(w/291)*t:H-h:shortest=1
```
**To remove the bar overlay effect completely, you can use this simplified command:
```bash
ffmpeg -i Mawar-Bodas.mp4 -filter_complex "drawtext=fontfile=KGTeacherJordan.ttf:text='The Best Darso':fontsize=48:fontcolor=white:x=(w-tw)/2:y=h-th-2,drawtext=fontfile=RitualoftheWitch.ttf:text='Mawar Bodas':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2,drawtext=fontfile=SuperWonder.ttf:text='%{pts\:hms}':x=(w-text_w-10):y=(h-text_h-10):fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" -y Mawar_Bodas.mp4
```
**This removes:
1. The `drawbox` filter (the gray bar)
2. The `color` filter that created the bar background
3. The `overlay` filter that animated the bar

The remaining filters will keep your title text ("The Best Darso" and "Mawar Bodas") and the timestamp overlay without the moving bar at the bottom.
To remove the background image from your FFmpeg command, you need to eliminate the background overlay part. Here's the modified command that creates just the audio waveform visualization without the background image:

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```

**Changes made:
1. Removed `-i background.png` input
2. Removed `[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv]` part since there's no background to overlay on
3. Simplified the filter_complex to directly output the waveform visualization

Here's how to create a video with waveform at the bottom (side-by-side with timestamp/duration) and title centered:

## Waveform + Timestamp+Duration + Centered Title

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[vmain];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=white[waves];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[0:a]volumedetect,ametadata=print:file=-,atempo=1.0,asplit[audio];^
[0:v]drawtext=text='Center Title':fontcolor=white:fontsize=36:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.5:shadowx=2:shadowy=2[title];^
[title][waves_bg]overlay=0:H-h[final]" ^
-map "[final]" -map 0:a -c:v libx264 -c:a copy -preset fast output.mp4
```

## Method 2: With Dynamic Timestamp and Duration Display

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=cyan[waves];^
color=c=black@0.7:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[scaled]drawtext=text='MY VIDEO TITLE':fontcolor=white:fontsize=40:fontweight=bold:x=(w-text_w)/2:y=(h/2)-50:shadowcolor=black@0.8:shadowx=3:shadowy=3[title];^
[title][waves_bg]overlay=0:H-h,^
drawtext=text='Time: %%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=H-80,^
drawtext=text='Duration: 00:02:30':fontcolor=green:fontsize=18:x=w-200:y=H-80" ^
-c:a copy -c:v libx264 output.mp4
```

## Method 3: Split Waveform with Left/Right Stereo Visualization

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=red[left];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=blue[right];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][left]overlay=0:0[bg_left];^
[bg_left][right]overlay=640:0[waves_bg];^
[scaled]drawtext=text='TITLE CENTERED':fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=10:y=10,^
drawtext=text='L':fontcolor=red:fontsize=14:x=10:y=H-130,^
drawtext=text='R':fontcolor=blue:fontsize=14:x=650:y=H-130[title];^
[title][waves_bg]overlay=0:H-h" ^
-c:a copy -c:v libx264 output_with_stereo_waves.mp4
```
You can display an audio waveform at the bottom of a video using FFmpeg's showwaves filter and the overlay filter. The core idea is to generate a waveform video from your audio and then place it over your original video, positioned at the bottom.

Here is a standard command that accomplishes this:


ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x202:mode=line[waveform];[0:v][waveform]overlay=0:H-h" -c:a copy output.mp4

And here is the breakdown of how it works:
-i input.mp4: Specifies your input video file, which contains both the video and audio streams.
-filter_complex: This enables the use of complex filter graphs, allowing you to process audio and video streams separately before combining them.
[0:a]showwaves=s=1280x202:mode=line[waveform]:
[0:a] selects the audio stream from the first input file (input.mp4).
showwaves is the filter that creates a visual representation of the audio.
s=1280x202 sets the size (resolution) of the generated waveform video. In this case, it's 1280 pixels wide and 202 pixels tall. You should adjust the width to match your video's width and the height to your preferred waveform size.
mode=line sets the style of the waveform to a connected line. Other popular modes include point (drawn as separate points) and p2p (drawn as a bar graph).
[waveform] gives this filter output a temporary name, or "label," so it can be used later in the command.
[0:v][waveform]overlay=0:H-h:
[0:v] selects the original video stream.
[waveform] selects the waveform video stream you just created.

overlay is the filter that places the waveform video on top of the main video.
0:H-h sets the position of the waveform. 0 means 0 pixels from the left edge. H-h is a dynamic expression that calculates the vertical position: it takes the height of the main video (H) and subtracts the height of the waveform (h), effectively placing the waveform at the very bottom of the frame.
-c:a copy: This tells FFmpeg to copy the original audio stream directly to the output file without re-encoding it, which preserves quality and saves time.
output.mp4: The name of your new output file.

Customizing Your Waveform
You can modify the showwaves filter to change the look and feel of your waveform. Here are some of the most common customizations:
Waveform Colors: Use the colors parameter. You can use named colors like red or hex codes like #25d3d0.

showwaves=s=1280x202:mode=line:colors=#25d3d0
Waveform Style (Mode): Change the mode to cline (colored line), p2p (peaks to peaks, a bar-like look), or point.

showwaves=s=1280x202:mode=p2p:colors=white
Drawing Scale: The draw parameter set to full will draw every sample, creating a bolder, more filled-in waveform.

showwaves=s=1280x202:mode=line:draw=full

Adding a Background Color
If you want to place the waveform over a solid color instead of directly on the video, you can create a colored background and then overlay the waveform on that.

This example creates a purple background and overlays a cyan waveform on top of it:

ffmpeg -i input.mp3 -f lavfi -i color=c=#7925d3:s=1280x720 -filter_complex "[0:a]showwaves=s=1280x202:colors=#25d3d0:draw=full:mode=cline[waveform];[1:v][waveform]overlay=0:H-h,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4

Explanation of new elements:
-f lavfi -i color=c=#7925d3:s=1280x720: This generates a solid color video stream. c=#7925d3 is the color (purple), and s=1280x720 is the frame size.
[1:v][waveform]overlay=...: The overlay filter now uses [1:v], which is the generated color stream, as its background.
format=yuv420p: This filter ensures the final video uses a pixel format that is compatible with most players.

This should give you a solid foundation to start adding and customizing waveforms in your videos. The overlay=0:H-h expression is the key to anchoring it to the bottom. Let me know if you'd like to explore other waveform styles or more advanced compositing techniques!

FFmpeg does not have a built-in filter to create a circular (polar) waveform directly . The showwaves and showwavespic filters only generate standard linear (horizontal or vertical) waveforms .

To create a circular waveform that animates with your audio, you need to use a multi-step approach:

Method 1: Using FFmpeg + ImageMagick (Simpler but Static Frames)
This method generates individual waveform frames and converts them to circular form.

Step 1: Generate linear waveform frames

ffmpeg -i input.mp4 -filter_complex "showwaves=s=720x720:mode=line:rate=25" -frames:v 1 waveform_%04d.png

Step 2: Convert to circular using ImageMagick

convert waveform_0001.png -distort Polar 0 circle_waveform.png

Step 3: Recombine with video
For animation, you would need to do this for every frame and then re-encode, which is complex and time-consuming.

Method 2: Advanced Approach with FFmpeg Geq Filter
For a dynamic circular waveform, you can use a combination of filters to transform coordinates:

ffmpeg -i input.mp4 -filter_complex \
"[0:a]showwaves=s=720x720:mode=line,format=rgba[linear]; \
 [0:v]scale=720:720[bg]; \
 [bg][linear]overlay=0:0,geq='if(between(r,320,340),p(X,Y),p(X,Y))':r=720/720" \
-c:a copy output.mp4
Explanation:

Generate a linear waveform
Scale video to match
Use geq (global equation) filter to manipulate pixel coordinates
The complex part is mapping Cartesian (x,y) to Polar (r,θ) coordinates

Practical Recommendation
For a truly dynamic circular waveform, consider these alternatives:
Use specialized audio visualization software like MilkDrop or Buttplug that support circular visualizations, then screen-capture and overlay
Use a video editing tool like Adobe After Effects or DaVinci Resolve which have audio waveform effects that can be shaped into circles
Create a custom solution using Python with libraries like ffmpeg-python and numpy to generate frames programmatically

A circular waveform (like an audio spectroscope in polar coordinates)
No image background (transparent or black)
Text overlay for title
Logo overlay
Here's a corrected command to achieve this:

ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"[0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1[waveform]; \
 [waveform]format=rgba,rotate=5:c=none[rotated]; \
 [rotated][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4

Key Components Explained:
1. Circular Waveform with avectorscope

avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1
mode=circle creates circular/polar visualization
zoom=1.3 controls the size of the circle
rc/gc/bc set colors for channels (white in this example)
rf/gf/bf set intensity factors

2. Rotation Effect

format=rgba,rotate=5:c=none

Rotates the visualization for dynamic effect
c=none keeps transparent background

3. Text Animation

alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))
Text fades in over 3 seconds after 1 second delay

Alternative: Circular Wave with Background
If you want a black background instead of transparent:

ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"color=c=black:s=720x720:r=30[bg]; \
 [0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=0:gc=1:bc=0:rf=1:gf=1:bf=1,format=rgba[waveform]; \
 [bg][waveform]overlay=0:0[withbg]; \
 [withbg][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:fontfile=/path/to/font.ttf[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4

Customization Options:
Colors:
Green only: rc=0:gc=1:bc=0


## Method 4: Professional Layout with Borders and Labels

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[main_video];^
[0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves];^
color=c=#333333:s=1280x120,format=rgba[wave_container];^
[wave_container][waves]overlay=40:20[waves_padded];^
[main_video]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.7:shadowx=3:shadowy=3,^
drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+30,^
drawbox=x=0:y=H-120:w=1280:h=120:color=#333333@0.9:t=fill[title_box];^
[title_box][waves_padded]overlay=0:H-120[final]" ^
-map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy professional_output.mp4
```

## Batch File Version with Customizable Settings

```batch
@echo off
set INPUT=input.mp4
set TITLE="Your Video Title"
set SUBTITLE="Additional Text"
set OUTPUT=final_video.mp4

ffmpeg -i "%INPUT%" -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1200x100:mode=cline:rate=25:colors=white|cyan[waves];^
color=c=#222222:s=1280x120,format=rgba[bg];^
[bg][waves]overlay=40:10[waves_final];^
[scaled]drawtext=text=%TITLE%:fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h/2)-40:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text=%SUBTITLE%:fontcolor=#AAAAAA:fontsize=24:x=(w-text_w)/2:y=(h/2)+20,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=20:y=10,^
drawtext=text='Duration: 00:02:30':fontcolor=yellow:fontsize=16:x=w-180:y=10[video_with_text];^
[video_with_text][waves_final]overlay=0:H-120" ^
-c:a copy -c:v libx264 -preset fast "%OUTPUT%"

echo Done! Output saved as %OUTPUT%
```

## Key Features Explained:

- **Centered Title**: Using `x=(w-text_w)/2:y=(h-text_h)/2` positions text exactly in the middle
- **Waveform at Bottom**: Positioned with `overlay=0:H-h` or `overlay=0:H-120`
- **Timestamp**: Top-left corner showing current playback time
- **Duration**: Top-right corner showing total video length
- **Waveform Container**: Dark background panel for better visibility

**Customization Tips:**
- Adjust `fontsize` values to change text size
- Modify `colors=` in showwaves for different waveform colors
- Change `y=(h-text_h)/2-30` to move title up/down from exact center
- Use hex colors like `#FF5733` for custom colors

Bar overlay effect. The bar is created by this part:

```
drawbox=x=0:y=h-20:w=iw*t/291:h=20:color=gray@0.5:t=fill
```

And the moving overlay is created by:
```
[0][bar]overlay=-w+(w/291)*t:H-h:shortest=1
```

To remove the bar overlay effect completely, you can use this simplified command:

```bash
ffmpeg -i Mawar-Bodas.mp4 -filter_complex "drawtext=fontfile=KGTeacherJordan.ttf:text='The Best Darso':fontsize=48:fontcolor=white:x=(w-tw)/2:y=h-th-2,drawtext=fontfile=RitualoftheWitch.ttf:text='Mawar Bodas':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2,drawtext=fontfile=SuperWonder.ttf:text='%{pts\:hms}':x=(w-text_w-10):y=(h-text_h-10):fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" -y Mawar_Bodas.mp4
```

This removes:
1. The `drawbox` filter (the gray bar)
2. The `color` filter that created the bar background
3. The `overlay` filter that animated the bar

The remaining filters will keep your title text ("The Best Darso" and "Mawar Bodas") and the timestamp overlay without the moving bar at the bottom.

To remove the background image from your FFmpeg command, you need to eliminate the background overlay part. Here's the modified command that creates just the audio waveform visualization without the background image:

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```

Changes made:
1. Removed `-i background.png` input
2. Removed `[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv]` part since there's no background to overlay on
3. Simplified the filter_complex to directly output the waveform visualization

The waveform will now be rendered directly on a transparent or black background (depending on your FFmpeg version and default settings). If you want a specific background color instead of transparency, you could add a `color` filter as a base layer.

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main_video];[0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves];color=c=#333333:s=1280x120,format=rgba[wave_container];[wave_container][waves]overlay=40:20[waves_padded];[main_video]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.9:shadowx=3:shadowy=3,drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+30,drawbox=x=0:y=h-120:w=1280:h=120:color=#333333@0.9:t=fill[title_box];[title_box][waves_padded]overlay=0:h-120[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main_video]; [0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves]; [main_video]drawbox=y=h-120:w=1280:h=120:color=#333333@0.9:t=fill[bg_box]; [bg_box][waves]overlay=(W-w)/2:H-100[video_with_waves]; [video_with_waves]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y


ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x100:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_with_text]; [video_with_text]drawbox=x=0:y=h-120:w=1280:h=120:color=#333333@0.6:t=fill[video_with_box]; [video_with_box][waves]overlay=x=0:y=H-110[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x100:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_text]; [video_text]drawbox=x=0:y=ih-120:w=iw:h=120:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-110[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x50:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='= 1':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Plastik':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_text]; [video_text]drawbox=x=0:y=ih-60:w=iw:h=60:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-55[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x50:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.8:shadowx=4:shadowy=4, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=28:x=(w-text_w)/2:y=(h-text_h)/2-40:box=1:boxcolor=black@0.5:boxborderw=10:shadowcolor=black@0.8:shadowx=2:shadowy=2[video_text]; [video_text]drawbox=x=0:y=ih-60:w=iw:h=60:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-55[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='VIDEO TITLE':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp4) DO ffmpeg -i "%i" -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='VIDEO TITLE':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -y "output\%~ni_matrix.mp4"

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp4) DO ffmpeg -i "%i" -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Plastik Band':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -y "output\%~ni.mp4"

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp3) DO ffmpeg -loop 1 -i "images.png" -i "%i" -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%~ni.mp4"

@echo off
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -loop 1 -i "%%~ni.jpg" -i "%%i" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; ^
    [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
    [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; ^
    [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
    drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
    [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
pause

@echo off
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -f lavfi -i color=c=#0e0e0e:s=1280x720:r=25 -i "%%i" -filter_complex ^
    "[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
    [0:v]drawbox=x=0:y=ih-140:w=iw:h=140:color=#1a1a1a@1:t=fill[bg_box]; ^
    [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110, ^
    drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70[video_text]; ^
    [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -c:a copy -shortest -y "output\%%~ni.mp4"
)
pause

@echo off
setlocal enabledelayedexpansion
IF NOT EXIST "output" MKDIR "output"

FOR %%i IN (*.mp3) DO (
    set "FILENAME=%%~ni"
    
    REM Cek apakah ada file gambar .jpg atau .png dengan nama yang sama
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else (
        REM Jika tidak ada gambar, pakai warna hitam
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
        set "V_FILTER=format=yuv420p"
    )

    ffmpeg !INPUT_V! -i "%%i" -filter_complex ^
    "[0:v]!V_FILTER![main]; ^
     [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
     [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box]; ^
     [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
     drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
     [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
echo --- PROSES SELESAI ---
pause

@echo off
setlocal enabledelayedexpansion

REM Membuat folder output jika belum ada, kalau sudah ada tidak akan error
if not exist "output" mkdir "output"

FOR %%i IN (*.mp3) DO (
    set "FILENAME=%%~ni"
    echo Sedang memproses: "!FILENAME!"
    
    REM Cek gambar (jpg/png/webp)
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
    ) else if exist "images.webp" (
        set "INPUT_V=-loop 1 -i "images.webp""
    ) else (
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
    )

    ffmpeg -y !INPUT_V! -i "%%i" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; ^
     [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
     [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box]; ^
     [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
     drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
     [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest "output\%%~ni.mp4"
)

echo --- SEMUA VIDEO BERHASIL DIRENDER ---
pause
The waveform will now be rendered directly on a transparent or black background (depending on your FFmpeg version and default settings). If you want a specific background color instead of transparency, you could add a `color` filter as a base layer.

You can display an audio waveform at the bottom of a video using FFmpeg's showwaves filter and the overlay filter. The core idea is to generate a waveform video from your audio and then place it over your original video, positioned at the bottom.

Here is a standard command that accomplishes this:

```
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x202:mode=line[waveform];[0:v][waveform]overlay=0:H-h" -c:a copy output.mp4
```
**And here is the breakdown of how it works:
-i input.mp4: Specifies your input video file, which contains both the video and audio streams.
-filter_complex: This enables the use of complex filter graphs, allowing you to process audio and video streams separately before combining them.
[0:a]showwaves=s=1280x202:mode=line[waveform]:
[0:a] selects the audio stream from the first input file (input.mp4).

**showwaves is the filter that creates a visual representation of the audio.
s=1280x202 sets the size (resolution) of the generated waveform video. In this case, it's 1280 pixels wide and 202 pixels tall. You should adjust the width to match your video's width and the height to your preferred waveform size.

**mode=line sets the style of the waveform to a connected line. Other popular modes include point (drawn as separate points) and p2p (drawn as a bar graph).
[waveform] gives this filter output a temporary name, or "label," so it can be used later in the command.
[0:v][waveform]overlay=0:H-h:
[0:v] selects the original video stream.
[waveform] selects the waveform video stream you just created.

**overlay is the filter that places the waveform video on top of the main video.
0:H-h sets the position of the waveform. 0 means 0 pixels from the left edge. H-h is a dynamic expression that calculates the vertical position: it takes the height of the main video (H) and subtracts the height of the waveform (h), effectively placing the waveform at the very bottom of the frame.
-c:a copy: This tells FFmpeg to copy the original audio stream directly to the output file without re-encoding it, which preserves quality and saves time.
output.mp4: The name of your new output file.

**Customizing Your Waveform
You can modify the showwaves filter to change the look and feel of your waveform. Here are some of the most common customizations:
Waveform Colors: Use the colors parameter. You can use named colors like red or hex codes like #25d3d0.
```
showwaves=s=1280x202:mode=line:colors=#25d3d0
```
Waveform Style (Mode): Change the mode to cline (colored line), p2p (peaks to peaks, a bar-like look), or point.
```
showwaves=s=1280x202:mode=p2p:colors=white
```
Drawing Scale: The draw parameter set to full will draw every sample, creating a bolder, more filled-in waveform.
```
showwaves=s=1280x202:mode=line:draw=full
```
**Adding a Background Color
If you want to place the waveform over a solid color instead of directly on the video, you can create a colored background and then overlay the waveform on that.

**This example creates a purple background and overlays a cyan waveform on top of it:
```
ffmpeg -i input.mp3 -f lavfi -i color=c=#7925d3:s=1280x720 -filter_complex "[0:a]showwaves=s=1280x202:colors=#25d3d0:draw=full:mode=cline[waveform];[1:v][waveform]overlay=0:H-h,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```
**Explanation of new elements:
-f lavfi -i color=c=#7925d3:s=1280x720: This generates a solid color video stream. c=#7925d3 is the color (purple), and s=1280x720 is the frame size.
[1:v][waveform]overlay=...: The overlay filter now uses [1:v], which is the generated color stream, as its background.
format=yuv420p: This filter ensures the final video uses a pixel format that is compatible with most players.

This should give you a solid foundation to start adding and customizing waveforms in your videos. The overlay=0:H-h expression is the key to anchoring it to the bottom. Let me know if you'd like to explore other waveform styles or more advanced compositing techniques!

Here's how to create a video with waveform at the bottom (side-by-side with timestamp/duration) and title centered:

## Waveform + Timestamp+Duration + Centered Title

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[vmain];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=white[waves];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[0:a]volumedetect,ametadata=print:file=-,atempo=1.0,asplit[audio];^
[0:v]drawtext=text='Center Title':fontcolor=white:fontsize=36:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.5:shadowx=2:shadowy=2[title];^
[title][waves_bg]overlay=0:H-h[final]" ^
-map "[final]" -map 0:a -c:v libx264 -c:a copy -preset fast output.mp4
```

## Method 2: With Dynamic Timestamp and Duration Display

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=cyan[waves];^
color=c=black@0.7:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[scaled]drawtext=text='MY VIDEO TITLE':fontcolor=white:fontsize=40:fontweight=bold:x=(w-text_w)/2:y=(h/2)-50:shadowcolor=black@0.8:shadowx=3:shadowy=3[title];^
[title][waves_bg]overlay=0:H-h,^
drawtext=text='Time: %%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=H-80,^
drawtext=text='Duration: 00:02:30':fontcolor=green:fontsize=18:x=w-200:y=H-80" ^
-c:a copy -c:v libx264 output.mp4
```

## Method 3: Split Waveform with Left/Right Stereo Visualization

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=red[left];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=blue[right];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][left]overlay=0:0[bg_left];^
[bg_left][right]overlay=640:0[waves_bg];^
[scaled]drawtext=text='TITLE CENTERED':fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=10:y=10,^
drawtext=text='L':fontcolor=red:fontsize=14:x=10:y=H-130,^
drawtext=text='R':fontcolor=blue:fontsize=14:x=650:y=H-130[title];^
[title][waves_bg]overlay=0:H-h" ^
-c:a copy -c:v libx264 output_with_stereo_waves.mp4
```
You can display an audio waveform at the bottom of a video using FFmpeg's showwaves filter and the overlay filter. The core idea is to generate a waveform video from your audio and then place it over your original video, positioned at the bottom.

Here is a standard command that accomplishes this:


ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x202:mode=line[waveform];[0:v][waveform]overlay=0:H-h" -c:a copy output.mp4

And here is the breakdown of how it works:
-i input.mp4: Specifies your input video file, which contains both the video and audio streams.
-filter_complex: This enables the use of complex filter graphs, allowing you to process audio and video streams separately before combining them.
[0:a]showwaves=s=1280x202:mode=line[waveform]:
[0:a] selects the audio stream from the first input file (input.mp4).
showwaves is the filter that creates a visual representation of the audio.
s=1280x202 sets the size (resolution) of the generated waveform video. In this case, it's 1280 pixels wide and 202 pixels tall. You should adjust the width to match your video's width and the height to your preferred waveform size.
mode=line sets the style of the waveform to a connected line. Other popular modes include point (drawn as separate points) and p2p (drawn as a bar graph).
[waveform] gives this filter output a temporary name, or "label," so it can be used later in the command.
[0:v][waveform]overlay=0:H-h:
[0:v] selects the original video stream.
[waveform] selects the waveform video stream you just created.

overlay is the filter that places the waveform video on top of the main video.
0:H-h sets the position of the waveform. 0 means 0 pixels from the left edge. H-h is a dynamic expression that calculates the vertical position: it takes the height of the main video (H) and subtracts the height of the waveform (h), effectively placing the waveform at the very bottom of the frame.
-c:a copy: This tells FFmpeg to copy the original audio stream directly to the output file without re-encoding it, which preserves quality and saves time.
output.mp4: The name of your new output file.

Customizing Your Waveform
You can modify the showwaves filter to change the look and feel of your waveform. Here are some of the most common customizations:
Waveform Colors: Use the colors parameter. You can use named colors like red or hex codes like #25d3d0.

showwaves=s=1280x202:mode=line:colors=#25d3d0
Waveform Style (Mode): Change the mode to cline (colored line), p2p (peaks to peaks, a bar-like look), or point.

showwaves=s=1280x202:mode=p2p:colors=white
Drawing Scale: The draw parameter set to full will draw every sample, creating a bolder, more filled-in waveform.

showwaves=s=1280x202:mode=line:draw=full

Adding a Background Color
If you want to place the waveform over a solid color instead of directly on the video, you can create a colored background and then overlay the waveform on that.

This example creates a purple background and overlays a cyan waveform on top of it:

ffmpeg -i input.mp3 -f lavfi -i color=c=#7925d3:s=1280x720 -filter_complex "[0:a]showwaves=s=1280x202:colors=#25d3d0:draw=full:mode=cline[waveform];[1:v][waveform]overlay=0:H-h,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4

Explanation of new elements:
-f lavfi -i color=c=#7925d3:s=1280x720: This generates a solid color video stream. c=#7925d3 is the color (purple), and s=1280x720 is the frame size.
[1:v][waveform]overlay=...: The overlay filter now uses [1:v], which is the generated color stream, as its background.
format=yuv420p: This filter ensures the final video uses a pixel format that is compatible with most players.

This should give you a solid foundation to start adding and customizing waveforms in your videos. The overlay=0:H-h expression is the key to anchoring it to the bottom. Let me know if you'd like to explore other waveform styles or more advanced compositing techniques!

FFmpeg does not have a built-in filter to create a circular (polar) waveform directly . The showwaves and showwavespic filters only generate standard linear (horizontal or vertical) waveforms .

To create a circular waveform that animates with your audio, you need to use a multi-step approach:

Method 1: Using FFmpeg + ImageMagick (Simpler but Static Frames)
This method generates individual waveform frames and converts them to circular form.

Step 1: Generate linear waveform frames

ffmpeg -i input.mp4 -filter_complex "showwaves=s=720x720:mode=line:rate=25" -frames:v 1 waveform_%04d.png

Step 2: Convert to circular using ImageMagick

convert waveform_0001.png -distort Polar 0 circle_waveform.png

Step 3: Recombine with video
For animation, you would need to do this for every frame and then re-encode, which is complex and time-consuming.

Method 2: Advanced Approach with FFmpeg Geq Filter
For a dynamic circular waveform, you can use a combination of filters to transform coordinates:

ffmpeg -i input.mp4 -filter_complex \
"[0:a]showwaves=s=720x720:mode=line,format=rgba[linear]; \
 [0:v]scale=720:720[bg]; \
 [bg][linear]overlay=0:0,geq='if(between(r,320,340),p(X,Y),p(X,Y))':r=720/720" \
-c:a copy output.mp4
Explanation:

Generate a linear waveform
Scale video to match
Use geq (global equation) filter to manipulate pixel coordinates
The complex part is mapping Cartesian (x,y) to Polar (r,θ) coordinates

Practical Recommendation
For a truly dynamic circular waveform, consider these alternatives:
Use specialized audio visualization software like MilkDrop or Buttplug that support circular visualizations, then screen-capture and overlay
Use a video editing tool like Adobe After Effects or DaVinci Resolve which have audio waveform effects that can be shaped into circles
Create a custom solution using Python with libraries like ffmpeg-python and numpy to generate frames programmatically

A circular waveform (like an audio spectroscope in polar coordinates)
No image background (transparent or black)
Text overlay for title
Logo overlay
Here's a corrected command to achieve this:

ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"[0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1[waveform]; \
 [waveform]format=rgba,rotate=5:c=none[rotated]; \
 [rotated][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4

Key Components Explained:
1. Circular Waveform with avectorscope

avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1
mode=circle creates circular/polar visualization
zoom=1.3 controls the size of the circle
rc/gc/bc set colors for channels (white in this example)
rf/gf/bf set intensity factors

2. Rotation Effect

format=rgba,rotate=5:c=none

Rotates the visualization for dynamic effect
c=none keeps transparent background

3. Text Animation

alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))
Text fades in over 3 seconds after 1 second delay

Alternative: Circular Wave with Background
If you want a black background instead of transparent:

ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"color=c=black:s=720x720:r=30[bg]; \
 [0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=0:gc=1:bc=0:rf=1:gf=1:bf=1,format=rgba[waveform]; \
 [bg][waveform]overlay=0:0[withbg]; \
 [withbg][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:fontfile=/path/to/font.ttf[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4

Customization Options:
Colors:
Green only: rc=0:gc=1:bc=0


## Method 4: Professional Layout with Borders and Labels

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[main_video];^
[0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves];^
color=c=#333333:s=1280x120,format=rgba[wave_container];^
[wave_container][waves]overlay=40:20[waves_padded];^
[main_video]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.7:shadowx=3:shadowy=3,^
drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+30,^
drawbox=x=0:y=H-120:w=1280:h=120:color=#333333@0.9:t=fill[title_box];^
[title_box][waves_padded]overlay=0:H-120[final]" ^
-map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy professional_output.mp4
```

## Batch File Version with Customizable Settings

```batch
@echo off
set INPUT=input.mp4
set TITLE="Your Video Title"
set SUBTITLE="Additional Text"
set OUTPUT=final_video.mp4

ffmpeg -i "%INPUT%" -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1200x100:mode=cline:rate=25:colors=white|cyan[waves];^
color=c=#222222:s=1280x120,format=rgba[bg];^
[bg][waves]overlay=40:10[waves_final];^
[scaled]drawtext=text=%TITLE%:fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h/2)-40:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text=%SUBTITLE%:fontcolor=#AAAAAA:fontsize=24:x=(w-text_w)/2:y=(h/2)+20,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=20:y=10,^
drawtext=text='Duration: 00:02:30':fontcolor=yellow:fontsize=16:x=w-180:y=10[video_with_text];^
[video_with_text][waves_final]overlay=0:H-120" ^
-c:a copy -c:v libx264 -preset fast "%OUTPUT%"

echo Done! Output saved as %OUTPUT%
```

## Key Features Explained:

- **Centered Title**: Using `x=(w-text_w)/2:y=(h-text_h)/2` positions text exactly in the middle
- **Waveform at Bottom**: Positioned with `overlay=0:H-h` or `overlay=0:H-120`
- **Timestamp**: Top-left corner showing current playback time
- **Duration**: Top-right corner showing total video length
- **Waveform Container**: Dark background panel for better visibility

**Customization Tips:**
- Adjust `fontsize` values to change text size
- Modify `colors=` in showwaves for different waveform colors
- Change `y=(h-text_h)/2-30` to move title up/down from exact center
- Use hex colors like `#FF5733` for custom colors

Bar overlay effect. The bar is created by this part:

```
drawbox=x=0:y=h-20:w=iw*t/291:h=20:color=gray@0.5:t=fill
```

And the moving overlay is created by:
```
[0][bar]overlay=-w+(w/291)*t:H-h:shortest=1
```

To remove the bar overlay effect completely, you can use this simplified command:

```bash
ffmpeg -i Mawar-Bodas.mp4 -filter_complex "drawtext=fontfile=KGTeacherJordan.ttf:text='The Best Darso':fontsize=48:fontcolor=white:x=(w-tw)/2:y=h-th-2,drawtext=fontfile=RitualoftheWitch.ttf:text='Mawar Bodas':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2,drawtext=fontfile=SuperWonder.ttf:text='%{pts\:hms}':x=(w-text_w-10):y=(h-text_h-10):fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" -y Mawar_Bodas.mp4
```

This removes:
1. The `drawbox` filter (the gray bar)
2. The `color` filter that created the bar background
3. The `overlay` filter that animated the bar

The remaining filters will keep your title text ("The Best Darso" and "Mawar Bodas") and the timestamp overlay without the moving bar at the bottom.

To remove the background image from your FFmpeg command, you need to eliminate the background overlay part. Here's the modified command that creates just the audio waveform visualization without the background image:

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```

Changes made:
1. Removed `-i background.png` input
2. Removed `[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv]` part since there's no background to overlay on
3. Simplified the filter_complex to directly output the waveform visualization

The waveform will now be rendered directly on a transparent or black background (depending on your FFmpeg version and default settings). If you want a specific background color instead of transparency, you could add a `color` filter as a base layer.

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main_video];[0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves];color=c=#333333:s=1280x120,format=rgba[wave_container];[wave_container][waves]overlay=40:20[waves_padded];[main_video]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.9:shadowx=3:shadowy=3,drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+30,drawbox=x=0:y=h-120:w=1280:h=120:color=#333333@0.9:t=fill[title_box];[title_box][waves_padded]overlay=0:h-120[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main_video]; [0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves]; [main_video]drawbox=y=h-120:w=1280:h=120:color=#333333@0.9:t=fill[bg_box]; [bg_box][waves]overlay=(W-w)/2:H-100[video_with_waves]; [video_with_waves]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y


ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x100:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_with_text]; [video_with_text]drawbox=x=0:y=h-120:w=1280:h=120:color=#333333@0.6:t=fill[video_with_box]; [video_with_box][waves]overlay=x=0:y=H-110[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x100:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_text]; [video_text]drawbox=x=0:y=ih-120:w=iw:h=120:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-110[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x50:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='= 1':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, drawtext=text='Plastik':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40[video_text]; [video_text]drawbox=x=0:y=ih-60:w=iw:h=60:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-55[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x50:mode=p2p:rate=25:colors=white@0.8[waves]; [main]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.8:shadowx=4:shadowy=4, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=28:x=(w-text_w)/2:y=(h-text_h)/2-40:box=1:boxcolor=black@0.5:boxborderw=10:shadowcolor=black@0.8:shadowx=2:shadowy=2[video_text]; [video_text]drawbox=x=0:y=ih-60:w=iw:h=60:color=#333333@0.6:t=fill[video_box]; [video_box][waves]overlay=x=0:y=H-55[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

ffmpeg -i 1.mp4 -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='VIDEO TITLE':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -t 5 _output.mp4 -y

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp4) DO ffmpeg -i "%i" -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='VIDEO TITLE':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Subtitle or Description':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -y "output\%~ni_matrix.mp4"

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp4) DO ffmpeg -i "%i" -filter_complex "[0:v]scale=1280:720[main]; [0:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Plastik Band':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy -y "output\%~ni.mp4"

IF NOT EXIST "output" MKDIR "output" & FOR %i IN (*.mp3) DO ffmpeg -loop 1 -i "images.png" -i "%i" -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; [bg_box]drawtext=text='%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; [video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%~ni.mp4"

@echo off
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -loop 1 -i "%%~ni.jpg" -i "%%i" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; ^
    [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
    [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box]; ^
    [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
    drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
    [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
pause

@echo off
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -f lavfi -i color=c=#0e0e0e:s=1280x720:r=25 -i "%%i" -filter_complex ^
    "[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
    [0:v]drawbox=x=0:y=ih-140:w=iw:h=140:color=#1a1a1a@1:t=fill[bg_box]; ^
    [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110, ^
    drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70[video_text]; ^
    [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -c:a copy -shortest -y "output\%%~ni.mp4"
)
pause

@echo off
setlocal enabledelayedexpansion
IF NOT EXIST "output" MKDIR "output"

FOR %%i IN (*.mp3) DO (
    set "FILENAME=%%~ni"
    
    REM Cek apakah ada file gambar .jpg atau .png dengan nama yang sama
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else (
        REM Jika tidak ada gambar, pakai warna hitam
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
        set "V_FILTER=format=yuv420p"
    )

    ffmpeg !INPUT_V! -i "%%i" -filter_complex ^
    "[0:v]!V_FILTER![main]; ^
     [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
     [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box]; ^
     [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
     drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
     [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
echo --- PROSES SELESAI ---
pause

@echo off
setlocal enabledelayedexpansion

REM Membuat folder output jika belum ada, kalau sudah ada tidak akan error
if not exist "output" mkdir "output"

FOR %%i IN (*.mp3) DO (
    set "FILENAME=%%~ni"
    echo Sedang memproses: "!FILENAME!"
    
    REM Cek gambar (jpg/png/webp)
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
    ) else if exist "images.webp" (
        set "INPUT_V=-loop 1 -i "images.webp""
    ) else (
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
    )

    ffmpeg -y !INPUT_V! -i "%%i" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; ^
     [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
     [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box]; ^
     [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2, ^
     drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text]; ^
     [video_text][waves]overlay=x=0:y=H-60[final]" ^
    -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest "output\%%~ni.mp4"
)

echo --- SEMUA VIDEO BERHASIL DIRENDER ---
pause

Convert MP3 to MP4 with Image.txt

```batch
for %f in (*.mp3) do ffmpeg -loop 1 -i images.webp -i "%f" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "%~nf.mp4"
```

**Key changes made:**
- Changed `$file` to `%f` (using a single character variable name)
- Changed `"${file%.mp3}.mp4"` to `"%~nf.mp4"` - this extracts the filename without extension
- Changed variable references from `"$file"` to `"%f"`

**Note:** If you're putting this in a batch file, you'll need to use double percent signs (`%%f` instead of `%f`):

```batch
for %%f in (*.mp3) do ffmpeg -loop 1 -i images.webp -i "%%f" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "%%~nf.mp4"
```

The `%~nf` syntax extracts just the filename without the extension, which is the CMD equivalent of `${file%.mp3}` in bash.

Here's how to add a waveform to an existing video using ffmpeg. I'll provide several approaches depending on your needs:

## Method 1: Add waveform as an overlay (shows audio visualization)

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 output.mp4
```

**Parameter explanations:**
- `s=1280x200` - waveform size (width x height)
- `mode=cline` - centered line waveform (try `line`, `p2p`, or `cline`)
- `colors=white` - waveform color
- `overlay=0:H-h` - position at bottom (0 from left, H-h from top)

## Method 2: Create a new video with waveform and original video side-by-side

```batch
ffmpeg -i input.mp4 -filter_complex "[0:v]scale=640:-1[vleft];[0:a]showwaves=s=640x360:mode=cline[waves];[vleft][waves]hstack" -c:a copy output.mp4
```

## Method 3: Oscilloscope style waveform

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x200:mode=point:rate=25:colors=white@0.8[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 output.mp4
```

## Method 4: Full screen waveform (replaces video)

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white|blue" -c:v libx264 -c:a copy output.mp4
```

## For CMD/Batch file usage:

```batch
ffmpeg -i "input.mp4" -filter_complex "[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];[0:v][waves]overlay=0:H-h:shortest=1" -c:a copy -c:v libx264 "output.mp4"
```

**Additional options you can customize:**
- Change `colors=white` to any color (red, blue, cyan, or hex #RRGGBB)
- Adjust `s=1280x200` for different waveform sizes
- Try different modes: `mode=line`, `mode=p2p`, `mode=cline`, `mode=point`
- Add `:scale=sqrt` for logarithmic scale (better for quiet/loud variations)

The waveform will animate in real-time matching your audio throughout the video.

Here's how to add timestamps and titles to your video using ffmpeg:

## Method 1: Add timestamp (current time) and title overlay

```batch
ffmpeg -i input.mp4 -filter_complex "drawtext=text='Title: Your Video Title':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" -c:a copy -c:v libx264 output.mp4
```

## Method 2: Add filename as title and timestamp

```batch
ffmpeg -i input.mp4 -filter_complex "drawtext=text='%~nxf':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" -c:a copy -c:v libx264 output.mp4
```

## Method 3: Combined with waveform (from previous step)

```batch
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];[0:v][waves]overlay=0:H-h:shortest=1, drawtext=text='My Video Title':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" -c:a copy -c:v libx264 output.mp4
```

## Method 4: With custom formatting (date + time)

```batch
ffmpeg -i input.mp4 -filter_complex "drawtext=text='Title: My Awesome Video':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='Time: %{pts\:hms}':fontcolor=cyan:fontsize=18:x=10:y=40, drawtext=text='Date: 2026-02-16':fontcolor=cyan:fontsize=18:x=10:y=65" -c:a copy -c:v libx264 output.mp4
```

## Method 5: Add timestamp with background for better visibility

```batch
ffmpeg -i input.mp4 -filter_complex "[0:v]drawbox=x=0:y=0:w=400:h=100:color=black@0.5:t=fill, drawtext=text='My Video Title':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" -c:a copy -c:v libx264 output.mp4
```

## Complete CMD/batch file version with all features:

```batch
@echo off
set INPUT=input.mp4
set TITLE="My Video Title"
set OUTPUT=output_with_text.mp4

ffmpeg -i "%INPUT%" -filter_complex ^
"[0:a]showwaves=s=1280x200:mode=cline:rate=25:colors=white[waves];^
[0:v][waves]overlay=0:H-h:shortest=1,^
drawbox=x=0:y=0:w=400:h=100:color=black@0.5:t=fill,^
drawtext=text=%TITLE%:fontcolor=white:fontsize=24:x=10:y=10,^
drawtext=text='%%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" ^
-c:a copy -c:v libx264 "%OUTPUT%"
```

**Customization options:**
- `fontcolor`: white, yellow, red, blue, cyan, etc.
- `fontsize`: adjust as needed (18, 24, 36, etc.)
- `x` and `y`: position coordinates
- Add `:fontfile=C\:\\Windows\\Fonts\\arial.ttf` to use specific fonts
- Use `%{pts\:hms}` for timestamp in HH:MM:SS format
- Use `%{pts\:hms}` with different formatting: `%{pts\:hms}` shows as 01:23:45

**For filename as title in batch:**
```batch
ffmpeg -i "input.mp4" -filter_complex "drawtext=text='%%~nxf':fontcolor=white:fontsize=24:x=10:y=10, drawtext=text='%%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=40" -c:a copy -c:v libx264 "output.mp4"
```

Here's how to create a video with waveform at the bottom (side-by-side with timestamp/duration) and title centered:

## Complete Solution with Waveform + Timestamp/Duration + Centered Title

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[vmain];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=white[waves];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[0:a]volumedetect,ametadata=print:file=-,atempo=1.0,asplit[audio];^
[0:v]drawtext=text='Center Title':fontcolor=white:fontsize=36:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.5:shadowx=2:shadowy=2[title];^
[title][waves_bg]overlay=0:H-h[final]" ^
-map "[final]" -map 0:a -c:v libx264 -c:a copy -preset fast output.mp4
```

## Method 2: With Dynamic Timestamp and Duration Display

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1280x100:mode=cline:rate=25:colors=cyan[waves];^
color=c=black@0.7:s=1280x100,format=rgba[bg];^
[bg][waves]overlay=0:0[waves_bg];^
[scaled]drawtext=text='MY VIDEO TITLE':fontcolor=white:fontsize=40:fontweight=bold:x=(w-text_w)/2:y=(h/2)-50:shadowcolor=black@0.8:shadowx=3:shadowy=3[title];^
[title][waves_bg]overlay=0:H-h,^
drawtext=text='Time: %%{pts\:hms}':fontcolor=yellow:fontsize=18:x=10:y=H-80,^
drawtext=text='Duration: 00:02:30':fontcolor=green:fontsize=18:x=w-200:y=H-80" ^
-c:a copy -c:v libx264 output.mp4
```

## Method 3: Split Waveform with Left/Right Stereo Visualization

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=red[left];^
[0:a]showwaves=s=640x100:mode=cline:rate=25:colors=blue[right];^
color=c=black:s=1280x100,format=rgba[bg];^
[bg][left]overlay=0:0[bg_left];^
[bg_left][right]overlay=640:0[waves_bg];^
[scaled]drawtext=text='TITLE CENTERED':fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=10:y=10,^
drawtext=text='L':fontcolor=red:fontsize=14:x=10:y=H-130,^
drawtext=text='R':fontcolor=blue:fontsize=14:x=650:y=H-130[title];^
[title][waves_bg]overlay=0:H-h" ^
-c:a copy -c:v libx264 output_with_stereo_waves.mp4
```

## Method 4: Professional Layout with Borders and Labels

```batch
ffmpeg -i input.mp4 -filter_complex ^
"[0:v]scale=1280:720[main_video];^
[0:a]showwaves=s=1200x80:mode=cline:rate=25:colors=white@0.9[waves];^
color=c=#333333:s=1280x120,format=rgba[wave_container];^
[wave_container][waves]overlay=40:20[waves_padded];^
[main_video]drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.7:shadowx=3:shadowy=3,^
drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+30,^
drawbox=x=0:y=H-120:w=1280:h=120:color=#333333@0.9:t=fill[title_box];^
[title_box][waves_padded]overlay=0:H-120[final]" ^
-map "[final]" -map 0:a -c:v libx264 -preset fast -c:a copy professional_output.mp4
```

## Batch File Version with Customizable Settings

```batch
@echo off
set INPUT=input.mp4
set TITLE="Your Video Title"
set SUBTITLE="Additional Text"
set OUTPUT=final_video.mp4

ffmpeg -i "%INPUT%" -filter_complex ^
"[0:v]scale=1280:720[scaled];^
[0:a]showwaves=s=1200x100:mode=cline:rate=25:colors=white|cyan[waves];^
color=c=#222222:s=1280x120,format=rgba[bg];^
[bg][waves]overlay=40:10[waves_final];^
[scaled]drawtext=text=%TITLE%:fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=(h/2)-40:shadowcolor=black@0.6:shadowx=3:shadowy=3,^
drawtext=text=%SUBTITLE%:fontcolor=#AAAAAA:fontsize=24:x=(w-text_w)/2:y=(h/2)+20,^
drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=20:y=10,^
drawtext=text='Duration: 00:02:30':fontcolor=yellow:fontsize=16:x=w-180:y=10[video_with_text];^
[video_with_text][waves_final]overlay=0:H-120" ^
-c:a copy -c:v libx264 -preset fast "%OUTPUT%"

echo Done! Output saved as %OUTPUT%
```

## Key Features Explained:

- **Centered Title**: Using `x=(w-text_w)/2:y=(h-text_h)/2` positions text exactly in the middle
- **Waveform at Bottom**: Positioned with `overlay=0:H-h` or `overlay=0:H-120`
- **Timestamp**: Top-left corner showing current playback time
- **Duration**: Top-right corner showing total video length
- **Waveform Container**: Dark background panel for better visibility

**Customization Tips:**
- Adjust `fontsize` values to change text size
- Modify `colors=` in showwaves for different waveform colors
- Change `y=(h-text_h)/2-30` to move title up/down from exact center
- Use hex colors like `#FF5733` for custom colors

Here's how to merge your MP3 to MP4 conversion with the waveform, timestamp, and title features:

## Complete Solution: MP3 to MP4 with Waveform + Timestamp + Centered Title

```batch
@echo off
setlocal enabledelayedexpansion

:: Set your title (use %%~nf for filename as title, or set custom text)
set CUSTOM_TITLE=My Music Video

for %%f in (*.mp3) do (
    echo Processing: %%f
    
    ffmpeg -loop 1 -i images.webp -i "%%f" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1[bg];^
    [1:a]showwaves=s=1200x100:mode=cline:rate=25:colors=cyan|white[waves];^
    color=c=#222222:s=1280x120,format=rgba[wave_bg];^
    [wave_bg][waves]overlay=40:10[waves_final];^
    [bg]drawtext=text='%%~nf':fontcolor=white:fontsize=48:fontweight=bold:x=(w-text_w)/2:y=(h/2)-60:shadowcolor=black@0.8:shadowx=3:shadowy=3,^
    drawtext=text='Music Video':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h/2)+20,^
    drawtext=text='%%{pts\:hms}':fontcolor=yellow:fontsize=18:x=20:y=20,^
    drawtext=text='Duration: ???':fontcolor=green:fontsize=18:x=w-200:y=20[title_video];^
    [title_video][waves_final]overlay=0:H-120" ^
    -c:v libx264 -tune stillimage -preset fast -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "%%~nf_with_wave.mp4" -y
    
    echo Completed: %%~nf_with_wave.mp4
    echo ----------------------------------------
)

echo All files processed!
pause
```

## Enhanced Version with Duration Display and Better Formatting

```batch
@echo off
setlocal enabledelayedexpansion

:: Configuration
set WAVE_HEIGHT=120
set WAVE_COLORS=cyan|white
set VIDEO_WIDTH=1280
set VIDEO_HEIGHT=720
set TITLE_FONTSIZE=48
set SUBTITLE_FONTSIZE=24
set TIMESTAMP_FONTSIZE=16

for %%f in (*.mp3) do (
    echo ========================================
    echo Processing: %%~nf
    echo ========================================
    
    :: Get duration using ffprobe
    for /f "tokens=*" %%a in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%%f"') do set DURATION=%%a
    
    :: Convert duration to HH:MM:SS format
    set /a HOURS=!DURATION:/=! / 3600
    set /a MINUTES=(!DURATION:/=! %% 3600) / 60
    set /a SECONDS=!DURATION:/=! %% 60
    if !HOURS! lss 10 set HOURS=0!HOURS!
    if !MINUTES! lss 10 set MINUTES=0!MINUTES!
    if !SECONDS! lss 10 set SECONDS=0!SECONDS!
    set DURATION_FORMATTED=!HOURS!:!MINUTES!:!SECONDS!
    
    ffmpeg -loop 1 -i images.webp -i "%%f" -filter_complex ^
    "[0:v]scale=%VIDEO_WIDTH%:%VIDEO_HEIGHT%:force_original_aspect_ratio=increase,crop=%VIDEO_WIDTH%:%VIDEO_HEIGHT%,pad=%VIDEO_WIDTH%:%VIDEO_HEIGHT%:(ow-iw)/2:(oh-ih)/2,setsar=1[bg];^
    [1:a]showwaves=s=%VIDEO_WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=%WAVE_COLORS%[waves];^
    color=c=#1a1a1a:s=%VIDEO_WIDTH%x%WAVE_HEIGHT%,format=rgba[wave_bg];^
    [wave_bg][waves]overlay=0:0[waves_final];^
    [bg]drawtext=text='%%~nf':fontcolor=white:fontsize=%TITLE_FONTSIZE%:fontweight=bold:x=(w-text_w)/2:y=((h-%WAVE_HEIGHT%)/2)-40:shadowcolor=black@0.8:shadowx=3:shadowy=3,^
    drawtext=text='Audio Visualization':fontcolor=#AAAAAA:fontsize=%SUBTITLE_FONTSIZE%:x=(w-text_w)/2:y=((h-%WAVE_HEIGHT%)/2)+30,^
    drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=%TIMESTAMP_FONTSIZE%:x=20:y=20,^
    drawtext=text='!DURATION_FORMATTED!':fontcolor=green:fontsize=%TIMESTAMP_FONTSIZE%:x=w-120:y=20,^
    drawbox=x=0:y=H-%WAVE_HEIGHT%:w=%VIDEO_WIDTH%:h=%WAVE_HEIGHT%:color=#1a1a1a@0.95:t=fill[with_box];^
    [with_box][waves_final]overlay=0:H-%WAVE_HEIGHT%" ^
    -c:v libx264 -tune stillimage -preset fast -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "%%~nf_waveform.mp4" -y
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] Created: %%~nf_waveform.mp4
    ) else (
        echo [ERROR] Failed to process: %%~nf
    )
    echo ----------------------------------------
)

echo.
echo All conversions completed!
pause
```

## Simplified Version with Basic Features

```batch
@echo off
for %%f in (*.mp3) do (
    echo Converting: %%f
    
    ffmpeg -loop 1 -i images.webp -i "%%f" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[bg];^
    [1:a]showwaves=s=1280x100:mode=cline:rate=25:colors=white[waves];^
    color=c=black:s=1280x100,format=rgba[wave_bg];^
    [wave_bg][waves]overlay=0:0[waves_final];^
    [bg]drawtext=text='%%~nf':fontcolor=white:fontsize=36:fontweight=bold:x=(w-text_w)/2:y=((h-100)/2)-20,^
    drawtext=text='%%{pts\:hms}':fontcolor=yellow:fontsize=14:x=10:y=10[title_video];^
    [title_video][waves_final]overlay=0:H-100" ^
    -c:v libx264 -tune stillimage -preset fast -c:a aac -pix_fmt yuv420p -shortest "%%~nf_wave.mp4" -y
    
    echo Done: %%~nf_wave.mp4
)
pause
```

## Advanced Version with Stereo Waveform and Custom Branding

```batch
@echo off
setlocal enabledelayedexpansion

:: Configuration
set LOGO_FILE=logo.png  (optional, remove if not needed)
set BRAND_COLOR=#00BFFF
set BG_COLOR=#0A0A0A

for %%f in (*.mp3) do (
    echo Creating video for: %%~nf
    
    :: Build filter complex based on logo availability
    if exist "%LOGO_FILE%" (
        set LOGO_FILTER=;[1:0]scale=60:-1[logo];[title_video][logo]overlay=10:10
    ) else (
        set LOGO_FILTER=
    )
    
    ffmpeg -loop 1 -i images.webp -i "%%f" %LOGO_FILE% -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[bg];^
    [1:a]asplit[audio1][audio2];^
    [audio1]showwaves=s=600x80:mode=cline:rate=25:colors=red[Lwaves];^
    [audio2]showwaves=s=600x80:mode=cline:rate=25:colors=blue[Rwaves];^
    color=c=%BG_COLOR%:s=1280x120,format=rgba[wave_bg];^
    [wave_bg][Lwaves]overlay=40:20[withL];^
    [withL][Rwaves]overlay=640:20[waves_final];^
    [bg]drawtext=text='%%~nf':fontcolor=white:fontsize=44:fontweight=bold:x=(w-text_w)/2:y=((h-120)/2)-50,^
    drawtext=text='Audio Waveform Visualization':fontcolor=%BRAND_COLOR%:fontsize=22:x=(w-text_w)/2:y=((h-120)/2)+20,^
    drawtext=text='L':fontcolor=red:fontsize=14:x=40:y=H-40,^
    drawtext=text='R':fontcolor=blue:fontsize=14:x=680:y=H-40,^
    drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=14:x=20:y=20,^
    drawtext=text='%%~nf':fontcolor=gray:fontsize=12:x=w-150:y=H-20[title_video]%LOGO_FILTER%;^
    [title_video][waves_final]overlay=0:H-120" ^
    -c:v libx264 -tune stillimage -preset fast -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "%%~nf_pro.mp4" -y
    
    echo [OK] %%~nf_pro.mp4
)

echo All videos created successfully!
pause
```

## Key Features Explained:

1. **Preserves original MP3 to MP4 conversion** with `-loop 1 -i images.webp`
2. **Adds waveform** at the bottom with customizable colors
3. **Centered title** showing filename (`%%~nf`)
4. **Timestamp** in top-left
5. **Duration** in top-right (calculated from MP3)
6. **Proper aspect ratio handling** with `crop` and `pad` filters
7. **Stereo visualization** option in advanced version

Choose the version that best fits your needs. The first one is the most straightforward integration with your original command.
