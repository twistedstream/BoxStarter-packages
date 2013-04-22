try {

    cinstm VisualStudio2012Ultimate
    if((Get-Item "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe").VersionInfo.ProductVersion -lt "11.0.60115.1") {
        if(Test-PendingReboot){Invoke-Reboot}
        Install-ChocolateyPackage 'vs update 2 ctp2' 'exe' '/passive /norestart' 'http://download.microsoft.com/download/8/9/3/89372D24-6707-4587-A7F0-10A29EECA317/vsupdate_KB2707250.exe'
    }
    cinstm dotpeek
    cinstm NugetPackageExplorer
    cinstm resharper
    cinstm Paint.net
    cinstm windbg

    cinst IIS-WebServerRole -source windowsfeatures
    cinst IIS-HttpCompressionDynamic -source windowsfeatures
    cinst IIS-ManagementScriptingTools -source windowsfeatures
    cinst IIS-WindowsAuthentication -source windowsfeatures

    Write-ChocolateySuccess 'DotNetWeb'
} catch {
  Write-ChocolateyFailure 'DotNetWeb' $($_.Exception.Message)
  throw
}