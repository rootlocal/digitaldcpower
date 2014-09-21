@REM *** Usage: just double click this file from the filemanger
@REM ***
@REM *** you need to edit this file and adapt it to your AVR installation. 
@REM *** Change the PATH

@echo -------- begin --------

@set PATH=C:\Program Files (x86)\Atmel\AVR Tools\AVR Toolchain\bin;%PATH%

make -f Makefile all

@echo --------  end  --------
pause
