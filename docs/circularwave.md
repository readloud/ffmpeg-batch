**Circular Wave**

**1. Version Without Image (Black Background)**
This script uses the `avectorscope` filter in `circular` mode to create a circle that pulses with the bass beats.

ffmpeg -i audio.mp3 -filter_complex \
"[0:a]avectorscope=s=1280x720:m=circular:colors=white:zoom=1.5[v]" \
-map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_black.mp4

**2. Version With Background Image**
Here we add an image, then overlay the audio circle exactly in the center of the image.

ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=white:zoom=1.5[sw]; \
 [0:v][sw]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_bg.mp4

**Explanation of Key Parameters:**
`m=circular`: Changes the visualization shape to a circle.
`zoom=1.5`: Adjusts the circle's sensitivity. The larger the number, the wider the circle's "explosion" when the audio intensifies.
`s=720x720`: We create a square canvas for the waveform (equal sides) so the circle is perfect, not oval.
`overlay=x=(W-w)/2:y=(H-h)/2`: Standard FFmpeg math formula to place an object exactly in the center of the screen horizontally and vertically.

**Pro Tips:**
If you want the circle to appear slightly transparent so the background image peeks through, add the `format=rgba,colorchannelmixer=aa=0.6` filter before the overlay part like this:
`[1:a]avectorscope=s=720x720:m=circular:colors=white[sw]; [sw]format=rgba,colorchannelmixer=aa=0.6[sw_trans]; [0:v][sw_trans]overlay=...`

**Rotating Circular Waveform**

ffmpeg -loop 1 -i audio.jpg -i audio.mp3 -filter_complex "[1:a]avectorscope=s=720x720:m=circular:colors=white:zoom=1.5[sw];[sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot];[0:v][rot]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[outv]" -map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_rotating.mp4

