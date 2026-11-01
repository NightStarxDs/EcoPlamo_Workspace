@echo off
echo ========================================
echo EcoPlamo Database Reset Script
echo ========================================
echo.
echo This will:
echo 1. Drop all tables
echo 2. Run migrations
echo 3. Seed database with real data
echo.
pause

cd /d "%~dp0"

echo.
echo [Step 1/2] Running migrations...
php artisan migrate:fresh

echo.
echo [Step 2/2] Seeding database...
php artisan db:seed

echo.
echo ========================================
echo Database reset complete!
echo ========================================
echo.
echo Test your API: http://localhost:8000/api/katalog
echo.
pause
