
function Get-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Gets the HTTPS certificate bindings on this computer.

    .DESCRIPTION
    The `Get-CHttpsCertificateBinding` returns all the HTTPS certificate bindings on the current computer. You can get
    specific bindings using an IP address, port, certificate thumbprint, and/or application ID, by using the
    `IPAddress`, `Port`, `Thumbprint`, and `ApplicationID` parameters. If a certificate that matches all the search
    criteria isn't found, the function writes an error.

    Uses the Windows API.

    .OUTPUTS
    Carbon.Windows.HttpServer.HttpsCertificateBinding.

    .EXAMPLE
    > Get-CHttpsCertificateBinding

    Demonstrates how to gets all the HTTPS certificate bindings on the local computer.

    .EXAMPLE
    > Get-CHttpsCertificateBinding -IPAddress 42.37.80.47 -Port 443

    Demonstrates how to get the binding for a specific IP address and port.

    .EXAMPLE
    Get-HttpsCertificateBinding -IPAddress '1.2.3.4'

    Demonstrates how to get all bindings on a specific IP address by passing the IP address number to the `IPAddress`
    parameter.

    .EXAMPLE
    > Get-CHttpsCertificateBinding -Port 443

    Demonstrates how to get all bindings on a specific port by passing the port number to the `Port` parameter.

    .EXAMPLE
    Get-CHttpsCertificateBinding -Thumbprint '4789073458907345907434789073458907345907'

    Demonstrates how to get all bindings using a specific certificate by passing the certificate's thumbprint to the
    `Thumbprint` parameter.

    .EXAMPLE
    Get-CHttpsCertificateBinding -ApplicationID '0c5a28db-f7e0-42f8-912b-9524fb49f054'

    Demonstrates how to get all bindings for a specific application by passing the application id to the
    `ApplicationID` parameter.
    #>
    [CmdletBinding()]
    [OutputType([Carbon.Windows.HttpServer.HttpsCertificateBinding])]
    param(
        # An IP address. Only bindings with this IP address are returned.
        [ipaddress] $IPAddress,

        # A port. Only bindings with this port number are returned.
        [UInt16] $Port,

        # A certificate thumbprint. Only bindings whose certificate hash matches this thumbprint are returned.
        [String] $Thumbprint,

        # An application ID. Only bindings whose application ID matches this value are returned.
        [Guid] $ApplicationID
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState
    $WhatIfPreference = $false

    $searching = $IPAddress -or $Port -or $Thumbprint -or $ApplicationID
    $bindings = @()
    [Carbon.Windows.HttpServer.HttpsCertificateBinding]::GetHttpsCertificateBindings() |
        Where-Object {
            if( $IPAddress )
            {
                return $_.IPAddress -eq $IPAddress
            }
            return $true
        } |
        Where-Object {
            if( $Port )
            {
                return $_.Port -eq $Port
            }
            return $true
        } |
        Where-Object {
            if( $Thumbprint )
            {
                return $_.CertificateHash -eq $Thumbprint
            }
            return $true
        } |
        Where-Object {
            if( $ApplicationID )
            {
                return $_.ApplicationID -eq $ApplicationID
            }
            return $true
        } |
        Tee-Object -Variable 'bindings' |
        Write-Output

    if (-not $searching -or $bindings)
    {
        return
    }

    $ipPortMsg = ''
    if (-not $IPAddress)
    {
        $IPAddress = [ipaddress]'0.0.0.0'
    }

    $ipPortMsg = "$($IPAddress.IPAddressToString)"
    if ($IPAddress.AddressFamily -eq 'InterNetworkV6')
    {
        $ipPortMsg = "[$($ipPortMsg)]"
    }

    if ($Port)
    {
        $ipPortMsg = "$($ipPortMsg.TrimEnd()):$($Port)"
    }

    $thumbprintMsg = ''
    if ($Thumbprint)
    {
        $ipPortMsg = " using certificate $($Thumbprint)"
    }

    $appIdMsg = ''
    if ($ApplicationID)
    {
        $appIdMsg = " for application $($ApplicationID.ToString('B'))"
    }

    $msg = "HTTPS certificate binding $($ipPortMsg)$($thumbprintMsg)$($appIdMsg) does not exist."
    Write-Error -Message $msg -ErrorAction $ErrorActionPreference
}
