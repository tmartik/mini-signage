; The name of the installer
Name "Mini Signage"

; The file to write
OutFile "Mini Signage Setup.exe"

; Request elevated privileges 
RequestExecutionLevel admin

; Build Unicode installer
Unicode False

; The default installation directory
InstallDir $PROGRAMFILES\Mini-Signage

;--------------------------------

LicenseData "license.txt" 
	
; Pages
Page license
Page directory
Page instfiles

;--------------------------------

; The stuff to install
Section ""

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put files there
  File /r "deployment\*"
  
  ; Put to Windows startup
  CreateShortCut "$SMSTARTUP\Mini-Signage.lnk" "$INSTDIR\Mini-Signage.exe" "config.json"
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
SectionEnd

;Uninstaller Section
Section "Uninstall"
 
  Delete "$INSTDIR\*"
  Delete "$SMSTARTUP\Mini-Signage.lnk"
 
  RMDIR /r /REBOOTOK "$INSTDIR"
  
SectionEnd
