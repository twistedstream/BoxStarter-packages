function SetOrAdd-ItemProperty ($key, $name, $value) {
    if (!(Test-Path $key)) {
        New-Item $key > $null
    }

    Set-ItemProperty $key $name $value
}

function Disable-ShutdownEventTracker {
    # source: http://technet.microsoft.com/en-us/library/cc776766(v=ws.10).aspx
    
    Out-BoxstarterLog "Disable: Shutdown Event Tracker..."
    SetOrAdd-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" `
                          "ShutdownreasonOn" `
                          0
}

function Disable-CrtlAltDeleteAtLogon {
    # source: http://www.win2008workstation.com/disabling-the-ctrlaltdel-prompt/#comment-113

    Out-BoxstarterLog "Disable: Crtl+Alt+Delete at login..."
    SetOrAdd-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
                          "DisableCAD" `
                          1
}

function Enable-PerformanceForPrograms {
    # source: http://social.technet.microsoft.com/Forums/en-US/winservergen/thread/be3eb9a9-8266-406f-97ad-ef7d9f06cd46/

    Out-BoxstarterLog "Enabling: Performance for Programs..."
    SetOrAdd-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
                          "Win32PrioritySeparation" `
                          38
}

function Disable-ServerManagerAtLogon {
    # source: http://serverfault.com/questions/402440/turn-off-server-manager-on-login

    Out-BoxstarterLog "Disabling: opening Server Manager at logon..."
    SetOrAdd-ItemProperty "HKLM:\Software\Microsoft\ServerManager" `
                          "DoNotOpenServerManagerAtLogon" `
                          1
}

function Enable-AudioService {
    Out-BoxstarterLog "Enabling: Audio service..."
    Set-Service Audiosrv -startuptype automatic
}

function Reboot-IfNoThemesService {
    $service = Get-Service | where { $_.ServiceName -eq "Themes" }

    if ($service) {
        Out-BoxstarterLog "Themes service exists.  No reboot requires."
    } else {
        Out-BoxstarterLog "Themes service does not exist.  Performing reboot..."
        Invoke-Reboot
    }
}

function Enable-ThemesService {
    Out-BoxstarterLog "Enabling: Themes service..."
    Set-Service Themes -startuptype automatic
}

function Enable-DesktopExperience {
    Import-Module ServerManager
    Out-BoxstarterLog "Enabling: Desktop Experience..."
    Add-WindowsFeature Desktop-Experience
}

function Enable-PowerShellISE {
    Import-Module ServerManager
    Out-BoxstarterLog "Enabling: PowerShell Integrate Scripting Environment (ISE)..."
    Add-WindowsFeature PowerShell-ISE
}

function Enable-TelnetClient {
    Import-Module ServerManager
    Out-BoxstarterLog "Enabling: Telnet Client..."
    Add-WindowsFeature Telnet-Client
}

function Set-MoreExplorerOptions {
    param(
        [switch] $lockTheTaskBar,
        [switch] $showAllFoldersInExplorerNavigation,
        [switch] $automaticallyExpandToCurrentFolderInExplorerNavigation
    )

    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    if ($lockTheTaskBar) { Set-ItemProperty $key TaskbarSizeMove 0 }
    if ($showAllFoldersInExplorerNavigation) { Set-ItemProperty $key NavPaneShowAllFolders 1 }
    if ($automaticallyExpandToCurrentFolderInExplorerNavigation) { Set-ItemProperty $key NavPaneExpandToCurrentFolder 1 }
}

try {
    $Boxstarter.RebootOk = $true

    Install-WindowsUpdate -AcceptEula
    Disable-UAC
    Disable-InternetExplorerESC
    Update-ExecutionPolicy Unrestricted
    Set-ExplorerOptions -showHidenFilesFoldersDrives -showFileExtensions
    Set-MoreExplorerOptions -lockTheTaskBar -showAllFoldersInExplorerNavigation -automaticallyExpandToCurrentFolderInExplorerNavigation
    Enable-RemoteDesktop    
    Disable-ShutdownEventTracker
    Disable-CrtlAltDeleteAtLogon
    Enable-PerformanceForPrograms
    Disable-ServerManagerAtLogon
    Enable-DesktopExperience

    Enable-AudioService
    Reboot-IfNoThemesService
    Enable-ThemesService
    Enable-PowerShellISE
    Enable-TelnetClient

    cinstm Console2
    cinstm notepadplusplus
    cinstm sublimetext2
    cinstm GoogleChrome
    cinstm Firefox
    cinstm beyondcompare
    cinstm fiddler
    cinstm windirstat
    cinstm sysinternals

    $sublimeDir = "$env:programfiles\Sublime Text 2"

    Install-ChocolateyPinnedTaskBarItem "$sublimeDir\sublime_text.exe"

    Write-ChocolateySuccess 'ServerAsWorkstation'
} catch {
  Write-ChocolateyFailure 'ServerAsWorkstation' $($_.Exception.Message)
  throw
}