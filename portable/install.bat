@echo off
setlocal EnableExtensions
chcp 65001 >nul
title FaceFusion Windows NVIDIA 安装器
set "ROOT=%~dp0"
set "INSTALL_DIR=%LOCALAPPDATA%\FaceFusion"
set "ENV_DIR=%INSTALL_DIR%\env"
set "APP_DIR=%INSTALL_DIR%\app"
set "CONDA_ROOT=%ProgramData%\FaceFusion\Miniconda3"
set "CONDA_BAT=%CONDA_ROOT%\condabin\conda.bat"

echo ==============================================
echo   FaceFusion Windows NVIDIA 一键安装
echo ==============================================
echo 安装目录：%INSTALL_DIR%
echo 首次安装需要网络，并会下载 Python、CUDA 运行库和应用模型。
echo.

where nvidia-smi >nul 2>nul
if errorlevel 1 (
  echo 未检测到 NVIDIA 驱动或 NVIDIA 显卡。
  echo 请先安装适用于本机显卡的官方驱动，再重新运行本安装器：
  start "" "https://www.nvidia.com/Download/index.aspx"
  echo 驱动只能通过 NVIDIA 官方安装程序安装，本安装器不会修改系统驱动。
  pause
  exit /b 1
)

if not exist "%CONDA_BAT%" (
  echo 正在下载 Miniconda 安装程序...
  curl.exe -L --fail --retry 3 "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -o "%TEMP%\FaceFusion-Miniconda3.exe"
  if errorlevel 1 goto :failed
  echo Miniconda 需要安装到 Windows 公共程序目录，接下来会请求管理员确认。
  powershell.exe -NoProfile -Command "Start-Process -FilePath '%TEMP%\FaceFusion-Miniconda3.exe' -ArgumentList '/InstallationType=AllUsers /RegisterPython=0 /S /D=%CONDA_ROOT%' -Verb RunAs -Wait; if (Test-Path '%CONDA_BAT%') { exit 0 } else { exit 1 }"
  if errorlevel 1 goto :failed
)

if not exist "%CONDA_BAT%" (
  echo 未找到 Miniconda：%CONDA_BAT%
  goto :failed
)

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%ENV_DIR%\python.exe" (
  echo 正在创建 Python 3.12 环境...
  call "%CONDA_BAT%" create -y -p "%ENV_DIR%" --override-channels -c conda-forge python=3.12 pip=25.0
  if errorlevel 1 goto :failed
)

if not exist "%APP_DIR%\facefusion.py" (
  echo 正在下载 FaceFusion 源码...
  call "%CONDA_BAT%" run -p "%ENV_DIR%" python -c "import urllib.request; urllib.request.urlretrieve('https://github.com/facefusion/facefusion/archive/refs/heads/master.zip', r'%TEMP%\facefusion-source.zip')"
  if errorlevel 1 goto :failed
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%TEMP%\facefusion-source.zip' -DestinationPath '%INSTALL_DIR%\source' -Force; $src=Get-ChildItem '%INSTALL_DIR%\source' -Directory | Select-Object -First 1; Move-Item -LiteralPath $src.FullName -Destination '%APP_DIR%'"
  if errorlevel 1 goto :failed
)

echo 正在安装 CUDA 12.9 和 cuDNN 9.10 运行库...
call "%CONDA_BAT%" install -y -p "%ENV_DIR%" --override-channels -c conda-forge nvidia/label/cuda-12.9.1::cuda-runtime nvidia/label/cudnn-9.10.0::cudnn
if errorlevel 1 goto :failed

echo 正在安装 FFmpeg...
call "%CONDA_BAT%" install -y -p "%ENV_DIR%" --override-channels -c conda-forge ffmpeg
if errorlevel 1 goto :failed

echo 正在安装 FaceFusion 与 NVIDIA CUDA 版 ONNX Runtime...
call "%CONDA_BAT%" run -p "%ENV_DIR%" python "%APP_DIR%\install.py" cuda@12 --skip-conda
if errorlevel 1 goto :failed
call "%CONDA_BAT%" run -p "%ENV_DIR%" python -c "import onnxruntime as ort; assert 'CUDAExecutionProvider' in ort.get_available_providers(), ort.get_available_providers()"
if errorlevel 1 goto :failed

copy /y "%ROOT%start.bat" "%INSTALL_DIR%\Start-FaceFusion.bat" >nul
powershell.exe -NoProfile -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut([Environment]::GetFolderPath('Desktop')+'\FaceFusion.lnk'); $s.TargetPath='%INSTALL_DIR%\Start-FaceFusion.bat'; $s.WorkingDirectory='%APP_DIR%'; $s.Save()"
echo.
echo 安装完成。桌面已创建 FaceFusion 快捷方式。
pause
exit /b 0

:failed
echo.
echo 安装未完成。请检查网络连接和上方错误信息，再重新运行 install.bat。
pause
exit /b 1
