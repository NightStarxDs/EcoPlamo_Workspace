@echo off
echo ========================================
echo EcoPlamo API Test Script
echo ========================================
echo.
echo Testing API endpoints...
echo.

echo [1/3] Testing Connection...
curl -s http://127.0.0.1:8000/api/tes-koneksi
echo.
echo.

echo [2/3] Testing Katalog Endpoint...
curl -s http://127.0.0.1:8000/api/katalog
echo.
echo.

echo [3/3] Testing Pengumuman Endpoint...
curl -s http://127.0.0.1:8000/api/pengumuman
echo.
echo.

echo ========================================
echo Test Complete!
echo ========================================
echo.
echo If you see JSON data above, the API is working correctly.
echo.
pause
