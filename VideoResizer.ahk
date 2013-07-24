#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent

SetWorkingDir %A_ScriptDir%
;SetTitleMatchMode, 2

Menu, tray, Icon , VideoResizer.ico,  1
Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit


	IfNotExist, ffmpeg.exe
	{
		MsgBox, 4,, ffmpeg.exe does not exist. This application won`'t work without it.`nWould you like to open the download page?
		IfMsgBox Yes
		{
			Run, http://ffmpeg.zeranoe.com/builds/
		}			
		else
		{
			
		}
		ExitApp
	}
	
	Global gName := ScriptNameNoExt()
	Global gRegEntry := "*\shell\VideoResizer"
	
	iniName = %gName%.ini
	IniRead, ini_resizeIfWidthLargerThan, %iniName%, settings, resizeIfWidthLargerThan
	IniRead, ini_bitRate, %iniName%, settings, bitRate
	IniRead, ini_singleInstance, %iniName%, settings, singleInstance
	IniRead, ini_overrideFile, %iniName%, settings, overrideFile

	
	Gui, Show, w200 h80, VideoResizerWindow
	Sleep, 100
	
	if(ini_singleInstance = 1) {
		;check if a instance is already running
		Winget,ArrayCount,Count,VideoResizerWindow
		;M sgBox, Amount of instances: %ArrayCount%
		if(ArrayCount > 1) {			
			Winget,List,List,VideoResizerWindow

			Loop %ArrayCount%
			{
				cPID := List%A_Index%
				if(A_Index > 1) {	
					WinGet, testPID, PID, VideoResizerWindow
					;MsgBox, closing %A_Index% - %cPID% - %testPID%
					WinClose, ahk_id %cPID%
					Sleep, 100
				}
				;M sgBox "Element number " . A_Index . " is " . %cPID%
			}
		}
	}
	
	IniRead, ini_tempDir, %iniName%, settings, tempDir
	if(ini_tempDir == "WINDOWS_TEMP") {
		ini_tempDir = %A_Temp%
	}

	;check if no parameters START		
	cFile = %1%
	cLength := StrLen(cFile)	
	;M sgBox, %cLength%
	if(cLength = 0) {
		;User didnt drag any file, so he maybe wants to add / remove the application to the right click menu
		GoSub, AddRemoveFromRegistry	
		ExitApp
	}
	;check if no parameters END
	

	Loop, %0%  ; For each parameter:
	{
		cFile := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		;M sgBox, %cFile%
		SplitPath, cFile, cFileName, sourceDir, cFileExtension, cFileNameNoExt, OutDrive
		StringReplace, cFileNameNoExtNoSpaces, cFileNameNoExt, %A_Space%,,All
		
		;cFileShort := ConvertFAT(cFile)			
		;cFileShort = %cFileShort%.%OutExtension%
		;M sgBox %cFileShort%
		
		;M sgBox, %cFile%

		outFilename = %cFileNameNoExtNoSpaces%_videoresizer.mp4		
		
		;delete output file if it exists
		FileDelete, %ini_tempDir%\%outFilename%
		
		;this scale version would scale all videos to half the size of the original if > ini_resizeIfWidthLargerThan
		;trunc (x/2)*2 - this makes sure the width is an even number, because odd numbers are not allowed
		;scale = 'if(gt(iw,%ini_resizeIfWidthLargerThan%),trunc((iw/2)/2)*2,iw)':-1
		
		TrayTip, %gName%, converting %cFile%
		
		scale = 'if(gt(iw,%ini_resizeIfWidthLargerThan%),1024,iw)':trunc(ow/a/2)*2
		ffmpegCommand =  -i "%cFile%" -vf scale="%scale%" -vcodec libx264 -vprofile high -preset slow -b:v %ini_bitRate%k -maxrate %ini_bitRate%k -bufsize 1000k -acodec copy  %ini_tempDir%\%outFilename%
		;M sgBox, %ffmpegCommand%
		RunWait, ffmpeg.exe %ffmpegCommand%
		
		;if for any reason the filesize is 0, something went wrong
		FileGetSize, outputFileSize,  %ini_tempDir%\%outFilename%, K  ; Retrieve the size in Kbytes.
		if(outputFileSize > 0) {
			;M sgBox, %outputFileSize%
			if(ini_overrideFile = 1) {
				;FileDelete, %1%
				FileMove, %ini_tempDir%\%outFilename%, %cFile%, 1
			} else {
				;M sgBox, %sourceDir%\%cFileNameNoExtNoSpaces%_videoresizer.mp4
				FileMove, %ini_tempDir%\%outFilename%, %sourceDir%\%cFileNameNoExt%_videoresizer.mp4, 1
				if ErrorLevel  ; Successfully loaded.
				{
					MsgBox, file could not be moved.
				}					
			}
		} else {
			FileDelete, %ini_tempDir%\%outFilename%
			MsgBox, There was an error converting your file
		}		

	}

	ExitApp
	
