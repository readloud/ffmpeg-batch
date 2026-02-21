## Animated line waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showwaves=s=1280x720:mode=line:colors=white,format=yuv420p[v]" \
-map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```
## Basic Waveform with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x720:mode=cline:colors=white[v]; [0:v][v]overlay=format=auto[outv]" -map "[outv]" -map 1:a -c:v libx264 -preset fast -crf 18 -c:a copy -shortest output.mp4
```

## Basic Waveform with Transparency with image
```
ffmpeg -loop 1 -i image.jpeg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x200:mode=cline:colors=white:rate=25[sw];  [sw]format=rgba,colorchannelmixer=aa=0.8[v]; [0:v][v]overlay=x=0:y=H-h:eval=init[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output.mp4
```
## Basic Waveform with Transparency
```
ffmpeg -loop 1 -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x720:mode=cline:colors=white[v]" -map "[v]" -map 1:a -c:v libx264 -c:a copy -shortest output.mp4
```
## 3D Wave
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=1280x720:m=ascope[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_3dwave.mp4
```

## 3D Wave with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]avectorscope=s=1280x720:m=ascope[v];[0:v][v]overlay=shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_3dwave_bg.mp4
```

## Split Channel
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:split_channels=1[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_black.mp4
```

## Circular Wave Solid Backgroung(Note escaped commas)
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```
## Circular Wave Static Image(Note escaped commas)
```
ffmpeg -i audio.mp3 -i background.png -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p[v];[v]format=rgba^, geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y^,X-W/2))^,W)^, H-2*hypot(0.5*H-Y^,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y^,X-W/2))^,W)^, H-2*hypot(0.5*H-Y^,X-W/2))'[vout];[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```

## Circular Wave Crop Background
```
ffmpeg -i audio.mp3 -i beach1.jpg -filter_complex "[1:v]crop=1280:720[bg];[0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a];[bg][a]overlay=(W-w)/2:(H-h)/2" -c:v libx264 -c:a copy -shortest ouput.mp4 -y
```

## Circular Wave Full Background
```
ffmpeg -i audio.mp3 -i beach1.jpg -filter_complex "[1:v]scale=1280:720[bg];[0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a];[bg][a]overlay=(W-w)/2:(H-h)/2" -c:v libx264 -c:a copy -shortest ouput.mp4 -y
```

## Classic Bars
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showspectrum=s=1280x720:mode=combined[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest spectrum_black.mp4
```

## Classic Bars with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showspectrum=s=1280x400:mode=combined[v];[0:v][v]overlay=y=H-h:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest spectrum_bg.mp4
```

## Dots/Points --
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=p2p[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest dots_black.mp4
```

## Dots with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x720:mode=p2p[v];[0:v][v]overlay=shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest dots_bg.mp4
```

## Double Wave --
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:split_channels=1:colors=white|red,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy double_wave.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:split_channels=1[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest double_black.mp4
```

## Double Wave with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x720:split_channels=1[v];[0:v][v]overlay=shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest double_bg.mp4
```

## Filled Curve##
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=filled[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest filled_black.mp4
```

## Filled Curve with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x300:mode=filled[v];[0:v][v]overlay=y=H-h:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest filled_bg.mp4
```

## Heartbeat ECG
```
ffmpeg -i input_audio.mp3 -filter_complex "showwaves=s=1280x720:colors=green:draw=line" -c:v libx264 -t 10 output_ecg.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:r=25[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest ecg_black.mp4
```

## Heartbeat ECG with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x200:mode=cline[sw];[0:v][sw]overlay=y=H-h:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest ecg_bg.mp4
```

## Line Graph
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest line_black.mp4
```

## Line Graph with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x300:mode=line[v];[0:v][v]overlay=y=H-150:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest line_bg.mp4
```

## Minimalist --
### Small minimalist waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"showwaves=s=1280x240:mode=line:colors=white:split_channels=0" \
-c:v libx264 -pix_fmt yuv420p output.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=point[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest minimalist_black.mp4
```

## Minimalist with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=1280x100:mode=point[v];[0:v][v]overlay=y=H-100:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest minimalist_bg.mp4
```

## Retro ARC##
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showvolume=f=0.5:w=1280:h=50[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest retro_arc_black.mp4
```

## Retro ARC with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showvolume=f=0.5:w=1280:h=50[v];[0:v][v]overlay=y=0:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest retro_arc_bg.mp4
```

## Retro VU
### Animated VU meter
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showvolume=b=5:w=1280:h=60:o=h:v=1:p=0.5:t=0:f=0" -c:v libx264 output_vumeter.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showvolume=b=4:w=1280:h=40[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest retro_vu_black.mp4
```

## Retro VU with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showvolume=b=4:w=400:h=50[v];[0:v][v]overlay=x=(W-w)/2:y=H-100:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest retro_vu_bg.mp4
```

## Spectrum Analyzer
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showspectrum=s=1920x1080:mode=combined:color=fire:scale=log[v]" -map "[v]" -map 0:a -c:v libx264 -t 30 combined.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=1280x480:zoom=1.5[v]" -map "[v]" -map 0:a -c:v libx264 output_vector.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showfrequency=s=1280x720[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest freq_black.mp4
```

## Spectrum with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showfrequency=s=1280x400[v];[0:v][v]overlay=y=H-h:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest freq_bg.mp4
```

## Split Channel with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showwaves=s=720x720:mode=line[sw];[0:v][sw]overlay=(W-w)/2:(H-h)/2:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_bg.mp4
```

## Static Waveform (Audio Only)
```
ffmpeg -i audio.mp3 -filter_complex "showwaves=s=1280x720:mode=line:colors=white" -c:a copy output.mp4
```
```
ffmpeg -i audio.mp3 -filter_complex "showwaves=s=1280x720:colors=white:mode=line" -c:v libx264 output_static.mp4
```
```
ffmpeg -loop 1 -i input.jpg -i audio.mp3 -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest output.mp4
```

## Stereo Bars
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showcqt=s=1280x720[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest cqt_black.mp4
```

## Stereo Bars with Image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex "[1:a]showcqt=s=1280x300[v];[0:v][v]overlay=y=H-h:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest cqt_bg.mp4
```

## Symmetrical Waveform
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:colors=white:rate=30[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy -pix_fmt yuv420p -shortest symmetrical.mp4
```
## Vector Scope
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=480x480:zoom=1.5[v]" -map "[v]" -map 0:a -c:v libx264 output_vector.mp4
```
---

### Complex Overlay with Text
```
ffmpeg -i output.mp4 -filter_complex "drawbox=x=0:y=h-20:w=iw*t/291:h=20:color=gray@0.5:t=fill,drawtext=fontfile=KGTeacherJordan.ttf:text='Darso':fontsize=48:fontcolor=white:x=(w-tw)/2:y=h-th-2,drawtext=fontfile=Ritual of the Witch.ttf:text='Mawar Bodas':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2,drawtext=fontfile=Super Wonder.ttf: text='%{pts\:hms}': x=(w-text_w-10): y=(h-text_h-10): fontsize=20: fontcolor=white: box=1: boxcolor=black@0.5,color=c=white:s=1280x20[bar];[0][bar]overlay=-w+(w/291)*t:H-h:shortest=1" -t 5 -y Mawar_Bodas.mp4
```

## Various Waveform Overlays
```
ffmpeg -y -i audio.mp3 -loop 1 -i beach1.jpg -filter_complex "[0:a]showwaves=s=1920x1080:mode=cline:rate=30:colors=white|green|yellow|red[waveform]; [1:v]scale=1920:1080[bg]; [bg][waveform]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:shortest=1" -map 0:a -c:v libx264 -c:a copy -shortest showave_waveform.mp4
```
```
ffmpeg -i audio.mp3 -loop 1 -i beach2.jpg -filter_complex "[0:a]aformat=channel_layouts=mono,showwaves=s=1920x1080:mode=cline:rate=30:colors=white[waveform]; [1:v]scale=1920:1080[bg]; [bg][waveform]overlay=shortest=1" -pix_fmt yuv420p -r 30 -tune fastdecode -y overlay_waveform.mp4
```
```
ffmpeg -i audio.mp3 -loop 1 -i beach3.jpg -filter_complex "[0:a]aformat=channel_layouts=mono,showwaves=s=1920x1080:mode=cline:rate=30:colors=cyan|blue|red[waveform];[1:v]scale=1920:1080[bg]; [bg][waveform]overlay=shortest=1" -pix_fmt yuv420p -tune fastdecode -r 30 -y symetrial_waveform.mp4
```
```
ffmpeg -i audio.mp3 -loop 1 -i beach4.jpg -filter_complex "[0:a]aformat=channel_layouts=mono,showwaves=s=1920x1080:mode=line:rate=30:colors=white[waveform];[1:v]scale=1920:1080[bg]; [bg][waveform]overlay=shortest=1" -pix_fmt yuv420p -tune fastdecode -r 30 -y spectrum_waveform.mp4
```
---
## 1. Basic Overlay on Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=white[v]; \
 [0:v][v]overlay=(W-w)/2:(H-h)/2:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -shortest output.mp4
```
**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=line:colors=white[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```
**Simple overlay on background
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=white[v]; \
 [0:v][v]overlay=(W-w)/2:(H-h)/2:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -shortest output.mp4
```
**With scaling
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=line:colors=white[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

## 2. Cline Mode with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=cline:colors=white[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```
**Center line waveform over image
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=white[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```
**With transparency
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=white,format=rgba,colorchannelmixer=aa=0.8[wave]; \
 [0:v][wave]overlay=x=0:y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```
**Animated cline waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"showwaves=s=1280x720:mode=cline:colors=white:rate=25" \
-c:v libx264 -pix_fmt yuv420p output.mp4
```
**Static cline image
```
ffmpeg -i audio.mp3 -filter_complex \
"showwavespic=s=1280x720:mode=cline:colors=white" -frames:v 1 output.png
```

## 3. Colored Waveform with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1920x1080:mode=cline:colors=white|green|yellow|red[waveform]; \
 [0:v]scale=1920:1080[bg]; [bg][waveform]overlay=shortest=1" \
-map 0:a -c:v libx264 -shortest output.mp4
```
**Split channels on background
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:split_channels=1:colors=blue|red[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1920x1080:r=30[bg]; \
 [0:a]showwaves=s=1920x1080:mode=cline:colors=white|green|yellow|red[waveform]; \
 [bg][waveform]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```
**Multi-color waveform overlay
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1920x1080:mode=cline:colors=white|green|yellow|red[waveform]; \
 [0:v]scale=1920:1080[bg]; [bg][waveform]overlay=shortest=1" \
-map 0:a -c:v libx264 -shortest output.mp4
```

**Split channels colored
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:split_channels=1:colors=blue|yellow[wave]; \
 [0:v][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```
**Multi-color waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"showwaves=size=1280x720:colors=cyan|yellow|white:mode=bar:split_channels=1" \
-c:v libx264 -pix_fmt yuv420p output.mp4
```
**Split channels stereo
```
ffmpeg -i audio.mp3 -filter_complex \
"showwaves=s=1280x720:split_channels=1:colors=blue|red" \
-c:v libx264 -pix_fmt yuv420p output.mp4
```

## 4. Waveform with Transparency → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=white,format=rgba,colorchannelmixer=aa=0.8[wave]; \
 [0:v][wave]overlay=x=0:y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=cline:colors=white,format=rgba,colorchannelmixer=aa=0.8[wave]; \
 [bg][wave]overlay=x=0:y=H-h:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

## 5. Waveform at Bottom Position → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=x=0:y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [bg][wave]overlay=x=0:y=H-h:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

**Waveform at bottom
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=x=0:y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```
**Waveform at top
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=x=0:y=0:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

## 6. Split Channels Stereo with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:split_channels=1:colors=blue|yellow[wave]; \
 [0:v][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:split_channels=1:colors=blue|yellow[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

## 7. Moving Waveform with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[0]scale=1280x720[bg]; \
 [1:a]showwavespic=s=8000x720:mode=line:colors=white,format=yuva420p[wave]; \
 [bg][wave]overlay=x='W-w*t/duration':y=0:shortest=1" \
-c:v libx264 -shortest output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwavespic=s=8000x720:mode=line:colors=white,format=yuva420p[wave]; \
 [bg][wave]overlay=x='W-w*t/duration':y=(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```
**Horizontal scrolling waveform
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[0]scale=1280x720[bg]; \
 [1:a]showwavespic=s=8000x720:mode=line:colors=white,format=yuva420p[wave]; \
 [bg][wave]overlay=x='W-w*t/duration':y=0:shortest=1" \
-c:v libx264 -shortest output.mp4
```
**Progressive reveal
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwavespic=s=8000x720:colors=white[wave]; \
 [0:v][wave]overlay=x='(W-w)*t/duration':y=(H-h)/2,format=yuv420p[outv]" \
-map "[outv]" -map 2:a -c:v libx264 -shortest output.mp4
```

## 8. Glow Effect with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; \
 [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; \
 [top][blurred]blend=all_mode=addition[glow]; \
 [0:v][glow]overlay=y=H-h:shortest=1[final]" \
-map "[final]" -map 1:a -c:v libx264 -pix_fmt yuv420p output_glow.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; \
 [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; \
 [top][blurred]blend=all_mode=addition[glow]; \
 [bg][glow]overlay=y=(H-h)/2:shortest=1,format=yuv420p[final]" \
-map "[final]" -map 0:a -c:v libx264 -c:a copy -shortest output_glow.mp4
```

**Waveform with glow effect
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; \
 [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; \
 [top][blurred]blend=all_mode=addition[glow]; \
 [0:v][glow]overlay=y=H-h:shortest=1[final]" \
-map "[final]" -map 1:a -c:v libx264 -pix_fmt yuv420p output_glow.mp4
```

## 9. Circular Waveform with Image → Black Background
**Original (with image):**
```
ffmpeg -i audio.mp3 -i background.jpg -filter_complex \
"[1:v]scale=1280:720[bg]; \
 [0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full, \
 geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))': \
 a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a]; \
 [bg][a]overlay=(W-w)/2:(H-h)/2:shortest=1" \
-c:v libx264 -c:a copy -shortest output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280:720:r=30[bg]; \
 [0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full, \
 geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))': \
 a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a]; \
 [bg][a]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

**Circular waveform overlay
```
ffmpeg -i audio.mp3 -i background.jpg -filter_complex \
"[1:v]scale=1280:720[bg]; \
 [0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full, \
 geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))': \
 a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a]; \
 [bg][a]overlay=(W-w)/2:(H-h)/2:shortest=1" \
-c:v libx264 -c:a copy -shortest output.mp4
```

## 10. Spectrum with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showspectrum=s=1280x720:mode=combined:color=intensity:scale=log[v]; \
 [0:v]scale=1280:720[bg]; [bg][v]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -shortest output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showspectrum=s=1280x720:mode=combined:color=intensity:scale=log[v]; \
 [bg][v]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

**Spectrum analyzer on background
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showspectrum=s=1280x720:mode=combined:color=intensity:scale=log[v]; \
 [0:v]scale=1280:720[bg]; [bg][v]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -shortest output.mp4
```

**Frequency spectrum
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showspectrum=s=1280x720:mode=combined:color=intensity:scale=log[v]" \
-map "[v]" -map 0:a -c:v libx264 output_spectrum.mp4
```
**With scrolling
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showspectrum=s=1280x720:mode=line:color=intensity:slide=scroll:fps=30[v]" \
-map "[v]" output_video.mp4
```

## 11. ECG with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=green[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output_ecg.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=line:colors=green[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output_ecg.mp4
```

**ECG style on background
```
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=green[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output_ecg.mp4
```

**ECG line waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showwaves=s=1280x720:mode=line:colors=green[v]" \
-map "[v]" -c:v libx264 output_ecg.mp4
```

**Scrolling ECG
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showwaves=s=1280x720:mode=line:colors=red:draw_mode=scroll[v]" \
-map "[v]" -c:v libx264 ecg_scrolling.mp4
```

## 12. Retro Style with Image → Black Background
**Original (with image):**
```
ffmpeg -loop 1 -i bg.jpg -i input_audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=00ff00:rate=30[wv]; \
 [0:v][wv]overlay=shortest=1" \
-c:v libx264 -pix_fmt yuv420p -c:a copy output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=cline:colors=00ff00:rate=30[wv]; \
 [bg][wv]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

**Retro green waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"showwaves=s=1280x720:mode=cline:colors=00ff00:rate=30[v]" \
-map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

**Retro with compand effect
```
ffmpeg -i audio.mp3 -filter_complex \
"aformat=channel_layouts=mono,compand,showwaves=s=1280x720:mode=cline:colors=white[v]" \
-map "[v]" -c:v libx264 output.mp4
```

## 13. Dots/Points Mode with Image → Black Background
**Original (with image):**
```
ffmpeg -i audio.mp3 -i background.png -filter_complex \
"[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p[v]; \
 [1:v][v]overlay=(W-w)/2:(H-h)/2[outv]" \
-map "[outv]" -map 0:a -pix_fmt yuv420p output.mp4
```

**Converted (black background):**
```
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=yuva420p[v]; \
 [bg][v]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

*** Particle/points waveform
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=colors=white:scale=sqrt:mode=p2p,format=yuva420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```
---

#Basic Example:

### 1. Double Waveform Image
```
ffmpeg -i input.mp3 -filter_complex "showwavespic=s=640x240:split_channels=1:colors=white|white" -frames:v 1 output.png

```

### 2. Basic Waveform Image
```
ffmpeg -i input.mp3 -filter_complex "showwavespic=s=640x120" -frames:v 1 output.png
```

### 3. Split Channel Image
```
ffmpeg -i input.mp3 -filter_complex "showwavespic=s=640x240:split_channels=1" -frames:v 1 output.png
```

### 4. Spectrogram Image
```
ffmpeg -i input_file.mp3 -lavfi showspectrumpic=s=800x400:mode=separate spectrogram.png
```

### 5. Stereo Waveform Images
**Default colors
```
ffmpeg -i input_audio.mp3 -filter_complex "showwavespic=s=1280x720" -frames:v 1 output.png
```
**Custom colors
```
ffmpeg -i input_audio.mp3 -filter_complex "showwavespic=s=1280x720:colors=blue|yellow" -frames:v 1 output.png
```
**Split channels vertically
```
ffmpeg -i input_audio.mp3 -filter_complex "showwavespic=split_channels=1:s=1024x800" -frames:v 1 output.png
```
**With scale adjustment
```
ffmpeg -i input_audio.mp3 -lavfi showwavespic=scale=log output.png
```
### 6. Overlay Waveform on Background (Static)
```
ffmpeg -i audio.mp3 -i background.jpg -filter_complex \
"[0:a]aformat=channel_layouts=mono,showwavespic=s=1280x200:colors=cyan:mode=cline[waveform]; \
 [1:v][waveform]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" \
-frames:v 1 output.png
```

### 7. Colored Bars Image
```
ffmpeg -i audio.mp3 -filter_complex \
"aformat=channel_layouts=mono,showwavespic=s=1280x300:colors=yellow|red:scale=sqrt" \
-frames:v 1 output.png
```

### 8. Transparent Background Image
```
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=640x120:colors=white:bg=0x00000000" -frames:v 1 output.png
```

### 9. Filled Curve Image
```
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=1280x240:colors=cyan|yellow" -frames:v 1 output.png
```

### 10. Dark Background Image
```
ffmpeg -i audio.mp3 -filter_complex "color=s=1280x240:c=black[bg];[0:a]showwavespic=s=1280x240:colors=white[fg];[bg][fg]overlay" -frames:v 1 output.png
```

### 11. Line Graph Image
```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwavespic=s=1280x720:colors=white|white:mode=line[v]" -map "[v]" -frames:v 1 output.png
```

### 12. Retro Waveform Image
```
ffmpeg -i input_audio.mp3 -filter_complex \
"showwavespic=s=1280x720:mode=cline:colors=orange" -frames:v 1 output_image.png

ffmpeg -i input_audio.mp3 -filter_complex \
"showwavespic=s=1280x720:colors=green[v]" -map "[v]" -frames:v 1 retro_waveform.png
```

### 13. Minimalist Waveform Image
```
ffmpeg -i input.mp3 -filter_complex "aformat=channel_layouts=mono,showwavespic=s=640x120:colors=white" -frames:v 1 output.png
```

### 14. Symmetrical Waveform Image
```
ffmpeg -i input.mp3 -filter_complex "aformat=channel_layouts=mono,showwavespic=s=1280x360:colors=white" -frames:v 1 output.png
```

### 15. ECG Frame Extraction
```
ffmpeg -i input_ecg_video.mp4 -vf fps=1 frame_%04d.png
```

### 16. Waveform Picture for Moving Effect
```
ffmpeg -i input.mp3 -filter_complex "aformat=channel_layouts=mono,showwavespic=s=1280x720:colors=white" -frames:v 1 wavespic.png
```
### 17. Static minimalist
```
ffmpeg -i audio.mp3 -filter_complex \
"aformat=channel_layouts=mono,showwavespic=s=640x120:colors=white" -frames:v 1 output.png
```

### 18. Advanced Colored Waveform Image
```
ffmpeg -i input.mp3 -filter_complex \
"[0:a]aformat=channel_layouts=mono, \
compand=gain=-6, \
showwavespic=s=600x120:colors=#9cf42f[fg]; \
color=s=600x120:color=#44582c, \
drawgrid=width=iw/10:height=ih/5:color=#9cf42f@0.1[bg]; \
[bg][fg]overlay=format=auto,drawbox=x=(iw-w)/2:y=(ih-h)/2:w=iw:h=1:color=#9cf42f" \
-frames:v 1 output.png
```

### 19. Advanced Waveform
```
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]aformat=channel_layouts=mono, \
compand=gain=-6, \
showwavespic=s=600x120:colors=#9cf42f[fg]; \
color=s=600x120:color=#44582c, \
drawgrid=width=iw/10:height=ih/5:color=#9cf42f@0.1[bg]; \
[bg][fg]overlay=format=auto,drawbox=x=(iw-w)/2:y=(ih-h)/2:w=iw:h=1:color=#9cf42f" \
-frames:v 1 output.png
```
---

**Animated Video from Image
```
ffmpeg -loop 1 -i image.png -vf "zoompan=z='zoom+0.001':d=125" -t 5 output.mp4
ffmpeg -loop 1 -i input.png -vf "zoompan=z='min(zoom+0.0005,1.5)':d=125" -c:v libx264 -t 10 -pix_fmt yuv420p output.mp4
ffmpeg -i input.mp4 -vf "fps=15,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" output.gif
```
```
ffmpeg -i background.mp4 -i overlay.png -filter_complex "overlay=x=0:y=0" output.mp4
```

**Classic Bars - Video Processing
```
ffmpeg -i input.mp4 -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -c:a copy output.mp4
```
```

ffmpeg -i input.mp4 -vf "pad=ih*16/9:ih:(ow-iw)/2:0:black" -c:a copy output.mp4
```

**Classic Bars - SMPTE
```
ffmpeg -f lavfi -i smptebars=size=1920x1080:rate=30 -f lavfi -i sine=frequency=1000:duration=10 -c:v libx264 -t 10 -pix_fmt yuv420p colorbars.mp4
```

**Color Generation
```
ffmpeg -f lavfi -i color=c=black:s=1280x720:r=30:d=10 output.mp4
```
```
ffmpeg -f lavfi -i color=c=white:s=1920x1080:r=24 -i input_with_transparency.png -filter_complex "[0:v][1:v]overlay=shortest=1,format=yuv420p[out]" -map "[out]" output.mp4
```

**Color Correction
```
ffmpeg -i INPUT.MOV -vf eq=brightness=0.06:saturation=2 -c:a copy OUTPUT.MOV
```
```
ffmpeg -i input.mp4 -vf curves=blue='0/0 0.5/0.58 1/1' output.mp4
```

**Dots/Points
```
ffmpeg -i input.mp4 -vf "drawbox=x=100:y=100:w=5:h=5:color=white@1.0:t=fill" -c:a copy output.mp4
```
```
ffmpeg -i input.mp4 -vf "drawtext=fontfile=Arial.ttf:text='.':x=100:y=100:fontsize=24:fontcolor=white" -c:a copy output.mp4
```

**Glow Effect (Multiline)
```
ffmpeg -i input_video.mp4 -i input_audio.mp3 -filter_complex ^
"[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; ^
 [v]split[top][bottom]; ^
 [bottom]gblur=sigma=10[blurred]; ^
 [top][blurred]blend=all_mode=addition[glow]; ^
 [0:v][glow]overlay=y=H-h[final]" ^
-map "[final]" -map 1:a -c:a copy -pix_fmt yuv420p -y output_glow.mp4
```

**Gradient
```
ffmpeg -f lavfi -i gradients=type=linear:size=1280x720:rate=30 -t 10 output.mp4
ffmpeg -f lavfi -i gradients=type=radial:size=1280x720:rate=30 -t 10 radial.mp4
```

**Live ECG (Note escaped commas)
```
ffmpeg -f lavfi -i color=c=black:s=1280x720:rate=30 -vf ^
"drawtext=fontfile=path/to/font.ttf:text=' ':fontcolor=green:fontsize=24:^
x='w-mod(t*200^,w+tw)':y=h/2+sin(t*10)*100^, ^
drawtext=fontfile=path/to/font.ttf:text=' ':fontcolor=green:fontsize=24:^
x='w-mod(t*200+100^,w+tw)':y=h/2+sin(t*10)*100" ^
-t 10 -pix_fmt yuv420p output_ecg.mp4
```

**Split Screen
```
ffmpeg -i input.mkv -filter_complex "[0:v]crop=iw/2:ih:0:0[left];[0:v]crop=iw/2:ih:ow:0[right]" -map "[left]" -map 0:a left.mp4 -map "[right]" -map 0:a right.mp4
```
```
ffmpeg -i in.wav -filter_complex "channelsplit=channel_layout=stereo[L][R]" -map "[L]" left.wav -map "[R]" right.wav
```
```
ffmpeg -i input1.mp4 -i input2.mp4 -filter_complex "[0:v][1:v]vstack[v]" -map "[v]" -map 0:a:0 -map 1:a:0 -c:v libx264 -c:a aac output.mp4
```

**Spectrogram
```
ffmpeg -i audio.mp3 -lavfi showspectrumpic=s=800x400:mode=separate spectrogram.png
```

**VU Meter
```
ffmpeg -i input.mp4 -vf "showvolume=f=1:w=100:h=480:b=2:s=1:dm=1" -c:a copy output.mp4
```
```
ffmpeg -f lavfi -i "amovie=audio.mp3,showvolume=f=1:w=100:h=480:c=yellow:dm=1[v]" -map "[v]" -c:v libx264 -t 30 vu_meter_only.mp4
```

**Overlay Video (Multiline)
```
ffmpeg -i input_video.mp4 -i background_image.jpg -filter_complex ^
"[0:a]aformat=channel_layouts=mono, ^
showwaves=s=1280x720:mode=cline:rate=30:colors=white, ^
colorkey=0x000000:0.01:0.1,format=yuva420p[wave]; ^
[1:v]scale=1280:720[bg]; ^
[bg][wave]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:shortest=1[outv]" ^
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output_video.mp4
```
```
ffmpeg -i input_video.mp4 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:colors=white,format=yuva420p[wave];[0:v][wave]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[outv]" -map "[outv]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

**Wave bottom of a video
```
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x202:mode=line[waveform];[0:v][waveform]overlay=0:H-h" -c:a copy output.mp4
```

Waveform Colors: showwaves=s=1280x202:mode=line:colors=#25d3d0
Waveform Style (Mode): showwaves=s=1280x202:mode=p2p:colors=white
cline (colored line), p2p (peaks to peaks, a bar-like look), or point.
Drawing Scale: showwaves=s=1280x202:mode=line:draw=full

**Background Color
```
ffmpeg -i input.mp3 -f lavfi -i color=c=#7925d3:s=1280x720 -filter_complex "[0:a]showwaves=s=1280x202:colors=#25d3d0:draw=full:mode=cline[waveform];[1:v][waveform]overlay=0:H-h,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```
