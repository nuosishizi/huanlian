FaceFusion Windows NVIDIA 轻量安装器
====================================

安装
1. 下载并解压 FaceFusion-Windows-NVIDIA-Installer.zip。
2. 双击 install.bat，按窗口提示完成安装。安装 Miniconda 时 Windows 会弹出管理员确认框。
3. 安装完成后双击桌面上的 FaceFusion 快捷方式启动。

安装器会联网安装 FaceFusion、Python 3.12、CUDA 12.9/cuDNN 9.10 运行库及 FFmpeg。
压缩包本身只包含安装脚本，体积很小。软件和 AI 模型会在首次安装/启动时下载。

电脑要求
- Windows 10/11 64 位，网络连接。
- NVIDIA 显卡和可用的 NVIDIA 显卡驱动。安装器会检测驱动；如果缺少，会打开 NVIDIA 官方下载页面。
- 磁盘空间：建议至少 10 GB，模型另需空间。

卸载
删除 `%LOCALAPPDATA%\FaceFusion` 文件夹，并在 Windows“已安装的应用”中卸载 FaceFusion 安装器安装的 Miniconda3。NVIDIA 显卡驱动属于系统组件，需在 Windows 设置中单独卸载。

项目：https://github.com/facefusion/facefusion
源码镜像：https://github.com/nuosishizi/huanlian
请阅读 LICENSE.md 并遵守适用法律及肖像、隐私权要求。
