
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenModuleLoaded
    {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Windows.HttpServer\Carbon.Windows.HttpServer.psd1' -Resolve)
        Get-Module -Name 'Carbon.Windows.HttpServer' | Add-Member -MemberType NoteProperty -Name 'NotReloaded' -Value $true
    }

    function GivenModuleNotLoaded
    {
        Remove-Module -Name 'Carbon.Windows.HttpServer' -Force -ErrorAction Ignore
    }

    function ThenModuleLoaded
    {
        $module = Get-Module -Name 'Carbon.Windows.HttpServer'
        $module | Should -Not -BeNullOrEmpty
        $module | Get-Member -Name 'NotReloaded' | Should -BeNullOrEmpty
    }

    function WhenImporting
    {
        $script:importedAt = Get-Date
        Start-Sleep -Milliseconds 1
        & (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Windows.HttpServer\Import-Carbon.Windows.HttpServer.ps1' -Resolve)
    }
}

Describe 'Import-Carbon.Windows.HttpServer' {
    It 'should import the module' {
        GivenModuleNotLoaded
        WhenImporting
        ThenModuleLoaded
    }

    It 'should re-import the module' {
        GivenModuleLoaded
        WhenImporting
        ThenModuleLoaded
    }
}
