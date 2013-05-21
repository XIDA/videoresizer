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
- Start VideoResizer.exe, it will ask you for admin rights (if needed) and will also ask you if you want to add it to the registry
This will allow you to access the VideoResizer by simply right clicking a video file and choosing "Resize Video".
If you don't want that you can skip this step
- Open the VideoResizer.ini file and change the settings to your needs
- Now you can drag video files on VideoResizer.exe and it will start conversion

**Further information**
- The .ahk script can be compiled to the .exe with www.autohotkey.com
- Sound is not changed from the video file