**Explanation of the "Magic" Behind Rotation:**
`rotate=a=t*0.5`: This part controls the rotation speed.
`t` is the time variable (seconds).
`0.5` is the speed. To make it faster, change it to `1.0` or `2.0`.
`c=none`: Ensures the background around the rotating circle remains transparent (doesn't become a black box).
`ow=rotw(a):oh=roth(a)`: Ensures the circle frame size remains correct when rotated so the corners aren't cut off.
`format=rgba`: Needed so FFmpeg recognizes the Alpha channel (transparency layer) during the rotation process.

**Color Customization Tips:**
If you want the colors to be more "alive" or changing (gradient), you can replace `colors=white` with:
`colors=cyan|purple` (Modern color combination).
`colors=0x00FF00` (Neon green).

**Rotating Circle + Song Title + Automatic Duration**

ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=cyan|purple:zoom=1.5[sw]; \
 [sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot]; \
 [0:v][rot]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[bg_wave]; \
 [bg_wave]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=40:x=(W-text_w)/2:y=H-100: \
 alpha='if(lt(t,2),0,if(lt(t,5),(t-2)/3,1))'[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_final.mp4

**Explanation of New Features:**
**Automatic Duration (-shortest):**
The `-shortest` parameter at the end of the command is very important. Because we use `-loop 1` on the image (which technically makes its duration infinite), `-shortest` tells FFmpeg to stop exactly when the audio file ends. So, your video will have the exact same duration as the song.
**Text Title (drawtext):**
`text='YOUR SONG TITLE'`: Replace this text as you wish.
`x=(W-text_w)/2`: Places the text exactly in the center horizontally.
`y=H-100`: Places the text at the bottom (100 pixels from the bottom of the video).
**Text Fade-in Effect (alpha=...):**
This formula controls the text transparency:
`0-2 seconds`: Text is invisible (transparent).
`2-5 seconds`: Text slowly appears (fade-in).
`Above 5 seconds`: Text is fully visible.

**Background Image + Rotating Circular Waveform + Song Title + Automatic Duration (Shortest)**

ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=cyan|purple:zoom=1.3[sw]; \
 [sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot]; \
 [0:v][rot]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[bg_wave]; \
 [bg_wave]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=45:x=(W-text_w)/2:y=H-120: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))', \
 drawtext=fontcolor=white:fontsize=30:x=(W-text_w)/2:y=H-70:text='%{pts\:gmtime\:0\:%M\\\:%S}': \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))'[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy -shortest output_final.mp4

**Running Timer:** I added a second `drawtext` that functions as a time duration indicator (00:01, 00:02, etc.) right below the song title.
**Gradient Colors:** Using `colors=cyan|purple` to make the circle look more modern.
**Fade Synchronization:** Both the title and the timer will appear together (fade-in) after the first second.

**Quick Customization Guide:**
**Change Title:** Modify `'YOUR SONG TITLE'`.
**Change Text Size:** Modify `fontsize=45`.
**Change Rotation Speed:** Modify `t*0.5` (larger number = faster).

**Glow Waveform + Logo + Text + Timer**

ffmpeg -loop 1 -i image.jpg -i audio.mp3 -i logo.png -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=cyan|purple:zoom=1.3[sw]; \
 [sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot]; \
 [rot]split[main][glow]; \
 [glow]boxblur=10:5[glow_blurred]; \
 [main][glow_blurred]mergeplanes=0x00010203:0x00010203[final_sw]; \
 [0:v][final_sw]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[bg_wave]; \
 [bg_wave][2:v]overlay=W-w-20:20[bg_logo]; \
 [bg_logo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=45:x=(W-text_w)/2:y=H-120: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))', \
 drawtext=fontcolor=white:fontsize=30:x=(W-text_w)/2:y=H-70:text='%{pts\:gmtime\:0\:%M\\\:%S}': \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))'[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy -shortest output_pro.mp4

**Glow Effect (split, boxblur, mergeplanes):**
We split the waveform into two (main and glow).
The glow layer is given a `boxblur` effect to make it look radiant.
Both are merged back so the main waveform appears to have a glow effect around it.
**Logo in Corner ([bg_wave][2:v]overlay):**
`2:v` refers to the `logo.png` file (input 3).
`W-w-20:20` means: place the logo in the top right corner with a margin of 20 pixels from the edge.
To place it in the top left corner, change it to `20:20`.
**Visual Quality:**
I still use `pix_fmt yuv420p` so this video can be uploaded directly to Instagram, TikTok, or YouTube without format errors.

**Little Tips:**
**Logo Size:** If your logo is too large, add a `scale` filter before overlaying the logo, for example: `[2:v]scale=100:-1[logo_small]; [bg_wave][logo_small]overlay...`
**Glow Color:** If you want a stronger glow, increase the numbers in `boxblur=10:5` (e.g., to `20:10`).

**FFmpeg Geq Filter
For a dynamic circular waveform, you can use a combination of filters to transform coordinates:
```
ffmpeg -i input.mp4 -filter_complex \
"[0:a]showwaves=s=720x720:mode=line,format=rgba[linear]; \
 [0:v]scale=720:720[bg]; \
 [bg][linear]overlay=0:0,geq='if(between(r,320,340),p(X,Y),p(X,Y))':r=720/720" \
-c:a copy output.mp4
```
**Explanation:

**Generate a linear waveform
Scale video to match
Use geq (global equation) filter to manipulate pixel coordinates
The complex part is mapping Cartesian (x,y) to Polar (r,θ) coordinates

**Practical Recommendation
For a truly dynamic circular waveform, consider these alternatives:
Use specialized audio visualization software like MilkDrop or Buttplug that support circular visualizations, then screen-capture and overlay
Use a video editing tool like Adobe After Effects or DaVinci Resolve which have audio waveform effects that can be shaped into circles
Create a custom solution using Python with libraries like ffmpeg-python and numpy to generate frames programmatically

**A circular waveform (like an audio spectroscope in polar coordinates)
No image background (transparent or black)
Text overlay for title
Logo overlay
Here's a corrected command to achieve this:
```
ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"[0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1[waveform]; \
 [waveform]format=rgba,rotate=5:c=none[rotated]; \
 [rotated][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4
```
Key Components Explained:
1. Circular Waveform with avectorscope
```
avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1
mode=circle creates circular/polar visualization
zoom=1.3 controls the size of the circle
rc/gc/bc set colors for channels (white in this example)
rf/gf/bf set intensity factors
```
2. Rotation Effect
```
format=rgba,rotate=5:c=none
```
**Rotates the visualization for dynamic effect
c=none keeps transparent background

3. Text Animation
```
alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))
```
Text fades in over 3 seconds after 1 second delay

**Alternative: Circular Wave with Background
If you want a black background instead of transparent:
```
ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"color=c=black:s=720x720:r=30[bg]; \
 [0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=0:gc=1:bc=0:rf=1:gf=1:bf=1,format=rgba[waveform]; \
 [bg][waveform]overlay=0:0[withbg]; \
 [withbg][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:fontfile=/path/to/font.ttf[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4
```
**Customization Options:
**Colors:
Green only: rc=0:gc=1:bc=0
Red/Blue mix: rc=1:gc=0:bc=1
Rainbow effect: Omit color parameters for default colors
**Circle Size:
Adjust zoom value: zoom=0.8 (smaller), zoom=2.0 (larger)
**Add Time Display:
Add this before the closing bracket of drawtext:
:drawtext=text='%{pts\:gmtime\:0\:%M\:%S}':x=10:y=10:fontcolor=white
**Fix for Missing Font:
If you get font errors, either:
Specify a valid font path:
fontfile=/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf
Or use a default font (if your FFmpeg is compiled with fontconfig):
font='Sans'
```
ffmpeg -h filter=avectorscope
```
Based on the output, here's the most compatible command:

```
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=720x720:zoom=1.3:draw=line:rc=1:gc=1:bc=1,format=yuv420p[outv]" -map "[outv]" -map 0:a -c:v libx264 -output.mp4
```
If you want a more circular-like effect, use:
These scripts should work with standard FFmpeg builds without requiring the non-existent mode=circle parameter.

```
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=720x720:mode=cline:rate=25:colors=cyan,geq=r='min(255, hypot(X-360,Y-360)*2)':g='min(255, hypot(X-360,Y-360)*2)':b=255,format=yuv420p[outv]" -map "[outv]" -map 0:a output.mp4
```