function Find-ModuleUpdates {

    Get-Module -ListAvailable -Verbose:$false | Group-Object -Property Name | ForEach-Object {

        $installedModule = $_.Group | Sort-Object -Property Version -Descending | Select-Object -First 1
        $onlineModule = Find-Module -Name $installedModule.Name -Verbose:$false -ErrorAction SilentlyContinue

        if ($onlineModule) {

            $onlineVersion = $onlineModule.Version
            $installedVersion = $installedModule.Version

            if ($onlineVersion -gt $installedVersion) {

                Write-Output ([PSCustomObject] [Ordered] @{
                    Name = $onlineModule.Name
                    InstalledVersion = $installedVersion
                    OnlineVersion = $onlineVersion
                })
            }
        }
    }
}

function Save-ModuleUpdates {
    $updatesPath = Join-Path $env:HOMEDRIVE (Join-Path $env:HOMEPATH 'availableModuleUpdates.xml')
    Find-ModuleUpdates | Export-Clixml -Path $updatesPath -Force
}

function Get-ModuleUpdates {
    $updatesPath = Join-Path $env:HOMEDRIVE (Join-Path $env:HOMEPATH 'availableModuleUpdates.xml')
    if (Test-Path -Path $updatesPath) {
        Import-Clixml -Path $updatesPath
    }
}

function Install-ModuleUpdatesCheck {

    $taskName = 'ModuleUpdatesCheck'

    if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        try {
            $taskAction = New-ScheduledTaskAction -Argument '-noprofile -command "& {Save-ModuleUpdates}' -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
            $taskTrigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay (New-TimeSpan -Minutes 15)
            $taskSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1)
            $taskPrincipal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
            $scheduledTask = New-ScheduledTask -Action $taskAction -Principal $taskPrincipal -Trigger $taskTrigger -Settings $taskSettings -Description "Module Updates Check"
            Register-ScheduledTask -TaskName $taskName -TaskPath '\' -InputObject $scheduledTask -Force
        }
        catch {
            Write-Warning -Message $_.Exception.Message
        }
    }

    else {
        Write-Host 'Task already installed.'
    }
}