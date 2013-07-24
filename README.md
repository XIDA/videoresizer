Video Resizer
============

Convert and resize videos from right click menu using ffmpeg

This is just a simple Windows gui for ffmpeg to convert videos from the file explorer right click menu.

**Demo Video**
https://www.youtube.com/watch?v=EJu8sHGppGo&hd=1


**Installation**
- Download the repository as a zip and extract it
- Copy the bin/ folder to a location where you want to permanently store the applcation (like c:\tools\videoresizer)
- Download ffmpeg.exe from http://ffmpeg.zeranoe.com/builds/ (download 32 or 64bit version, depending on your windows version)
- Place ffmpeg in the same directory where you placed the other files (like VideoResizer.exe)
- Start VideoResizer.exe, it will add a shortcut to the right-click "sendTo" Menu
This will allow you to access the VideoResizer by simply right clicking a video file and choosing "sendTo" - "VideoResizer".
- Open the VideoResizer.ini file and change the settings to your needs
- Now you can drag video files on VideoResizer.exe and it will start conversion or use the "sendTo" menu entry

**Further information**
- The .ahk script can be compiled to .exe with www.autohotkey.com
- Sound is not changed from the video file
