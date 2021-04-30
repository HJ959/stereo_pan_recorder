# stereo_pan_recorder
## Author: Henry James
## Created: 09 04 2020
## Website: https://henryjames.space


This script will record audio from a microphone, after a 
specified amount of input time it will compile the audio into 
the master audio file. Each audio recording is bounced to the 
master audio file but has the pan subtly increment so each 
iteration of audio is in a different position covering the
stereo field. 

Each audio file will have the correct gain applied when 
being mixed with the master so to not cause clipping after 
many hours of recording. 

Possible uses for the script include creating 'soundlapses'
of environments in nature or recording musicians to create
interesting sound pieces that seem to capture the bredth
of a performance in a compressed time.

I've been running this script on Mac OS with a focusrite 
Saffire Pro 14 interface as well as creating a portable
version with a raspberry pi powered by external power bank
with the native instrument’s audio interface.
Another cheap interface that's compatible with the Pi is 
the Behringer U-Control.

When running this script you can edit the following variables
at the top of the script.
```
# how many times you iterate across the stereo spectrum
count_limit=10

# the record length in seconds
record_time=182

# the delay in seconds, useful if outside and need to quickly
# get away from the recording
start_delay=1
```
# tools you will need to run this script: FFMPEG, FFPROBE