return

AddRemoveFromRegistry:
	If !(A_IsAdmin) {
		MsgBox, 52, % gName . " - Administrator rights required", % "You need Admin rights to add a Registry entry. Do you want to run " . gName . " as Admin now?"
		IfMsgBox, Yes
		{
			Run *RunAs "%A_ScriptFullPath%"			
		}
	} else {
		RegRead, cVal, HKEY_CLASSES_ROOT, %gRegEntry%		
		If !(StrLen(cVal)) {			
			cScriptPathAndName = %A_ScriptFullPath%
			StringReplace, cScriptPathAndName, cScriptPathAndName, \ , \\, All				
			AddCommand := "Resize Video"
			RegWrite, REG_SZ, HKEY_CLASSES_ROOT, %gRegEntry%, , %AddCommand%
			RegWrite, REG_SZ, HKEY_CLASSES_ROOT, %gRegEntry%\command, , "%cScriptPathAndName%" "`%1"
			RegWrite, REG_SZ, HKEY_CLASSES_ROOT, %gRegEntry%, Icon, "%A_ScriptDir%\%gName%.ico"

			RegRead, cVal, HKEY_CLASSES_ROOT, %gRegEntry%				
			if(cVal = AddCommand) {
				MsgBox, 64, % gName . " - Registry Entry", Successfully added to the right click menu				
			} else {
				MsgBox, 48, % gName . " - Registry Entry", Could not add the entry to the right click menu
			}
			
		} else {		
			RegDelete, HKEY_CLASSES_ROOT, %gRegEntry%								
			RegRead, cVal, HKEY_CLASSES_ROOT, %gRegEntry%			
			if !(StrLen(cVal)) {
				GuiControl, , RegistryButton, Add Registry Entry
				MsgBox, 64, % gName . " - Registry Entry", Successfully removed from the right click menu				
			} else {			
				MsgBox, 48, % gName . " - Registry Entry", Could not remove the entry from the right click menu
			}
			
		}		
	}
return
	
ScriptNameNoExt() {
    SplitPath, A_ScriptName, , , , ScriptNameNoExt
    return ScriptNameNoExt
}

ConvertFAT(String)
{
	StringSplit, Path, String, \
	Loop, %Path0%
	{
		IfInString, Path%A_Index%, %A_Space%
		{
			StringReplace, Path%A_Index%, Path%A_Index%, %A_Space%
			StringLeft, Path%A_Index%, Path%A_Index%, 6
			Path%A_Index% := Path%A_Index% . "~1"
		}
		If A_Index = %Path0%
			Output := Output . Path%A_Index%
		Else
			Output := Output . Path%A_Index% . "\"
	}
	Return, Output
}
	
GuiClose:
	ExitApp
return
	
Reload:
	Reload
return 

Exit:
	ExitApp
return
