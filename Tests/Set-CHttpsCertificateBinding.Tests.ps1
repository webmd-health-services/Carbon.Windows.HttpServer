# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Requires -Version 5.1
#Requires -RunAsAdministrator
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [ipaddress] $script:ipAddress = $null
    [ipaddress] $script:ipv6Addres = $null
    $script:cert = $null
    $certPath = Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.pfx' -Resolve
    $script:cert = Install-CCertificate -Path $certPath -StoreLocation LocalMachine  -StoreName My  -PassThru
    $certPath = Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate2.pfx' -Resolve
    $script:cert2 = Install-CCertificate -Path $certPath -StoreLocation LocalMachine  -StoreName My  -PassThru
    $script:testNum = 1
    $lastBinding = Get-CHttpsCertificateBinding | Sort-Object -Property 'Port' | Sort-Object | Select-Object -Last 1
    $script:port = 44444
    if ($lastBinding)
    {
        $script:port = $lastBinding.Port + 1
    }
}

AfterAll {
    Uninstall-CCertificate -Certificate $script:cert -StoreLocation LocalMachine -StoreName My
    Uninstall-CCertificate -Certificate $script:cert2 -StoreLocation LocalMachine -StoreName My
}

Describe 'Set-CHttpsCertificateBinding' {
    BeforeEach {
        $Global:Error.Clear()
        $script:appId = [Guid]::NewGuid()
        $script:ipAddress = "$($script:testNum).$($script:testNum).$($script:testNum).$($script:testNum)"
        $script:ipv6Address = "::$($script:testNum)"
    }

    AfterEach {
        $script:testNum += 1
        $script:port += 1

        Remove-CHttpsCertificateBinding -IPAddress $script:ipAddress -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -IPAddress $script:ipv6Address -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -Port $script:port -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -ApplicationID $script:appId -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -Thumbprint $script:cert2.Thumbprint -ErrorAction Ignore
    }

    It 'should create new HTTPS certificate binding' {
        Test-CHttpsCertificateBinding -IPAddress $script:ipAddress -Port $script:port | Should -BeFalse
        $binding = Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                              -Port $script:port `
                                              -ApplicationID $script:appId `
                                              -Thumbprint $script:cert.Thumbprint
        $binding | Should -BeNullOrEmpty
        $binding = Get-CHttpsCertificateBinding -IPAddress $script:ipAddress -Port $script:port
        $binding | Should -Not -BeNullOrEmpty
        $ipPort = '{0}:{1}' -f $script:ipAddress,$script:port
        $binding.IPPort | Should -Be $ipPort
        $binding.ApplicationID | Should -Be $script:appId
        $binding.CertificateHash | Should -Be $script:cert.Thumbprint
        $binding.CertificateStoreName | Should -Be 'My'
    }

    It 'should return binding' {
        $binding = Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                              -Port $script:port `
                                              -ApplicationID $script:appId `
                                              -Thumbprint $script:cert.Thumbprint `
                                              -PassThru

        $binding | Should -Not -BeNullOrEmpty
        $expectedBinding = Get-CHttpsCertificateBinding -IPAddress $script:ipAddress -Port $script:port
        $binding | Should -Be $expectedBinding
        $ipPort = '{0}:{1}' -f $script:ipAddress,$script:port
        $binding.IPPort | Should -Be $ipPort
        $expectedBinding.IPPort | Should -Be $ipPort
        $binding.ApplicationID | Should -Be $script:appId
        $expectedBinding.ApplicationID | Should -Be $script:appId
        $binding.CertificateHash | Should -Be $script:cert.Thumbprint
        $expectedBinding.CertificateHash | Should -Be $script:cert.Thumbprint
        $binding.CertificateStoreName | Should -Be 'My'
        $expectedBinding.CertificateStoreName | Should -Be 'My'
    }

    It 'should update existing HTTPS certificate binding' {
        $newAppID = '353364bb-1ca8-4d6c-a596-be7608d57771'
        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $script:appId `
                                   -Thumbprint $script:cert.Thumbprint

        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $newAppID `
                                   -Thumbprint $script:cert.Thumbprint
        Test-CHttpsCertificateBinding -ApplicationID $script:appId | Should -BeFalse
        Test-CHttpsCertificateBinding -ApplicationID $newAppID | Should -BeTrue

        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $newAppID `
                                   -Thumbprint $script:cert2.Thumbprint
        Test-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint | Should -BeFalse
        Test-CHttpsCertificateBinding -Thumbprint $script:cert2.Thumbprint | Should -BeTrue

        $Global:Error | Should -BeNullOrEmpty
    }

    It 'should not create binding' {
        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $script:appId `
                                   -Thumbprint $script:cert.Thumbprint `
                                   -WhatIf
        Test-CHttpsCertificateBinding -IPAddress $script:ipAddress -Port $script:port | Should -BeFalse
    }

    It 'should not update binding' {
        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $script:appId `
                                   -Thumbprint $script:cert.Thumbprint

        Mock -CommandName 'Remove-CHttpsCertificateBinding' -ModuleName 'Carbon.Windows.HttpServer'
        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $script:appId `
                                   -Thumbprint $script:cert.Thumbprint

        Assert-MockCalled -CommandName 'Remove-CHttpsCertificateBinding' -ModuleName 'Carbon.Windows.HttpServer' -Times 0
        $Global:Error | Should -BeNullOrEmpty
        $newAppId = [Guid]::NewGuid()
        Set-CHttpsCertificateBinding -IPAddress $script:ipAddress `
                                   -Port $script:port `
                                   -ApplicationID $newAppId `
                                   -Thumbprint $script:cert.Thumbprint `
                                   -WhatIf

        Assert-MockCalled -CommandName 'Remove-CHttpsCertificateBinding' -ModuleName 'Carbon.Windows.HttpServer' -Times 1
        Test-CHttpsCertificateBinding -ApplicationID $script:appId | Should -BeTrue
        Test-CHttpsCertificateBinding -ApplicationID $newAppId | Should -BeFalse
    }


    It 'should support ipv6 address' {
        Set-CHttpsCertificateBinding -IPAddress $script:ipv6Address `
                                   -Port $script:port `
                                   -ApplicationID $script:appId `
                                   -Thumbprint $script:cert.Thumbprint
        $binding = Get-CHttpsCertificateBinding -IPAddress $script:ipv6Address
        $binding.ApplicationID | Should -Be $script:appId
    }
}
