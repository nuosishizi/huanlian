@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "ROOT=%~dp0"
if not exist "%ROOT%env\python.exe" (
  echo 尚未安装。请先双击 install.bat。
  pause
  exit /b 1
)
set "GRADIO_ANALYTICS_ENABLED=False"
cd /d "%ROOT%app"
"%ROOT%miniconda3\condabin\conda.bat" run --no-capture-output -p "%ROOT%env" python facefusion.py run --open-browser --execution-providers cuda %*
if errorlevel 1 (
  echo.
  echo 启动失败。请检查 NVIDIA 驱动和安装器中的错误信息。
  pause
)
