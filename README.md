# Communary.MUC

This module lets you easily check for updates to installed PowerShell modules.

Since the check itself takes quite some time, at least if you have many modules installed,
you can use the **Install-ModuleUpdatesCheck** to install a scheduled task that does the
checking in the background. The results will be written to a file which is read when you
use the **Get-ModuleUpdates** function.

This way you can get a list of available module updates listed as part of your PowerShell
profile if you want to.

## Functions
- Find-ModuleUpdates
- Save-ModuleUpdates
- Get-ModuleUpdates
- Install-ModuleUpdatesCheck

## Installation
```powershell
Install-Module -Name Communary.MUC -Scope CurrentUser
```

## NOTE
To be able to install the scheduled job, the command need to be executed in an elevated context.