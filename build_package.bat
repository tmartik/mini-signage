@ECHO OFF

REM
REM Params: <path-to-exe>
REM

if "%~1"=="" goto finish


REM Clean folder
rmdir /q /s deployment


windeployqt --dir deployment -qmldir . %1

xcopy %1 deployment\ /F

REM Copy sample files
xcopy config.json deployment\ /F
xcopy sampleslides deployment\sampleslides\ /F

REM Build installation package
makensis installation.nsi

:finish
