@echo off
echo ========================================
echo STARTING REACT FRONTENDS
echo ========================================
echo.

cd uniclub-fe

echo Installing dependencies...
call pnpm install

echo.
echo Starting React development servers...
echo - Customer Frontend: http://localhost:5173
echo - Admin Frontend: http://localhost:5174
echo.

call pnpm dev
