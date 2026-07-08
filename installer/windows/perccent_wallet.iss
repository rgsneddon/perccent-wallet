; Perccent Wallet Windows installer (Inno Setup).
; Build: scripts\build_windows_installer.ps1

#ifndef WalletVersion
  #define WalletVersion "1.0.1"
#endif
#ifndef WalletBuild
  #define WalletBuild "2"
#endif

#define WalletAppName "Perccent Wallet"
#define WalletPublisher "Perccent Wallet"
#define WalletExeName "perccent_wallet.exe"
#define WalletReleaseDir "..\..\build\windows\x64\runner\Release"
#define WalletOutputBase "perccent-wallet-v" + WalletVersion + "-windows-x64-setup"

[Setup]
AppId={{B8E4D3F2-1C5A-4F9B-A2D7-PERCWALLET}
AppName={#WalletAppName}
AppVersion={#WalletVersion}
AppVerName={#WalletAppName} {#WalletVersion} (build {#WalletBuild})
AppPublisher={#WalletPublisher}
DefaultDirName={autopf}\{#WalletAppName}
DefaultGroupName={#WalletAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\build\installer\windows
OutputBaseFilename={#WalletOutputBase}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\{#WalletExeName}
VersionInfoVersion={#WalletVersion}.{#WalletBuild}
VersionInfoCompany={#WalletPublisher}
VersionInfoDescription={#WalletAppName} Windows installer
VersionInfoProductName={#WalletAppName}
VersionInfoProductVersion={#WalletVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#WalletReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#WalletAppName}"; Filename: "{app}\{#WalletExeName}"
Name: "{autodesktop}\{#WalletAppName}"; Filename: "{app}\{#WalletExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#WalletExeName}"; Description: "{cm:LaunchProgram,{#StringChange(WalletAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent