
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $certPath = Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.pfx' -Resolve
    $script:cert = Install-CCertificate -Path $certPath -StoreLocation LocalMachine -StoreName My -PassThru

    $lastBinding = Get-CHttpsCertificateBinding | Sort-Object -Property 'Port' | Sort-Object | Select-Object -Last 1
    $script:port = 44444
    if ($lastBinding)
    {
        $script:port = $lastBinding.Port + 1
    }
    $script:appId = '9236e152-2b3e-4674-a410-58f2d218c66c'
    [ipaddress] $script:ipAddress = '255.255.255.255'
    Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                               -Port $script:port `
                               -Thumbprint $script:cert.Thumbprint `
                               -ApplicationID $script:appId
}

AfterAll {
    Remove-CHttpsCertificateBinding -Port $script:port -ErrorAction Ignore
    Remove-CHttpsCertificateBinding -IPAddress $script:ipAddress -ErrorAction Ignore
    Uninstall-CCertificate -Thumbprint $script:cert
}

Describe 'Test-CHttpsCertificateBinding' {
    BeforeEach {
        $Global:Error.Clear()
    }

    AfterEach {
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'should find binding by IP address' {
        Test-CHttpsCertificateBinding -IPAddress $script:ipAddress | Should -BeTrue
    }

    It 'should find binding by port' {
        Test-CHttpsCertificateBinding -Port $script:port | Should -BeTrue
    }

    It 'should find binding by thumbprint' {
        Test-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint | Should -BeTrue
    }

    It 'should find binding by application ID' {
        Test-CHttpsCertificateBinding -ApplicationID $script:appId | Should -BeTrue
    }

}

