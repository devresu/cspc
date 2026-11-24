@echo off
setlocal enabledelayedexpansion
title Linux Codespace PC - Launcher

:menu
cls
echo ============================================================
echo   GitHub Codespace Linux PC (High-FPS KasmVNC + Chrome)
echo ============================================================
echo.
echo   1. Check Git ^& GitHub CLI (gh) setup
echo   2. Initialize Git repo ^& push to a new GitHub repo
echo   3. Create ^& launch GitHub Codespace in browser
echo   4. List active Codespaces ^& open Desktop port (6901)
echo   5. Exit
echo.
set /p "choice=Select an option [1-5]: "

if "%choice%"=="1" goto check_tools
if "%choice%"=="2" goto push_github
if "%choice%"=="3" goto create_codespace
if "%choice%"=="4" goto open_codespace
if "%choice%"=="5" goto end
goto menu

:check_tools
echo.
where git >nul 2>&1
if errorlevel 1 (
    echo [MISSING] git is not installed. Install from https://git-scm.com/
) else (
    for /f "delims=" %%v in ('git --version') do echo [OK] %%v
)

where gh >nul 2>&1
if errorlevel 1 (
    echo [OPTIONAL] GitHub CLI (gh) is not installed. Install from https://cli.github.com/
) else (
    for /f "delims=" %%v in ('gh --version ^| findstr /b "gh version"') do echo [OK] %%v
    gh auth status
)
echo.
pause
goto menu

:push_github
echo.
where git >nul 2>&1
if errorlevel 1 (
    echo Error: git is required. Install from https://git-scm.com/
    pause
    goto menu
)

if not exist ".git" (
    git init -b main
)
git add .
git commit -m "Initial commit: High-FPS Linux Codespace PC with Chrome" 2>nul

where gh >nul 2>&1
if not errorlevel 1 (
    set /p "reponame=Enter new GitHub repository name (e.g. linux-codespace-pc): "
    if not "!reponame!"=="" (
        set /p "vis=Visibility - public or private? [private]: "
        if "!vis!"=="" set "vis=private"
        gh repo create "!reponame!" --!vis! --source=. --remote=origin --push
    )
) else (
    echo GitHub CLI ^(gh^) not found. Create an empty repo on github.com, then enter its URL:
    set /p "remoteurl=Repository URL (e.g. https://github.com/user/repo.git): "
    if not "!remoteurl!"=="" (
        git remote remove origin 2>nul
        git remote add origin "!remoteurl!"
        git push -u origin main
    )
)
echo.
pause
goto menu

:create_codespace
echo.
where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI ^(gh^) is required for this option.
    echo You can also open your repo on github.com -> Code -> Codespaces -> Create codespace on main.
    pause
    goto menu
)
echo Creating Codespace (select 4-core or 8-core machine when prompted for best FPS)...
gh codespace create
echo.
echo Once started, forward port 6901 in VS Code / Codespaces Ports tab -> Open in Browser.
pause
goto menu

:open_codespace
echo.
where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI ^(gh^) is required for this option.
    pause
    goto menu
)
gh codespace list
echo.
echo To open your Codespace in the browser, run:
echo   gh codespace view --web
set /p "openweb=Open a Codespace in your browser now? (y/n): "
if /i "%openweb%"=="y" (
    gh codespace view --web
)
pause
goto menu

:end
endlocal
exit /b 0
