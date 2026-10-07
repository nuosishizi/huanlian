@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "INSTALL_DIR=%LOCALAPPDATA%\FaceFusion"
set "ENV_DIR=%INSTALL_DIR%\env"
set "APP_DIR=%INSTALL_DIR%\app"
set "CONDA_BAT=%ProgramData%\FaceFusion\Miniconda3\condabin\conda.bat"
if not exist "%ENV_DIR%\python.exe" (
  echo 尚未安装。请先双击 install.bat。
  pause
  exit /b 1
)
set "GRADIO_ANALYTICS_ENABLED=False"
cd /d "%APP_DIR%"
"%CONDA_BAT%" run --no-capture-output -p "%ENV_DIR%" python facefusion.py run --open-browser --execution-providers cuda %*
if errorlevel 1 (
  echo.
  echo 启动失败。请检查 NVIDIA 驱动和安装器中的错误信息。
  pause
)
