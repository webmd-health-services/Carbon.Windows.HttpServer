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

    $cert = $null
    $ipAddress = '1.2.3.4'
    $ipV6Address = '::1234'
    $port = '8483'
    $ipPort = '{0}:{1}' -f $ipAddress,$port
    $ipv6Port = '[{0}]:{1}' -f $ipV6Address,$port
    $appID = '454f19a6-3ea8-434c-874f-3a860778e4af'
    $ipV6AppID = 'b01fa31e-d255-48df-983e-c5c6dd0ccd03'
}

Describe 'Remove-CHttpsCertificateBinding' {
    BeforeEach {
        $cert = Install-CCertificate -Path (Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.cer' -Resolve) `
                                     -StoreLocation LocalMachine `
                                     -StoreName My `
                                     -PassThru
        netsh http add sslcert ipport=$ipPort "certhash=$($cert.Thumbprint)" "appid={$appID}"
        netsh http add sslcert ipport=$ipV6Port "certhash=$($cert.Thumbprint)" "appid={$ipV6AppID}"
    }

    AfterEach {
        netsh http delete sslcert ipport=$ipPort
        netsh http delete sslcerrt ipport=$ipV6Port

        Uninstall-CCertificate -Certificate $cert -StoreLocation LocalMachine -StoreName My
    }

    It 'should remove non existent binding' {
        $bindings = @( Get-CHttpsCertificateBinding )
        Remove-CHttpsCertificateBinding -IPAddress '1.2.3.4' -Port '8332'
        $newBindings = @( Get-CHttpsCertificateBinding )
        $newBindings.Length | Should -Be $bindings.Length
    }

    It 'should not remove certificate what if' {
        Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -WhatIf
        (Test-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port) | Should -BeTrue
    }

    It 'should remove binding' {
        Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        (Test-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port) | Should -BeFalse
    }

    It 'should remove i pv6 binding' {
        Remove-CHttpsCertificateBinding -IPAddress $ipV6Address -Port $port
        (Test-CHttpsCertificateBinding -IPAddress $ipV6Address -Port $port) | Should -BeFalse
    }
}
