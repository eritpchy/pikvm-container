 /usr/bin/ustreamer --device=/dev/video0 --persistent --format=mjpeg --resolution=1920x1080 --desired-fps=25 --drop-same-frames=30 --last-as-blank=0 --unix-rm --unix-mode=0660 --exit-on-parent-death --process-name-prefix=aaa --notify-parent --no-log-colors --sink=kvmd::ustreamer::jpeg --sink-mode=0660


 /usr/bin/ustreamer --device=/dev/video0 --persistent --format=mjpeg --resolution=1920x1080 --desired-fps=25 --drop-same-frames=30 --last-as-blank=0 --unix-rm --unix-mode=0660 --exit-on-parent-death --process-name-prefix=aaa --notify-parent --no-log-colors --h264-sink=kvmd::ustreamer::h264
            --h264-sink-mode=0660 --sink=kvmd::ustreamer::h264


kill -9 $(pidof ustreamer); /usr/bin/ustreamer-dump  --device=/dev/video0  --sink kvmd::ustreamer::jpeg --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1 -i pipe: -rtbufsize 10M -c:v libx264 -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v baseline -bf 0 -b:v 3M -maxrate:v 5M  -r 10 -g 10 -an  -f rtp rtp://127.0.0.1:5004

kill -9 $(pidof ustreamer); ffmpeg -f v4l2 -input_format mjpeg  -i /dev/video0 -c:v libx264 -vf "scale=1920:1080,format=yuv420p" -preset:v ultrafast -tune:v zerolatency -profile:v baseline -bf 0 -b:v 3M -maxrate:v 5M  -r 10 -g 10 -an  -f rtp rtp://192.168.50.75:5004

kill -9 $(pidof ustreamer); ffmpeg -f v4l2 -input_format yuyv422  -i /dev/video0 -c:v libx264 -vf "scale=1920:1080,format=yuv420p" -preset:v ultrafast -tune:v zerolatency -profile:v baseline -bf 0 -b:v 3M -maxrate:v 5M  -r 10 -g 10 -an  -f rtp /tmp/1.mp4


kill -9 $(pidof ustreamer); ffmpeg -f v4l2 -input_format mjpeg -i /dev/video0 -vf "format=vaapi" -c:v h264_vaapi -b:v 3M -maxrate 5M -r 10 -g 10 -an -f rtp rtp://192.168.50.75:5004
kill -9 $(pidof ustreamer); ffmpeg -f v4l2 -input_format mjpeg -i /dev/video0 -vf "format=vaapi" -c:v h264_qsv -f null -

ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -i /tmp/test_en.mp4  -c:v h264_vaapi -y /tmp/test_en.1.mp4

kill -9 $(pidof ustreamer); ffmpeg -re -use_wallclock_as_timestamps 1  -f v4l2 -input_format yuyv422 -i /dev/video0 -c:v mjpeg -f mjpeg -| /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1  -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi -i pipe: -vf 'scale_vaapi=format=nv12'  -rtbufsize 10M -c:v h264_vaapi -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M  -an  -f rtp rtp://192.168.50.75:5004


kill -9 $(pidof ustreamer) $(pidof ffmpeg); ffmpeg -re -use_wallclock_as_timestamps 1 -f v4l2 -input_format yuyv422  -video_size 1920x1080 -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi -i /dev/video0 -rtbufsize 10M -vf 'hwupload,scale_vaapi=format=nv12' -c:v h264_vaapi -preset:v ultrafast -tune:v zerolatency -profile:v main -r 25 -bf 0 -b:v 3M -maxrate:v 5M   -an  -f rtp -headers 'X-UStreamer-Online: true' rtp://192.168.50.75:5004 

kill -9 $(pidof ustreamer); ffmpeg -f v4l2 -input_format yuyv422  -video_size 1920x1080 -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi -i /dev/video0 -vf 'hwupload,scale_vaapi=format=nv12' -c:v h264_vaapi -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M   -an  -f rtp rtp://192.168.50.75:5004

ffmpeg -f v4l2 -input_format mjpeg -i /dev/video0 -vf "format=nv12,hwupload" -c:v h264_vaapi -b:v 3M -maxrate 5M -r 10 -g 10 -an -f rtp rtp://192.168.50.75:5004

/usr/bin/ustreamer-dump --sink kvmd::ustreamer::jpeg --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1 -i pipe: -rtbufsize 10M -c:v libx264 -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M  -r 10 -g 10 -an  -f rtp rtp://127.0.0.1:5004


/usr/bin/ustreamer-dump --sink kvmd::ustreamer::jpeg --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1 -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi  -i pipe:  -vf 'scale_vaapi=format=nv12'  -c:v h264_vaapi -pix_fmt yuv420p -f rtp rtp://192.168.50.75:5004


/usr/bin/ustreamer-dump --sink kvmd::ustreamer::jpeg --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1  -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi  -i pipe: -vf 'scale_vaapi=format=nv12'  -rtbufsize 10M -c:v h264_vaapi -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M -g 10 -an  -f rtp rtp://192.168.50.75:5004

#!/bin/bash
/usr/bin/ustreamer-dump --sink kvmd::ustreamer::raw --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1  -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi -f rawvideo -pixel_format yuyv422 -video_size 1920x1080 -i pipe: -vf 'hwupload,scale_vaapi=format=nv12'  -rtbufsize 10M -c:v h264_vaapi -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M -g 10 -an  -f rtp rtp://192.168.50.75:5004


/usr/bin/ustreamer-dump --sink kvmd::ustreamer::raw --output - | /usr/bin/ffmpeg  -re -use_wallclock_as_timestamps 1  -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 -hwaccel_output_format vaapi -i pipe: -vf 'hwupload,scale_vaapi=format=nv12'  -rtbufsize 10M -c:v h264_vaapi -pix_fmt yuv420p -preset:v ultrafast -tune:v zerolatency -profile:v main -bf 0 -b:v 3M -maxrate:v 5M -g 10 -an  -f rtp rtp://192.168.50.75:5004


kill -9 $(pidof ustreamer); ffmpeg -t 60 -f video4linux2 -input_format mjpeg -i /dev/video0 -c:v libx264 -strict -2  -f rtp rtp://192.168.50.75:5004
