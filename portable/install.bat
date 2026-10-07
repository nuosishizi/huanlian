@echo off
setlocal EnableExtensions
chcp 65001 >nul
title FaceFusion Windows NVIDIA 安装器
set "ROOT=%~dp0"
set "ENV_DIR=%ROOT%env"
set "APP_DIR=%ROOT%app"

echo ==============================================
echo   FaceFusion Windows NVIDIA 一键安装
echo ==============================================
echo 安装目录：%ROOT%
echo 首次安装需要网络，并会下载 Python、CUDA 运行库和应用模型。
echo.

where winget >nul 2>nul
if errorlevel 1 (
  echo 未检测到 winget。请先安装或更新“应用安装程序”/App Installer：
  start "" "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
  echo 安装完成后重新双击 install.bat。
  pause
  exit /b 1
)

where nvidia-smi >nul 2>nul
if errorlevel 1 (
  echo 未检测到 NVIDIA 驱动或 NVIDIA 显卡。
  echo 请先安装适用于本机显卡的官方驱动，再重新运行本安装器：
  start "" "https://www.nvidia.com/Download/index.aspx"
  echo 驱动只能通过 NVIDIA 官方安装程序安装，本安装器不会修改系统驱动。
  pause
  exit /b 1
)

if not exist "%ROOT%miniconda3\condabin\conda.bat" (
  echo 正在下载 Miniconda 安装程序...
  curl.exe -L --fail --retry 3 "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -o "%TEMP%\FaceFusion-Miniconda3.exe"
  if errorlevel 1 goto :failed
  echo 正在为当前用户安装 Miniconda...
  "%TEMP%\FaceFusion-Miniconda3.exe" /InstallationType=JustMe /RegisterPython=0 /S /D=%ROOT%miniconda3
  if errorlevel 1 goto :failed
)

set "CONDA_BAT=%ROOT%miniconda3\condabin\conda.bat"
if not exist "%CONDA_BAT%" (
  echo 未找到项目目录中的 Conda：%CONDA_BAT%
  goto :failed
)

if not exist "%ENV_DIR%\python.exe" (
  echo 正在创建 Python 3.12 环境...
  call "%CONDA_BAT%" create -y -p "%ENV_DIR%" python=3.12 pip=25.0
  if errorlevel 1 goto :failed
)

if not exist "%APP_DIR%\.git" (
  echo 正在下载 FaceFusion 源码...
  call "%CONDA_BAT%" run -p "%ENV_DIR%" python -c "import urllib.request; urllib.request.urlretrieve('https://github.com/facefusion/facefusion/archive/refs/heads/master.zip', r'%TEMP%\facefusion-source.zip')"
  if errorlevel 1 goto :failed
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%TEMP%\facefusion-source.zip' -DestinationPath '%ROOT%source' -Force; $src=Get-ChildItem '%ROOT%source' -Directory | Select-Object -First 1; Move-Item -LiteralPath $src.FullName -Destination '%APP_DIR%'"
  if errorlevel 1 goto :failed
)

echo 正在安装 CUDA 12.9 和 cuDNN 9.10 运行库...
call "%CONDA_BAT%" install -y -p "%ENV_DIR%" nvidia/label/cuda-12.9.1::cuda-runtime nvidia/label/cudnn-9.10.0::cudnn
if errorlevel 1 goto :failed

echo 正在安装 FFmpeg...
call "%CONDA_BAT%" install -y -p "%ENV_DIR%" -c conda-forge ffmpeg
if errorlevel 1 goto :failed

echo 正在安装 FaceFusion 与 NVIDIA CUDA 版 ONNX Runtime...
call "%CONDA_BAT%" run -p "%ENV_DIR%" python "%APP_DIR%\install.py" cuda@12 --skip-conda
if errorlevel 1 goto :failed

copy /y "%ROOT%start.bat" "%ROOT%Start-FaceFusion.bat" >nul
echo.
echo 安装完成。双击 Start-FaceFusion.bat 即可启动。
pause
exit /b 0

:failed
echo.
echo 安装未完成。请检查网络连接和上方错误信息，再重新运行 install.bat。
pause
exit /b 1
