$javaHomeVariable = "JAVA_HOME"

try {

    Out-BoxstarterLog "Install: JDK..."    
    & (Join-Path $(Split-Path -parent $MyInvocation.MyCommand.Definition) 'jdk-7u17-windows-x64.exe') /passive
    Out-BoxstarterLog "Configure: Java home variable and path"    
    Install-ChocolateyEnvironmentVariable "JAVA_HOME" (Join-Path $Env:ProgramW6432 "Java\jdk1.7.0_17") Machine
    Install-ChocolateyPath "%JAVA_HOME%\bin" Machine

    cinstm Grails

    Write-ChocolateySuccess 'Grails'
} catch {
  Write-ChocolateyFailure 'Grails' $($_.Exception.Message)
  throw
}