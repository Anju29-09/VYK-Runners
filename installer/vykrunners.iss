; Inno Setup script for the VYK Runners Windows desktop build.
; Compile with: ISCC.exe /DMyAppVersion=1.0.0 installer\vykrunners.iss
; Expects `flutter build windows --release` to have been run first.

#define MyAppName "VYK Runners"
#define MyAppExeName "vykrunners_flutter.exe"
#define MyAppPublisher "VYK Runners"
#define MyAppURL "https://github.com/Anju29-09/VYK-Runners"

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

[Setup]
AppId={{8F3A1C7E-4D62-4B19-9E5A-2C7B6D840F31}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputDir=Output
OutputBaseFilename=VYKRunners-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

; Per-user install into %LocalAppData%\Programs — no admin rights, no UAC prompt.
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
