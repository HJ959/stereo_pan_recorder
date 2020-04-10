#!/bin/sh
#############################################################
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

#############################################################
# create a max record counter and a max count value
max_count=0
count_limit=15
pan_L=.0
pan_R=1.

# master file
master_audio=master.aiff
new_audio=new_audio.aiff

for (( ; ; ))
do
    if [ -f "$master_audio" ]
    then
        output="new_audio.aiff"
    else
        output="master.aiff"
    fi

     
    # record 9 mins of audio
    ffmpeg -y -f avfoundation -i ":0" -t 1 $output

    # if first time recording master bounce to stereo channel
    # from the 8 channel saffire input
    if [ $max_count -lt 1  ]
    then
        cp master.aiff master_copy.aiff
        sleep 2
        ffmpeg -y -i master_copy.aiff -af "pan=stereo|c0<c0|c1<c0" master.aiff
        sleep 1
        rm master_copy.aiff
    fi

    # mix the new audio recording with the master audio
    if [ -f "$master_audio" ] && [ -f "$new_audio"  ]
    then
        cp $master_audio master_copy.aiff
        sleep 2
        echo "Copied master"

        # when recording from saffire it caputres all 8 channels
        # bounce these so only channel 1 is 'stereo'
        ffmpeg -y -i new_audio.aiff -af "pan=stereo|c0<c0|c1<c0" new_audio_stereo.aiff

        # mix the stereo tracks together incrementing the pan to achieve a wide spread
       ffmpeg -y -i master_copy.aiff -i new_audio_stereo.aiff -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0=c0+$pan_L*c2|c1=c1+$pan_R*c3[a]" -map "[a]" master.aiff
        echo $pan_L
        echo $pan_R
        
        pan_L=$(echo "$pan_L+0.1" | bc)
        pan_R=$(echo "$pan_R-0.1" | bc)
        if [ $pan_L -ge 1.  ]
        then
            pan_L=.0
        fi 
        if [ $pan_R -le .0  ]
        then
            pan_R=1.
        fi

        rm master_copy.aiff new_audio_stereo.aiff    
    fi

    # check that we're still within the record limit
    let "++max_count"
    if [ $max_count -gt $count_limit  ]
    then
        break
    fi




done
#############################################################
