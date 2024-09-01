[English](./README.md) | [简体中文](./README_zh.md)
# PiKVM-Container
Run PiKVM inside a Docker container.

## Documentation
- [PiKVM Official Documentation](https://docs.pikvm.org/)

## Tested Environment
- **HID**: USB CH340 to CH9329 adapter (~$2)
- **VID**: USB MS2130 hdmi video grabber (~$4)
- **Platform**: Synology x86 NAS

## Features
- MJPEG
- H.264 (Intel VAAPI hardware encoder)
- ~~OTG~~

## Getting Started
1. Edit `.env.sample` to match your environment
2. Ensure your hardware devices are properly configured with the correct udev rules and permissions. See [Driver Setup](#driver-setup) for details
3. Start the container with `./script/docker_run.sh`
4. Wait for 2 minutes, then access https://your_docker_host_address:9043
5. The default username/password is `admin`
6. Enjoy your PiKVM setup!

## Driver Setup
1. Make sure your kernel support `USB VIDEO CLASS`, on Synology NAS, See [Other](#other) for details
2. Create a user group for accessing hardware devices within the container:
    ``` 
    Group name: videodriver 
    ```
3. Ensure your hardware devices are mapped to the following locations. Docker will mount `/dev/kvmd` directly into the container.
    > `Plug and play` functionality is supported.
    - **HID**: `/dev/kvmd/kvmd-hid`
    - **VID**: `/dev/kvmd/kvmd-video`
4. Ensure your hardware character device files have `0660` permissions and are owned by `root:videodriver`
    ```
    chmod 0660 /dev/kvmd/kvmd-hid
    chmod 0660 /dev/kvmd/kvmd-video
    chown root:videodriver /dev/kvmd/kvmd-hid
    chown root:videodriver /dev/kvmd/kvmd-video
    ```
5. Example udev rules
    > The following paths may vary depending on your system. The paths below are for Synology devices.
    - **/lib/udev/rules.d/92-usb-video.rules**
    ```sh
    KERNEL=="video[0-9]*", RUN+="/bin/sh -c 'mkdir -p /dev/kvmd; unlink /dev/kvmd/kvmd-video; mknod /dev/kvmd/kvmd-video c ${MAJOR} ${MINOR}; chmod 660 /dev/kvmd/kvmd-video; chown root:videodriver /dev/kvmd/kvmd-video'"
    ```
    - **/lib/udev/rules.d/99-kvmd-hid.rules**
    ```sh
    KERNEL=="ttyUSB[0-9]*", RUN+="/bin/sh -c 'mkdir -p /dev/kvmd/; unlink /dev/kvmd/kvmd-hid; mknod /dev/kvmd/kvmd-hid c ${MAJOR} ${MINOR}; chmod 660 /dev/kvmd/kvmd-hid; chown root:videodriver /dev/kvmd/kvmd-hid'"
    ```
6. Reload udev rules to ensure devices are properly mapped
    ```sh
    sudo udevadm control --reload
    sudo udevadm trigger
    ```

## Other
- You can modify `./root/usr/share/kvmd/stream.sh` to add support for other hardware encoders.
- Refer to the script `./script/test_hardware_coder.sh` for examples and testing.
- [Build `USB VIDEO CLASS` kernel module for Synology NAS](https://github.com/eritpchy/docker-syno-toolkit)


## Latency
| Codec        | Latency            |
| ------------ | ------------------ |
| MJPEG        | Less than 100ms    |
| H.264 (VAAPI)| 84-150ms           |