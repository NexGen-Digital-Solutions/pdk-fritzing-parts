#define MyAppName "PDK Fritzing Library"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "NexGen Digital Solutions"

[Setup]
AppId={{B5FEF289-10A0-49DD-9AAC-58B9F64182DC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\PDK Fritzing Library
DisableProgramGroupPage=yes
OutputBaseFilename=PDK-Fritzing-Library-Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
WizardStyle=modern

[Files]
Source: "..\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
Filename: "{cmd}"; Parameters: "/c ""{app}\Install PDK Fritzing Library.cmd"""; Description: "Install the PDK parts into Fritzing"; Flags: postinstall waituntilterminated
