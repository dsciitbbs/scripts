@echo off
IF "%1%"=="black" (
  echo [30m%2[0m 
  GOTO:eof
) 
IF "%1%"=="red" (
  echo [31m%var:~1,-1%[0m 
  GOTO:eof
) 
IF "%1%"=="green" (
  echo [32m%2[0m 
  GOTO:eof
)
IF "%1%"=="yellow" (
  echo [33m%2[0m 
  GOTO:eof
)
IF "%1%"=="blue" (
  echo [34m%2[0m 
  GOTO:eof
) 
IF "%1%"=="magenta" (
  echo [35m%2[0m 
  GOTO:eof
)
IF "%1%"=="skyblue" (
  echo [36m%2[0m 
  GOTO:eof
)
echo %2