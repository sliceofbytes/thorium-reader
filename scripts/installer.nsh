# Thorium Reader Custom Installer
# Fixed to ensure all variables are properly referenced

!include "LogicLib.nsh"

# Custom installation logic
!macro customInstall
  # Ask user during installation if they want portable mode
  MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to install Thorium Reader in portable mode?$\r$\n$\r$\nPortable mode:$\r$\n• Stores all data in the installation folder$\r$\n• Can run from USB drives$\r$\n• Easy to move to another computer$\r$\n$\r$\nChoose YES for portable mode, NO for standard installation." /SD IDNO IDYES portable_mode IDNO standard_mode
  
  portable_mode:
    DetailPrint "User selected: Portable installation"
    
    # Create portable marker file
    FileOpen $9 "$INSTDIR\THORIUM_PORTABLE" w
    FileWrite $9 "Thorium Reader - Portable Installation$\r$\n"
    FileWrite $9 "====================================$\r$\n$\r$\n"
    FileWrite $9 "This file indicates a portable installation.$\r$\n"
    FileWrite $9 "Application data is stored in: $INSTDIR\user_data\$\r$\n$\r$\n"
    FileWrite $9 "To launch portable mode:$\r$\n"
    FileWrite $9 "- Use the desktop/start menu shortcuts$\r$\n"
    FileWrite $9 "- Run LaunchPortable.bat$\r$\n"
    FileWrite $9 "- Run thorium.exe --portable$\r$\n$\r$\n"
    FileWrite $9 "To convert to standard installation:$\r$\n"
    FileWrite $9 "1. Delete this THORIUM_PORTABLE file$\r$\n"
    FileWrite $9 "2. Restart the application$\r$\n"
    FileClose $9
    
    # Create UserData directory for portable mode
    CreateDirectory "$INSTDIR\user_data"
    
    # Create portable launcher batch file
    FileOpen $9 "$INSTDIR\LaunchPortable.bat" w
    FileWrite $9 "@echo off$\r$\n"
    FileWrite $9 "title Thorium Reader Portable$\r$\n"
    FileWrite $9 "cd /d %~dp0$\r$\n"
    FileWrite $9 'start "" thorium.exe --portable$\r$\n'
    FileClose $9
    
    # Create README for portable users
    FileOpen $9 "$INSTDIR\PORTABLE_README.txt" w
    FileWrite $9 "THORIUM READER PORTABLE INSTALLATION$\r$\n"
    FileWrite $9 "===================================$\r$\n$\r$\n"
    FileWrite $9 "This is a portable installation of Thorium Reader.$\r$\n$\r$\n"
    FileWrite $9 "FEATURES:$\r$\n"
    FileWrite $9 "- All data stored in this folder$\r$\n"
    FileWrite $9 "- Can be moved to other computers$\r$\n"
    FileWrite $9 "- Can run from USB drives$\r$\n"
    FileWrite $9 "- No registry entries$\r$\n$\r$\n"
    FileWrite $9 "TO LAUNCH:$\r$\n"
    FileWrite $9 "1. Use the Thorium Reader executable in this folder with THORIUM_PORTABLE file present$\r$\n"
    FileWrite $9 "2. Use desktop/start menu shortcuts$\r$\n"
    FileWrite $9 "3. Double-click LaunchPortable.bat$\r$\n"
    FileWrite $9 "4. Run: thorium.exe --portable$\r$\n$\r$\n"
    FileWrite $9 "DATA LOCATION: UserData\ folder$\r$\n"
    FileClose $9
    
    DetailPrint "Portable installation configured successfully"
    Goto install_done
    
  standard_mode:
    DetailPrint "User selected: Standard installation"
    
  install_done:
!macroend

# Custom shortcut modification
!macro customInstallMode
  # Check if THORIUM_PORTABLE exists to determine if this is a portable installation
  ${If} ${FileExists} "$INSTDIR\THORIUM_PORTABLE"
    DetailPrint "Creating portable shortcuts..."
    
    # Update desktop shortcut if it exists
    ${If} ${FileExists} "$DESKTOP\${PRODUCT_FILENAME}.lnk"
      Delete "$DESKTOP\${PRODUCT_FILENAME}.lnk"
      CreateShortCut "$DESKTOP\Thorium Reader (Portable).lnk" "$INSTDIR\thorium.exe" "--portable" "$INSTDIR\thorium.exe" 0
      DetailPrint "Created portable desktop shortcut"
    ${EndIf}
    
    # Update start menu shortcut if it exists
    ${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\${PRODUCT_FILENAME}.lnk"
      Delete "$SMPROGRAMS\$StartMenuFolder\${PRODUCT_FILENAME}.lnk"
      CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Thorium Reader (Portable).lnk" "$INSTDIR\thorium.exe" "--portable" "$INSTDIR\thorium.exe" 0
      DetailPrint "Created portable start menu shortcut"
    ${EndIf}
    
    # Create additional desktop shortcut for the batch launcher
    CreateShortCut "$DESKTOP\Launch Thorium Portable.lnk" "$INSTDIR\LaunchPortable.bat" "" "$INSTDIR\thorium.exe" 0
    
    DetailPrint "Portable shortcuts created successfully"
  ${Else}
    DetailPrint "Standard installation shortcuts created"
  ${EndIf}
!macroend

# Custom uninstall logic
!macro customUnInstall
  # Check if this was a portable installation
  ${If} ${FileExists} "$INSTDIR\THORIUM_PORTABLE"
    MessageBox MB_YESNO|MB_ICONQUESTION "This is a portable installation.$\r$\n$\r$\nDo you want to remove your application data as well?$\r$\n$\r$\n• Choose YES to completely remove everything$\r$\n• Choose NO to keep your data for future use" /SD IDNO IDNO SkipPortableDataRemoval
    
    # User chose to remove portable data
    DetailPrint "Removing portable installation data..."
    RMDir /r "$INSTDIR\user_data"
    Delete "$INSTDIR\THORIUM_PORTABLE"
    Delete "$INSTDIR\LaunchPortable.bat"
    Delete "$INSTDIR\PORTABLE_README.txt"
    Delete "$DESKTOP\Launch Thorium Portable.lnk"
    DetailPrint "Portable data and launchers removed"
    Goto PortableUninstallDone
    
    SkipPortableDataRemoval:
    DetailPrint "Portable data preserved in $INSTDIR\user_data"
    
    PortableUninstallDone:
  ${EndIf}
!macroend
