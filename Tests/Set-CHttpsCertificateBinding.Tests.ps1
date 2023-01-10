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

    $script:cert = $null
}

Describe 'Set-CHttpsCertificateBinding' {
    BeforeEach {
        $script:cert =
            Install-CCertificate -Path (Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.cer' -Resolve) `
                                 -StoreLocation LocalMachine `
                                 -StoreName My `
                                 -PassThru
    }

    AfterEach {
        Uninstall-CCertificate -Certificate $script:cert -StoreLocation LocalMachine -StoreName My
    }

    It 'should create new HTTPS certificate binding' {
        $appID = '0e8a659e-8034-4ab1-ab82-dcb0f5e90bfd'
        $ipAddress = '74.32.80.43'
        $port = '3847'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint
        try
        {
            $binding | Should -BeNullOrEmpty
            $binding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
            $ipPort = '{0}:{1}' -f $ipAddress,$port
            $binding.IPPort | Should -Be $ipPort
            $binding.ApplicationID | Should -Be $appID
            $binding.CertificateHash | Should -Be $script:cert.Thumbprint
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }

    It 'should return binding' {
        $appID = '0e8a659e-8034-4ab1-ab82-dcb0f5e90bfd'
        $ipAddress = '74.32.80.43'
        $port = '3847'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint -PassThru
        $expectedBinding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        try
        {
            $binding | Should -Not -BeNullOrEmpty
            $binding | Should -Be $expectedBinding
            $ipPort = '{0}:{1}' -f $ipAddress,$port
            $binding.IPPort | Should -Be $ipPort
            $binding.ApplicationID | Should -Be $appID
            $binding.CertificateHash | Should -Be $script:cert.Thumbprint
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }

    It 'should update existing HTTPS certificate binding' {
        $appID = '40f5bb4b-569b-47a8-a0cb-39ed797ce8ea'
        $newAppID = '353364bb-1ca8-4d6c-a596-be7608d57771'
        $ipAddress = '74.38.209.47'
        $port = '8823'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint
        $binding | Should -BeNullOrEmpty
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $newAppID -Thumbprint $script:cert.Thumbprint
        $binding | Should -BeNullOrEmpty
        $binding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        try
        {
            $binding.ApplicationID | Should -Be $newAppID
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }

    It 'should support should process' {
        $appID = '411b1023-be42-458e-8fe7-a7ab6c908566'
        $ipAddress = '54.72.38.90'
        $port = '4782'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint -WhatIf
        $binding | Should -BeNullOrEmpty
        try
        {
            (Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port) | Should -BeNullOrEmpty
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }

    It 'should support should process on binding update' {
        $appID = '411b1023-be42-458e-8fe7-a7ab6c908566'
        $newAppID = 'db48e0ec-6d8c-4b2c-9486-a2bb33c68b05'
        $ipAddress = '54.237.80.94'
        $port = '7821'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint
        $binding | Should -BeNullOrEmpty
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $newAppID -Thumbprint $script:cert.Thumbprint -WhatIf
        $binding | Should -BeNullOrEmpty
        $binding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        try
        {
            $binding.ApplicationID | Should -Be $appID
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }


    It 'should support i pv6 address' {
        $appID = '9aa262a9-dfb3-49db-b368-9f15bc12168c'
        $ipAddress = '[::]'
        $port = '7821'
        $binding = Set-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port -ApplicationID $appID -Thumbprint $script:cert.Thumbprint
        try
        {
            $binding | Should -BeNullOrEmpty
            $binding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
            $binding.ApplicationID | Should -Be $appID
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
        }
    }
}
