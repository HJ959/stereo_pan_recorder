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

# tools you will need to run this script: FFMPEG, FFPROBE
#############################################################
# create a max record counter and a max count value
max_count=0
count_limit=10
record_time=423
pan_L=0
pan_R=10

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

     
    # record x mins of audio
    ffmpeg -y -f avfoundation -i ":0" -t $record_time $output

    # if first time recording master bounce to stereo channel
    # from the 8 channel saffire input
    num_channels=$(ffprobe -i master.aiff -show_entries stream=channels -select_streams a:0 -of compact=p=0:nk=1 -v 0)

    if [ $max_count -lt 1  ] && [ $num_channels -gt 2 ]
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
       ffmpeg -y -i master_copy.aiff -i new_audio_stereo.aiff -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0=c0+0.$pan_L*c2|c1=c1+0.$pan_R*c3[a]" -map "[a]" master.aiff
        
        let "++pan_L"
        let "--pan_R"

        if [ $pan_L -ge 10 ]
        then
            pan_L=0
        fi 
        if [ $pan_R -lt 1 ]
        then
            pan_R=10
        fi

        rm master_copy.aiff new_audio_stereo.aiff    
    fi

    # check that we're still within the record limit
    let "++max_count"
    if [ $max_count -gt $count_limit  ]
    then
        break
    fi

    echo "Pan left value $pan_L"
    echo "Pan right value $pan_R"
    echo "Number of iterations: $max_count limit $count_limit"
    echo ""
done
rm new_audio.aiff
#############################################################
