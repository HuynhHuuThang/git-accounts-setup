@echo off
:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo Please run this script as administrator!
    echo Right-click on the script and select "Run as administrator"
    pause
    exit /b 1
)

:: Create .ssh directory if it doesn't exist
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"
cd "%USERPROFILE%\.ssh"

echo Creating SSH keys for your accounts...

:: Generate SSH keys (will prompt for email addresses)
set /p office_email=Enter your office email: 
set /p personal_email=Enter your personal email: 
set /p office_username=Enter your office GitHub username: 
set /p personal_username=Enter your personal GitHub username: 

:: Generate SSH keys
ssh-keygen -t rsa -C "%office_email%" -f "github-%office_username%" -N ""
ssh-keygen -t rsa -C "%personal_email%" -f "github-%personal_username%" -N ""

:: Add keys to SSH agent
echo Adding keys to SSH agent...
start-ssh-agent
ssh-add "%USERPROFILE%\.ssh\github-%office_username%"
ssh-add "%USERPROFILE%\.ssh\github-%personal_username%"

:: Create config file
echo Creating SSH config file...
(
echo #%office_username% account
echo Host github.com-%office_username%
echo      HostName github.com
echo      User git
echo      IdentityFile ~/.ssh/github-%office_username%
echo.
echo #%personal_username% account
echo Host github.com-%personal_username%
echo      HostName github.com
echo      User git
echo      IdentityFile ~/.ssh/github-%personal_username%
) > "%USERPROFILE%\.ssh\config"

:: Display public keys for user to copy
echo.
echo ========== OFFICE ACCOUNT PUBLIC KEY ==========
type "github-%office_username%.pub"
echo.
echo ========== PERSONAL ACCOUNT PUBLIC KEY ==========
type "github-%personal_username%.pub"
echo.
echo Please copy these public keys and add them to your respective GitHub accounts
echo Visit: https://github.com/settings/keys to add your SSH keys
echo.
echo Setup completed! Please follow these steps:
echo 1. Copy the public keys shown above
echo 2. Add them to your GitHub accounts in the SSH keys section
echo 3. For each repository you clone, remember to set the user.email and user.name:
echo    git config user.email "your-email"
echo    git config user.name "your-name"
echo.
pause
