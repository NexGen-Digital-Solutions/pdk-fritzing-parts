# Windows Installer Design

The installer copies parts into Fritzing's per-user library and writes a standard `.fzb` bin into the user's Fritzing bins folder.

The bin's `icon` attribute references `PDK.png`. Fritzing resolves custom bin icons relative to the `.fzb` file, so both `PDK.png` and `PDK-mono.png` are installed beside the bin.

The generated bin contains one `<instance>` entry per part with the module ID and absolute path to the installed FZP.

A PowerShell implementation is used because it can:

- Resolve the real Documents folder, including redirected or OneDrive-backed paths
- Create backups
- Generate absolute XML paths at install time
- Avoid administrator privileges
- Launch Fritzing after installation

An Inno Setup source file is included for producing a conventional `.exe` wrapper.
