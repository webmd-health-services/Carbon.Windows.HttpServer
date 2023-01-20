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

    $ipAddress = '1.2.3.4'
    $script:ipNum = 1
    $appID = '454f19a6-3ea8-434c-874f-3a860778e4af'

    $certPath = Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.pfx' -Resolve
    $script:cert = Install-CCertificate -Path $certPath -StoreLocation LocalMachine -StoreName My -PassThru

    $lastBinding = Get-CHttpsCertificateBinding | Sort-Object -Property 'Port' | Sort-Object | Select-Object -Last 1
    $script:port = 44444
    if ($lastBinding)
    {
        $script:port = $lastBinding.Port + 1
    }
    $script:appId = '9236e152-2b3e-4674-a410-58f2d218c66c'

    function New-IPAddress
    {
        param(
            [switch] $V6
        )

        [ipaddress] $ipAddress = "$($script:ipNum).$($script:ipNum).$($script:ipNum).$($script:ipNum)"
        if ($V6)
        {
            $ipAddress = "::$($script:ipNum)"
        }
        $script:ipNum += 1
        return $ipAddress
    }

    function GivenBinding
    {
        param(
            [ipaddress] $IPAddress = (New-IPAddress),

            [UInt64] $Port = $script:port
        )

        Set-CHttpsCertificateBinding -IPAddress $IPAddress `
                                   -Port $Port `
                                   -Thumbprint $script:cert.Thumbprint `
                                   -ApplicationID $script:appID
    }

    function ThenNoErrors
    {
        $Global:Error | Should -BeNullOrEmpty
    }
}

AfterAll {
    Remove-CHttpsCertificateBinding -ApplicationID $script:appID -ErrorAction Ignore
    Remove-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint -ErrorAction Ignore
    Uninstall-CCertificate -Certificate $script:cert -StoreLocation LocalMachine -StoreName My
}

Describe 'Remove-CHttpsCertificateBinding' {
    BeforeEach {
        $Global:Error.Clear()
    }

    AfterEach {
        Remove-CHttpsCertificateBinding -ApplicationID $script:appID -ErrorAction Ignore
        Remove-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint -ErrorAction Ignore

        $script:port += 1
    }

    It 'should remove non existent binding' {
        $currentBindings = Get-CHttpsCertificateBinding
        Remove-CHttpsCertificateBinding -IPAddress (New-IPAddress) -ErrorAction SilentlyContinue
        Remove-CHttpsCertificateBinding -IPAddress (New-IPAddress -V6) -ErrorAction SilentlyContinue
        Remove-CHttpsCertificateBinding -Port $script:port -ErrorAction SilentlyContinue
        Remove-CHttpsCertificateBinding -Thumbprint 'deadbee' -ErrorAction SilentlyContinue
        Remove-CHttpsCertificateBinding -ApplicationID ([Guid]::NewGuid()) -ErrorAction SilentlyContinue
        $Global:Error | Should -Match 'because it does not exist'
        Get-CHttpsCertificateBinding | Should -HaveCount $currentBindings.Count

        $Global:Error.Clear()
        Remove-CHttpsCertificateBinding -IPAddress (New-IPAddress) -ErrorAction Ignore
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'should not remove certificate' {
        GivenBinding
        Remove-CHttpsCertificateBinding -ApplicationID $script:appID -WhatIf
        ThenNoErrors
        Test-CHttpsCertificateBinding -ApplicationID $script:appID | Should -BeTrue
    }

    It 'should remove binding by IP v4 address' {
        $ipAddress = New-IPAddress
        GivenBinding -IPAddress $ipAddress
        Remove-CHttpsCertificateBinding -IPAddress $ipAddress
        ThenNoErrors
        Test-CHttpsCertificateBinding -IPAddress $ipAddress | Should -BeFalse
    }

    It 'should remove binding by IP v6 address' {
        $ipAddress = New-IPAddress -V6
        GivenBinding -IPAddress $ipAddress
        Remove-CHttpsCertificateBinding -IPAddress $ipAddress
        ThenNoErrors
        Test-CHttpsCertificateBinding -IPAddress $ipAddress | Should -BeFalse
    }

    It 'should remove binding by certificate thumbprint' {
        GivenBinding
        Remove-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint
        ThenNoErrors
        Test-CHttpsCertificateBinding -Thumbprint $script:cert.Thumbprint | Should -BeFalse
    }

    It 'should remove binding by application ID' {
        GivenBinding
        Remove-CHttpsCertificateBinding -ApplicationID $script:appId
        ThenNoErrors
        Test-CHttpsCertificateBinding -ApplicationID $script:appId | Should -BeFalse
    }

    It 'should remove binding using multiple criteria' {
        $ip1 = New-IPAddress
        GivenBinding -IPAddress $ip1
        $ip2 = New-IPAddress
        GivenBinding -IPAddress $ip2
        Remove-CHttpsCertificateBinding -IPAddress $ip1 -Port $script:port
        ThenNoErrors
        Test-CHttpsCertificateBinding -IPAddress $ip1 | Should -BeFalse
        Test-CHttpsCertificateBinding -IPAddress $ip2 | Should -BeTrue
    }

    It 'should accept pipeline input' {
        GivenBinding
        GivenBinding
        Get-CHttpsCertificateBinding -ApplicationID $script:appID | Should -HaveCount 2
        Get-CHttpsCertificateBinding -ApplicationID $script:appID | Remove-CHttpsCertificateBinding
        Get-CHttpsCertificateBinding -ApplicationID $script:appID -ErrorAction Ignore | Should -BeNullOrEmpty
    }

    It 'should remove all bindings' {
        GivenBinding
        $bindings = Get-CHttpsCertificateBinding
        Mock -CommandName 'Invoke-Netsh' -ModuleName 'Carbon.Windows.HttpServer'
        Remove-CHttpsCertificateBinding -Force
        Assert-MockCalled -CommandName 'Invoke-Netsh' -ModuleName 'Carbon.Windows.HttpServer' -ParameterFilter {
            $ArgumentList[0] | Should -Be 'http'
            $ArgumentList[1] | Should -Be 'delete'
            $true
        } -Times $bindings.Count -Exactly
        ThenNoErrors
    }
}
