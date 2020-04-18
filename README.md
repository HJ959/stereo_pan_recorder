# stereo_pan_recorder
# Author: Henry James
# Created: 09 04 2020
# Website: https://henryjames.space

#############################################################
# This script will record audio from a microphone
# after 9.45 mins of audio has been recorded it
# will compile the audio into the master audio file
# each time it compiles to the master audio file
# it will subtly incrememnt the pan so each iteration
# of audio is in a different position covering the
# space. Each audio file will have the correct gain
# applied when being mixed with the master so to not
# cause clipping after many hours of recording, the
# script should be ran over night and the overall
# piece will be the collection of nights through different
# windows in the house

# tools you will need to run this script: FFMPEG, FFPROBE
