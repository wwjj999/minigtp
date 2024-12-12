@echo off
REM --- Step 1: 强制设置CMD使用UTF-8编码 ---
chcp 65001

REM --- Step 2: 检查Git是否安装 ---
git --version >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo Git没有安装，请从 https://git-scm.com/ 下载并安装Git。
    pause
    exit /b
)

REM --- Step 3: 确保当前在正确的Git仓库目录 ---
echo 正在切换到正确的Git仓库目录：C:\minigtp
cd /d C:\minigtp

REM --- Step 4: 检查当前目录是否为Git仓库 ---
IF NOT EXIST ".git" (
    echo 当前目录不是Git仓库。请确保您在正确的目录下。
    pause
    exit /b
)

REM --- Step 5: 检查并添加上游仓库（如果尚未添加）---
echo 正在检查是否配置了上游仓库...
git remote -v | findstr upstream >nul
IF %ERRORLEVEL% NEQ 0 (
    echo 上游仓库未配置，正在添加上游仓库...
    git remote add upstream https://github.com/cmliu/edgetunnel.git
) ELSE (
    echo 上游仓库已经配置。
)

REM --- Step 6: 获取上游仓库的最新更改 ---
echo 正在获取上游仓库的最新更改...
git fetch upstream

REM --- Step 7: 获取当前分支名 ---
FOR /F "tokens=*" %%i IN ('git branch --show-current') DO SET CURRENT_BRANCH=%%i

echo 当前分支是：%CURRENT_BRANCH%
echo 请确认您在正确的分支上（例如 main 或 master），然后按任意键继续。
pause

REM --- Step 8: 提示用户是否继续合并 ---
echo 您是否要将上游仓库的更改合并到您的本地分支？[Y/N]
set /p choice=
IF /I "%choice%"=="Y" (
    REM --- Step 9: 合并上游更改 ---
    echo 正在合并上游仓库的更改...
    git merge upstream/%CURRENT_BRANCH%
    IF %ERRORLEVEL% NEQ 0 (
        echo 合并失败！请手动解决冲突并按任意键继续。
        pause
        exit /b
    )
) ELSE (
    echo 用户取消了合并操作。
    pause
    exit /b
)

REM --- Step 10: 检查并处理未跟踪文件 ---
echo 正在检查是否有未跟踪的文件...
git status

REM 如果有未跟踪文件（例如 sync_with_upstream.bat），自动添加并提交
git add sync_with_upstream.bat
git commit -m "添加 sync_with_upstream.bat 文件"

REM --- Step 11: 强制推送到远程仓库 ---
echo 正在强制推送更改到远程仓库，以确保与上游仓库同步...
git push origin %CURRENT_BRANCH% --force
IF %ERRORLEVEL% NEQ 0 (
    echo 推送失败！请检查远程仓库设置。
    pause
    exit /b
)

echo 同步完成，您的仓库现在已与上游仓库保持一致。
pause
