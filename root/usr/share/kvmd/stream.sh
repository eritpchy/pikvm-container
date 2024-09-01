#!/bin/bash
kill -9 $(pidof ustreamer-dump ffmpeg)
/usr/bin/ustreamer-dump --sink kvmd::ustreamer::raw --output - | \
    /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1 \
    -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 \
    -hwaccel_output_format vaapi -f rawvideo -pixel_format yuyv422 \
    -video_size 1920x1080 -i pipe: -vf 'hwupload,scale_vaapi=format=nv12' \
    -rtbufsize 10M -c:v h264_vaapi -pix_fmt yuv420p -preset:v ultrafast \
    -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M \
    -g 10 -an  -f rtp rtp://127.0.0.1:5004