@echo off

:: Visual Studio Environment
set VSCMD="%VCINSTALLDIR%vcvarsall.bat"

:: OPENSSL Configuration Options
set /p OPENSSL_CONFIG_OPTIONS=<config-params-windows.txt

:: Output Directory
set OUTPUT_DIR="%CD%\libs\windows"

:: Clean output directory
rmdir /S /Q %OUTPUT_DIR%

cd vendor\openssl
call git clean -dfx
call git checkout -f

:: Build 32 bit binaries

:: Run Visual Studio 32 bits shell
setlocal
call %VSCMD% x86

:: Set make output directory
set MAKE_OUTPUT_DIR="%CD%\output\openssl-32"

:: Clean output directory
rmdir /S /Q %MAKE_OUTPUT_DIR%

:: Configure and make
perl Configure VC-WIN32 %OPENSSL_CONFIG_OPTIONS% --prefix=%MAKE_OUTPUT_DIR%
call ms\do_ms.bat
nmake -f ms\mt.mak
nmake -f ms\nt.mak install

:: Copy binary
mkdir %OUTPUT_DIR%\x86
copy %MAKE_OUTPUT_DIR%\lib\libeay32.lib %OUTPUT_DIR%\x86

:: Reset and done
call git clean -dfx
call git checkout -f
endlocal

:: Build 64 bit binaries

:: Run Visual Studio 64 bits shell
setlocal
call %VSCMD% amd64

:: Set make output directory
set MAKE_OUTPUT_DIR="%CD%\output\openssl-64"

:: Clean output directory
rmdir /S /Q %MAKE_OUTPUT_DIR%

:: Configure and make
perl Configure VC-WIN64A %OPENSSL_CONFIG_OPTIONS% --prefix=%MAKE_OUTPUT_DIR%
call ms\do_win64a.bat
nmake -f ms\mt.mak
nmake -f ms\nt.mak install

:: Copy binary
mkdir %OUTPUT_DIR%\amd64
copy %MAKE_OUTPUT_DIR%\lib\libeay32.lib %OUTPUT_DIR%\amd64

mkdir %OUTPUT_DIR%\x86_64
copy %MAKE_OUTPUT_DIR%\lib\libeay32.lib %OUTPUT_DIR%\x86_64

:: Reset and done
call git clean -dfx
call git checkout -f

:: Exit
cd ..\..\
endlocal