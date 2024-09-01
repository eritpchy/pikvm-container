[English](./README.md) | [简体中文](./README_zh.md)
# PiKVM-Container
在 Docker 容器中运行 PiKVM。

## 文档
- [PiKVM 官方文档](https://docs.pikvm.org/)

## 测试环境
- **HID**: USB CH340 to CH9329 适配器 (~¥15)
- **VID**: USB MS2130 采集器 (~¥28)
- **平台**: 群晖 x86 NAS

## 功能
- MJPEG
- H.264 (Intel VAAPI 硬件编码器)
- ~~OTG~~

## 快速开始
1. 编辑 `.env.sample` 以匹配你的环境
2. 确保你的硬件设备已正确配置 udev 规则和权限。详情见 [驱动设置](#驱动设置)
3. 使用 `./script/docker_run.sh` 启动容器
4. 等待 2 分钟，然后访问 https://your_docker_host_address:9043
5. 默认用户名/密码是 `admin`
6. 享受你的 PiKVM 设置！

## 驱动设置
1. 确保你的内核支持 `USB VIDEO CLASS` 功能, 对于群晖NAS, 详情见 [其他](#其他)
2. 为容器内硬件设备访问创建用户组：
    ``` 
    组名: videodriver 
    ```
3. 确保你的硬件设备映射到以下位置。Docker 将 `/dev/kvmd` 直接挂载到容器中。
    > 支持 `即插即用` 功能。
    - **HID**: `/dev/kvmd/kvmd-hid`
    - **VID**: `/dev/kvmd/kvmd-video`
4. 确保你的硬件字符设备文件权限为 `0660`，且所有者为 `root:videodriver`
    ```
    chmod 0660 /dev/kvmd/kvmd-hid
    chmod 0660 /dev/kvmd/kvmd-video
    chown root:videodriver /dev/kvmd/kvmd-hid
    chown root:videodriver /dev/kvmd/kvmd-video
    ```
5. udev 规则示例
    > 以下路径可能因系统不同而有所差异。下面的路径适用于群晖设备。
    - **/lib/udev/rules.d/92-usb-video.rules**
    ```sh
    KERNEL=="video[0-9]*", RUN+="/bin/sh -c 'mkdir -p /dev/kvmd; unlink /dev/kvmd/kvmd-video; mknod /dev/kvmd/kvmd-video c ${MAJOR} ${MINOR}; chmod 660 /dev/kvmd/kvmd-video; chown root:videodriver /dev/kvmd/kvmd-video'"
    ```
    - **/lib/udev/rules.d/99-kvmd-hid.rules**
    ```sh
    KERNEL=="ttyUSB[0-9]*", RUN+="/bin/sh -c 'mkdir -p /dev/kvmd/; unlink /dev/kvmd/kvmd-hid; mknod /dev/kvmd/kvmd-hid c ${MAJOR} ${MINOR}; chmod 660 /dev/kvmd/kvmd-hid; chown root:videodriver /dev/kvmd/kvmd-hid'"
    ```
6. 重新加载 udev 规则，以确保设备正确映射
    ```sh
    sudo udevadm control --reload
    sudo udevadm trigger
    ```

## 其他
- 你可以修改 `./root/usr/share/kvmd/stream.sh` 以添加对其他硬件编码器的支持。
- 参考脚本 `./script/test_hardware_coder.sh` 获取示例和测试方法。
- [为群晖编译 `USB VIDEO CLASS` 内核模块](https://github.com/eritpchy/docker-syno-toolkit)


## 延迟
| 编码格式     | 延迟                |
| ------------ | ------------------ |
| MJPEG        | 小于 100ms          |
| H.264 (VAAPI)| 84-150ms           |
