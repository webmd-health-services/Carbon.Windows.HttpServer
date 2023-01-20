
function Test-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Tests if an HTTPS certificate binding exists.

    .DESCRIPTION
    The `Test-CHttpsCertificateBinding` tests if an HTTPS certificate binding exists. You can check if a binding exists
    by passing an IP address, port, certificate thumbprint, and/or application ID to the `IPAddress`, `Port`,
    `Thumbprint`, and `ApplicationID` parameters, respectively. If a cert exists that matches all the criteria you
    pass, the function returns `$true`, otherwise it returns `$false`. If you pass no arguments, the function tests if
    *any* bindings exist.

    .EXAMPLE
    Test-CHttpsCertificateBinding -Port 443

    Tests if there are any bindings on port 443.

    .EXAMPLE
    Test-CHttpsCertificateBinding -IPAddress 10.0.1.1

    Tests if there are any bindings on IP address `10.0.1.1`.

    .EXAMPLE
    Test-CHttpsCertificateBinding -Thumbprint '7d5ce4a8a5ec059b829ed135e9ad8607977691cc'

    Tests if there are any bindings to certificate with thumbprint `7d5ce4a8a5ec059b829ed135e9ad8607977691cc`.

    .EXAMPLE
    Test-CHttpsCertificateBinding -ApplicationID '71740b45-ea65-48c4-a8bd-6f2110c52ba7'

    Tests if there are any bindings for application whose ID is `71740b45-ea65-48c4-a8bd-6f2110c52ba7`.

    .EXAMPLE
    Test-CHttpsCertificateBinding

    Tests if there are any bindings on the machine.
    #>
    [CmdletBinding()]
    param(
        # The IP address.
        [ipaddress] $IPAddress,

        # The port.
        [Uint16] $Port,

        # The certificate thumbprint.
        [String] $Thumbprint,

        # The application ID
        [Guid] $ApplicationID
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $getArgs = @{ }
    if ($IPAddress)
    {
        $getArgs['IPAddress'] = $IPAddress
    }

    if ($Port)
    {
        $getArgs['Port']= $Port
    }

    if ($Thumbprint)
    {
        $getArgs['Thumbprint'] = $Thumbprint
    }

    if ($ApplicationID)
    {
        $getArgs['ApplicationID'] = $ApplicationID
    }

    $binding = Get-CHttpsCertificateBinding @getArgs -ErrorAction Ignore

    if ($binding)
    {
        return $true
    }

    return $false
}

