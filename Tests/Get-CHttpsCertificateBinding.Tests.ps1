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
}

Describe 'Get-CHttpsCertificateBinding' {
    It 'should get all bindings' {
        $output = netsh http show sslcert
        foreach ($line in $output)
        {
            if ($line -notmatch '^    (.*)\s+: (.*)$')
            {
                return
            }

            Write-Debug -Message $line
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()

            if( $value -eq '(null)' )
            {
                $value = ''
            }
            elseif( $value -eq 'Enabled' )
            {
                $value = $true
            }
            elseif( $value -eq 'Disabled' )
            {
                $value = $false
            }

            if( $name -eq 'IP:port' )
            {
                if( $value -notmatch '^(.*):(\d+)$' )
                {
                    Write-Error ('Invalid IP address/port: {0}' -f $value)
                }
                else
                {
                    $ipAddress = $matches[1]
                    $port = $matches[2]
                    $binding = Get-CHttpsCertificateBinding -IPAddress $ipAddress -Port $port
                    $binding.IPAddress | Should -Be ([ipaddress]$ipAddress)
                    $binding.Port | Should -Be $port
                }
            }
            elseif( $name -eq 'Certificate Hash' )
            {
                $binding.CertificateHash | Should -Be $value
            }
            elseif( $name -eq 'Application ID' )
            {
                $binding.ApplicationID | Should -Be ([Guid]$value)
            }
            elseif( $name -eq 'Certificate Store Name' )
            {
                if( $value -eq '' )
                {
                    $value = $null
                }
                $binding.CertificateStoreName | Should -Be $value
            }
            elseif( $name -eq 'Verify Client Certificate Revocation' )
            {
                $binding.VerifyClientCertificateRevocation | Should -Be $value
            }
            elseif( $name -eq 'Verify Revocation Using Cached Client Certificate Only' )
            {
                $binding.VerifyRevocationUsingCachedClientCertificatesOnly | Should -Be $value
            }
            elseif( $name -eq 'Revocation Freshness Time' )
            {
                $binding.RevocationFreshnessTime | Should -Be $value
            }
            elseif( $name -eq 'URL Retrieval Timeout' )
            {
                $binding.UrlRetrievalTimeout | Should -Be $value
            }
            elseif( $name -eq 'Ctl Identifier' )
            {
                $binding.CtlIdentifier | Should -Be $value
            }
            elseif( $name -eq 'Ctl Store Name' )
            {
                $binding.CtlStoreName | Should -Be $value
            }
            elseif( $name -eq 'DS Mapper Usage' )
            {
                $binding.DSMapperUsageEnabled | Should -Be $value
            }
            elseif( $name -eq 'Negotiate Client Certificate' )
            {
                $binding.NegotiateClientCertificate | Should -Be $value
            }
        }

        $numBindings =
            netsh http show sslcert |
             Where-Object { $_ -match '^[ \t]+IP:port[ \t]+: (.*)$' } |
             Measure-Object |
             Select-Object -ExpandProperty Count

        Get-CHttpsCertificateBinding | Should -HaveCount $numBindings
    }

    It 'should filter by IP address and port' {
        $foundOne = $false
        foreach ($line in (netsh http show sslcert))
        {
            if (-not ($line -match '^    IP:port\s+: (.*)$'))
            {
                continue
            }

            if( $foundOne )
            {
                return
            }

            $ipPort = $matches[1].Trim()
            if( $ipPort -notmatch '^(.*):(\d+)$' )
            {
                Write-Error ('Invalid IP address/port in netsh output: ''{0}''' -f $ipPort )
                return
            }
            $ipAddress = $matches[1]
            $port = $matches[2]

            $foundOne = $false
            foreach ($binding in (Get-CHttpsCertificateBinding -IPAddress $ipAddress))
            {
                $binding | Should -Not -BeNullOrEmpty
                $binding.IPAddress | Should -Be ([ipaddress]$ipAddress)
                $foundOne = $true
            }
            $foundOne | Should -BeTrue

            $foundOne = $false
            foreach ($binding in (Get-CHttpsCertificateBinding -Port $port))
            {
                $binding | Should -Not -BeNullOrEmpty
                $binding.Port | Should -Be $port.Trim()
                $foundOne = $true
            }
            $foundOne | Should -BeTrue
        }
    }

    It 'should get IPv6 binding' {
        $certPath = Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificate.cer' -Resolve
        $cert = Install-CCertificate -Path $certPath -StoreLocation LocalMachine -StoreName My -PassThru
        $appID = '12ec3276-0689-42b0-ad39-c1fe23d25721'
        Set-CHttpsCertificateBinding -IPAddress '[::]' -Port 443 -ApplicationID $appID -Thumbprint $cert.Thumbprint

        try
        {
            $binding = Get-CHttpsCertificateBinding -IPAddress '[::]' | Where-Object { $_.ApplicationID -eq $appID }
            $binding | Should -Not -BeNullOrEmpty
        }
        finally
        {
            Remove-CHttpsCertificateBinding -IPAddress '[::]' -Port 443
        }
    }
}
