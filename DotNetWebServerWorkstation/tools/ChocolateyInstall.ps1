try {
    cinst IIS-WebServerRole -source windowsfeatures
    cinst IIS-HttpCompressionDynamic -source windowsfeatures
    cinst IIS-ManagementScriptingTools -source windowsfeatures
    cinst IIS-WindowsAuthentication -source windowsfeatures

    Write-ChocolateySuccess 'DotNetWebServerWorkstation'
} catch {
  Write-ChocolateyFailure 'DotNetWebServerWorkstation' $($_.Exception.Message)
  throw
}