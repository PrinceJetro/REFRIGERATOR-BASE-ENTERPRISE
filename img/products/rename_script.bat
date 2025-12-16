@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
SET "NEW_NAMES_FILE=new_names.txt"
SET "FILE_EXTENSION=*.jpeg"
:: ---------------------

ECHO Starting file rename operation...

:: Check if the file with new names exists
IF NOT EXIST "%NEW_NAMES_FILE%" (
    ECHO ERROR: The file "%NEW_NAMES_FILE%" was not found. Please create it first.
    GOTO :EOF
)

:: Initialize counters
SET "i=0"
SET "RENAME_COUNT=0"

:: Read the new names from the text file into an array
FOR /F "tokens=*" %%N IN ('type "%NEW_NAMES_FILE%"') DO (
    SET /A i+=1
    SET "NewName[!i!]=%%N"
)

ECHO Found !i! new names to use.

:: Reset counter for old files
SET "j=0"

:: Iterate through the original files in the folder (sorted by name/default)
FOR /F "tokens=*" %%F IN ('dir /b /a-d %FILE_EXTENSION%') DO (
    SET /A j+=1
    
    :: Check if we have a corresponding new name
    IF DEFINED NewName[!j!] (
        SET "OLD_NAME=%%F"
        SET "NEW_NAME=!NewName[!j!]!"
        
        IF "!OLD_NAME!" NEQ "!NEW_NAME!" (
            REN "!OLD_NAME!" "!NEW_NAME!"
            IF NOT ERRORLEVEL 1 (
                ECHO Successfully renamed: "!OLD_NAME!" -> "!NEW_NAME!"
                SET /A RENAME_COUNT+=1
            ) ELSE (
                ECHO ERROR: Could not rename "!OLD_NAME!". Target name may already exist.
            )
        ) ELSE (
            ECHO File already has the correct name: "!OLD_NAME!"
        )
    ) ELSE (
        ECHO Warning: Ran out of new names at file number !j!. Stopping.
        GOTO :Summary
    )
)

:Summary
ECHO.
ECHO --- Operation Complete ---
ECHO Total files processed: !j!
ECHO Total files successfully renamed: !RENAME_COUNT!
ECHO.

endlocal

pause